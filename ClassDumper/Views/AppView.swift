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
    
    @State private var editedFile: EditedFile?
    
    var body: some View {
        NavigationSplitView {
            let directories = Array(Set(files.map { entry in
                return entry?.folder
            }))
            
            if !directories.isEmpty {
                List(directories, id: \.self) { entry in
                    Label {
                        if let label = entry {
                            NavigationLink(label) {
                                List(files, id: \.?.id) { entry in
                                    if let name = entry?.name, let contents = entry?.contents, entry?.folder == label {
                                        NavigationLink(destination:
                                            FileConentsView(fileContents: contents)
                                        ) {
                                            Text(name)
                                        }
                                    }
                                }
                           }
                        }
                    } icon: {
                        Image(systemName: "folder")
                            .foregroundColor(.accentColor)
                    }
                }
                .listStyle(SidebarListStyle())
            } else {
                FileView(file: .placeholder)
                    .padding(.vertical)
                    .redacted(reason: .placeholder)
                    .padding(.horizontal)

                Spacer()
                emptyFooter()
            }
        } content: {

        } detail: {
            emptyFooter()

        } 
        .padding(.horizontal)
        .sheet(item: $editedFile) { file in
            FileEditionView(id: file.id)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.newFilesAddedNotification)) { _ in
            parseDirectory()
        }
        .toolbar {
            ToolbarItemGroup {
                CreateFileButton("Create a File")
            }
        }
        .navigationTitle(NSApplication.bundleName)
    }
}

extension AppView {

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

        deleteDirectory()
    }
    
    func parseFile(atPath path: String) -> String {
        if let contents = try? String(contentsOf: URL(filePath: path)) {
            return contents
        }
        
        return ""
    }
    
    func deleteDirectory() {
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

    private func emptyFooter() -> some View {
        VStack {
            Text("The demo application observes the database and displays information about the file.")
                .informationStyle()
            
            CreateFileButton("Create a File")
            
            Text("What if another application component deletes the file at the most unexpected moment?")
                .informationStyle()
            DeleteFilesButton("Delete File")
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
