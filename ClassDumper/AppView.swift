import GRDB
import GRDBQuery
import Files
import SwiftUI

typealias FileDatabase = Array<File>

struct AppView: View {
    @Environment(\.fileRepository) private var fileRepository

    @Query(FileRequest())
    fileprivate var files: FileDatabase
    
    @State var deletionEnabled = false

    private var filteredFileNames: FileDatabase {
        if searchText.isEmpty {
            return files
        } else {
            return files.filter { $0.name.forSearch().contains(searchText.forSearch()) }
        }
    }
    
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            if !files.isEmpty {
                FolderRowView(deletionEnabled: deletionEnabled)
                    .toolbar {
                        ToolbarItemGroup(placement: .automatic) {
                            Spacer()
                            EditToolbarButton()
                            CreateFileButton()
                        }
                    }
            } else {
                EmptyFooter()
                Spacer()
            }
        } content: {

        } detail: {

        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.folderSelectedFromFinderNotification)) { _ in
            parseDirectory()
        }
        .searchable(text: $searchText, prompt: "Search files")
        .navigationTitle(NSApplication.bundleName)
    }
}

extension AppView {

    @ViewBuilder
    func EditToolbarButton() -> some View {
        if !files.isEmpty {
            Button(action: {
                withAnimation {
                    deletionEnabled.toggle()
                }
            }, label: {
                Label("Edit files", systemImage: "pencil")
                    .foregroundColor(deletionEnabled ? .accentColor : .none)
            })
            .keyboardShortcut("e", modifiers: [.command])
        }
    }

    func parseDirectory() {
        if let directory = FileManager.default.enumerator(at: outputDirectory.resolvingSymlinksInPath(), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            
            /// batching changes so that inserts can be done in a single transaction
            var filesToinsert = [File]()

            while let url = directory.nextObject() as? URL {
                if (url.pathExtension != "" && !url.hasDirectoryPath) {
                    let directory = url.deletingLastPathComponent().lastPathComponent
                    let filename = url.lastPathComponent
                    let contents = parseFile(atPath: url.relativePath)
                    
                    filesToinsert.append(File.createFile(name: filename, folder: directory, contents: contents))
                }
            }

            try! fileRepository.insert(filesToinsert)
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
    ///
    /// It is good to clean up the resulting directory saved on disk as ClassDumper's goal is to have info
    /// about mach-o files stored within its own sqlite database. This affords us the nicety of asking our
    /// own cached database instead of querying a user's directories each run.
    ///
    /// An improvement around this could be moving the temporary folder to a safer directory meant for
    /// writing by sandboxed applications.
    func deleteTempDirectory() {
        try? FileManager.default.removeItem(atPath: outputDirectory.path)
    }

    private func EmptyFooter() -> some View {
        VStack {
            Text("Open a file to get started with class dumping.")
                .informationStyle()
            
            CreateFileButton()
        }
        .informationBox()
    }
}

/// A @Query request that observes the file (any file, actually) in the database
private struct FileRequest: Queryable {
    static var defaultValue: FileDatabase { [] }
    
    func publisher(in fileRepository: FileRepository) -> DatabasePublishers.Value<FileDatabase> {
        ValueObservation
            .tracking(File.fetchAll)
            .publisher(in: fileRepository.reader, scheduling: .immediate)
    }
}
