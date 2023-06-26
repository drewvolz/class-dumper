import GRDB
import GRDBQuery
import Files
import SwiftUI

/// The main application view
struct AppView: View {
    @Environment(\.fileRepository) private var fileRepository

    /// A helper `Identifiable` type that can feed SwiftUI `sheet(item:onDismiss:content:)`
    private struct EditedFile: Identifiable {
        var id: Int64
    }
    
    @Query(FileRequest())
    private var files: Array<File?>
    
    private var filteredFileNames: Array<File?> {
        if searchText.isEmpty {
            return files
        } else {
            return files.filter { $0?.name.forSearch().contains(searchText.forSearch()) ?? false }
        }
    }
    
    @State private var editedFile: EditedFile?
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            let directories = Array(Set(files.map { entry in
                entry?.folder ?? ""
            })).sorted()
            
            if !directories.isEmpty {
                SidebarListView(directories: directories)
            } else {
                EmptyFooter()
                Spacer()
            }
        } content: {

        } detail: {

        } 
        .padding(.horizontal)
        .sheet(item: $editedFile) { file in
            FileEditionView(id: file.id)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.folderSelectedFromFinderNotification)) { _ in
            parseDirectory()
        }
        .toolbar {
            ToolbarItemGroup {
                CreateFileButton("Create a File")
            }
        }
        .searchable(text: $searchText, prompt: "Search files")
        .navigationTitle(NSApplication.bundleName)
    }
}

extension AppView {
    
    func SidebarListView(directories: [String?]) -> some View {
        List(directories, id: \.self) { entry in
            Label {
                if let label = entry {
                    NavigationLink(label) {
                        MiddleListView(label: label)
                   }
                }
            } icon: {
                Image(systemName: "folder")
                    .foregroundColor(.accentColor)
            }
        }
        .listStyle(SidebarListStyle())
    }
    
    func MiddleListView(label: String) -> some View {
        List(filteredFileNames, id: \.?.id) { entry in
            if let contents = entry?.contents, entry?.folder == label {
                NavigationLink(destination: DetailView(contents: contents)) {
                    if let file = entry {
                        FileView(file: file)
                    }
                }
            }
        }
    }
    
    func DetailView(contents: String) -> some View {
        FileConentsView(fileContents: contents)
    }

    func parseDirectory() {
        if let directory = FileManager.default.enumerator(at: outputDirectory.resolvingSymlinksInPath(), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            while let url = directory.nextObject() as? URL {
                if (url.pathExtension != "" && !url.hasDirectoryPath) {
                    let directory = url.deletingLastPathComponent().lastPathComponent
                    let filename = url.lastPathComponent
                    let contents = parseFile(atPath: url.relativePath)
                    
                    _ = try! fileRepository.insert(File.createFile(name: filename, folder: directory, contents: contents))
                }
            }
        }

        deleteTempDirectory()
    }
    
    func parseFile(atPath path: String) -> String {
        if let contents = try? String(contentsOf: URL(filePath: path)) {
            return contents
        }
        
        return ""
    }
    
    /// The output from `class-dump`is temporarily stored on-disk so that we can parse structured
    /// output. Otherwise, we'd have to write a parser to get the same data structure for the header files.
    /// It is good to clean up the resulting directory saved on disk as ClassDumper's goal is to have info
    /// about mach-o files stored within its own sqlite database. This affords us the nicety of asking our
    /// own cached database instead of querying a user's directories each run.
    func deleteTempDirectory() {
        try? FileManager.default.removeItem(atPath: outputDirectory.path)
    }
    
    func FileConentsView(fileContents: String) -> some View {
        Group{
            ZStack {
                TextEditor(text: .constant(fileContents))
                    .padding(8)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(Color(NSColor.labelColor))
            }
            .background(Color(NSColor.textBackgroundColor))
        }
    }

    private func EmptyFooter() -> some View {
        VStack {
            Text("Start by opening a file to get going with class dumping.")
                .informationStyle()
            
            CreateFileButton("Open a File")
        }
        .informationBox()
    }
    
    private func populatedFooter(id: Int64) -> some View {
        VStack(spacing: 10) {
            Text("What if another application component deletes the file at the most unexpected moment?")
                .informationStyle()
            DeleteFilesButton("Delete File")
            
            Spacer().frame(height: 10)
            Text("What if the file is deleted soon after the Edit button is hit?")
                .informationStyle()
            DeleteFilesButton("Delete After Editing", after: {
                editFile(id: id)
            })
            
            Spacer().frame(height: 10)
            Text("What if the file is deleted right before the Edit button is hit?")
                .informationStyle()
            DeleteFilesButton("Delete Before Editing", before: {
                editFile(id: id)
            })
        }
        .informationBox()
    }
    
    private func editFile(id: Int64) {
        editedFile = EditedFile(id: id)
    }
}

/// A @Query request that observes the file (any file, actually) in the database
private struct FileRequest: Queryable {
    static var defaultValue: Array<File?> { [] }
    
    func publisher(in fileRepository: FileRepository) -> DatabasePublishers.Value<Array<File?>> {
        ValueObservation
            .tracking(File.fetchAll)
            .publisher(in: fileRepository.reader, scheduling: .immediate)
    }
}
