import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedFolder = ""
    @State private var selectedFile = ""

    @State private var folderNames = [String]()
    @State private var fileNames = [String]()
    @State private var fileContents = ""

    @State private var deletionEnabled = false

    var body: some View {
        NavigationSplitView {
            SidebarListView()
        } content: {
            MiddleListView()
        } detail: {
            DetailView()
        }
        .navigationTitle(!selectedFile.isEmpty ? selectedFile : NSApplication.bundleName)
        .searchable(text: $searchText, placement: .toolbar)
        .toolbar {
            NavigationToolbar(
                onOpenInFinderPressed: {
                    openFileInFinder()
                },
                openInFinderDisabledCondition: selectedFile.isEmpty
            )
        }
        .onAppearOnce {
            folderNames = getFiles(from: outputDirectory)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.folderSelectedFromFinderNotification)) { _ in
            folderNames = fetchFolders()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.directoryDeletedNotification)) { notification in
            guard let folderNotification = notification.object as? FolderNotification else {
                let object = notification.object as Any
                assertionFailure("Invalid object: \(object)")
                return
            }

            folderNames = fetchFolders()

            if isSelectedFolder(folderNotification.folderName) {
                fileNames = []
            }

            if folderNames.isEmpty {
                resetContent()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.resetContentNotification)) { _ in
            resetContent()
        }
    }
}

extension ContentView {

    // MARK: Views

    func SidebarListView() -> some View {
        List(folderNames, id: \.self) { folderName in
            HStack {
                Label {
                    Text(folderName)
                        .fontWeight(isSelectedFolder(folderName) ? .bold : .regular)
                } icon: {
                    Image(systemName: "folder")
                        .foregroundColor(.accentColor)
                }

                Spacer()

                if deletionEnabled {
                    Button(action: {
                        deleteDirectory(folder: folderName)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .font(.subheadline)
            .onTapGesture {
                onPrimarySelected(folderName: folderName)
            }
            .contextMenu {
                Button(action: {
                    openFolderInFinder(folderName)
                }) {
                    Text("Reveal in Finder")
                }

                Button(action: {
                    deleteDirectory(folder: folderName)
                }) {
                    Text("Delete")
                }
            }
        }
        .listStyle(SidebarListStyle())
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                if !folderNames.isEmpty {
                    Button(action: {
                        deletionEnabled.toggle()
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(deletionEnabled ? .accentColor : .none)
                    }
                }
                
                ImportView()
            }
        }
    }

    func MiddleListView() -> some View {
        Group {
            if noMatchesfound {
                Text("No matches found")
                    .font(.largeTitle)
            }
            else if fileNames.isEmpty {
                Text("No files found")
                    .font(.largeTitle)
            } else {
                List(filteredFileNames, id: \.self) { fileName in
                    HStack {
                        Label {
                            Text(fileName)
                                .fontWeight(isSelectedFile(fileName) ? .bold : .regular)
                        } icon: {
                            Image(systemName: "doc.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .onTapGesture {
                        onSecondarySelected(fileName: fileName)
                    }
                    .contextMenu {
                        Button(action: {
                            openFileInFinder(fileName)
                        }) {
                            Text("Reveal in Finder")
                        }
                    }
                }
            }
        }
    }
    
    func DetailView() -> some View {
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
    
    struct NavigationToolbar: ToolbarContent {
        let onOpenInFinderPressed: () -> Void
        let openInFinderDisabledCondition: Bool
        
        var body: some ToolbarContent {
            ToolbarItem(placement: .navigation) {
                Button(action: onOpenInFinderPressed) {
                    Image(systemName: "info.circle")
                }
                .disabled(openInFinderDisabledCondition)
                .keyboardShortcut("i", modifiers: [.command])
            }
        }
    }
}

extension ContentView {

    // MARK: Utilities

    private func isSelectedFolder(_ folderName: String) -> Bool {
        return folderName.caseInsensitiveCompare(selectedFolder) == .orderedSame
    }
    
    private func isSelectedFile(_ fileName: String) -> Bool {
        return fileName.caseInsensitiveCompare(selectedFile) == .orderedSame
    }
    
    var filteredFileNames: [String] {
        if searchText.isEmpty {
            return fileNames
        } else {
            return fileNames.filter { $0.forSearch().contains(searchText.forSearch()) }
        }
    }

    func onPrimarySelected(folderName: String) {
        if isSelectedFolder(folderName) == false {
            selectedFile = ""
            fileContents = ""
        }

        selectedFolder = folderName
        fileNames = getFiles(from: outputDirectory.appendingPathComponent(folderName))
    }

    func onSecondarySelected(fileName: String) {
        selectedFile = fileName

        let path = outputDirectory
            .appendingPathComponent(selectedFolder)
            .appendingPathComponent(fileName)
            .relativePath

        if let contents = try? String(contentsOf: URL(filePath: path )) {
            fileContents = contents
        }
    }

    func openFileInFinder(_ fileAtRow: String? = nil) {
        var fileUrl: URL = outputDirectory.appendingPathComponent(selectedFolder)

        if let file = fileAtRow {
            fileUrl = fileUrl.appendingPathComponent(file)
        } else {
            fileUrl = fileUrl.appendingPathComponent(selectedFile)
        }

        NSWorkspace.shared.selectFile(fileUrl.path, inFileViewerRootedAtPath: fileUrl.path)
    }

    func openFolderInFinder(_ selectedFolderAtRow: String) {
        let folderUrl: URL = outputDirectory.appendingPathComponent(selectedFolderAtRow)
        NSWorkspace.shared.selectFile(folderUrl.path, inFileViewerRootedAtPath: folderUrl.path)
    }

    func resetContent() {
        folderNames = []
        fileNames = []
        fileContents = ""
        selectedFile = ""
    }
    
    var noMatchesfound: Bool {
        !searchText.isEmpty &&
        !selectedFolder.isEmpty &&
        !fileNames.isEmpty &&
        filteredFileNames.isEmpty
    }

    func fetchFolders() -> [String] {
        return getFiles(from: outputDirectory)
    }
    
    func deleteDirectory(folder: String) {
        let pathToRemove = outputDirectory.appendingPathComponent(folder)
        try? FileManager.default.removeItem(atPath: pathToRemove.path)
        NotificationCenter.default.post(name: .directoryDeletedNotification, object: FolderNotification(folderName: folder))
    }
    
    func getFiles(from path: URL, removeEnding: Bool = false) -> Array<String> {
        var files: [String] = []

        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: path,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )

            let fileNames = directoryContents.map {
                removeEnding ? $0.deletingPathExtension().lastPathComponent : $0.lastPathComponent
            }

            files.append(contentsOf: fileNames)
        } catch {
            print(error)
        }

        return files.sorted()
    }
}

struct FolderNotification {
    let folderName: String
}

struct ImportView: View {
    @State private var importing = false

    var body: some View {
        Button(action: {
            importing = true
        }) {
            Image(systemName: "plus")
        }
        .keyboardShortcut("o", modifiers: [.command])
        .fileImporter(
            isPresented: $importing,
            allowedContentTypes: [.application, .executable]
        ) { result in
            switch result {
            case .success(let file):
                onFileImport(file: file)
                NotificationCenter.default.post(name: .folderSelectedFromFinderNotification, object: nil)
            case .failure(let error):
                print("Unable to read file contents: \(error.localizedDescription)")
            }
        }
    }
}

extension ImportView {
    func onFileImport(file: URL) {
        // TODO: allow the user to configure the save location
        let outputDirectoryURL = outputDirectory
            .appendingPathComponent(file.deletingPathExtension().lastPathComponent)

        try? FileManager.default.createDirectory(atPath: outputDirectoryURL.path, withIntermediateDirectories: true)

        if let path = Bundle.main.url(forResource: "class-dump", withExtension: "") {
            let _ = executeCommand(executableURL:path, args: [file.path, "-H", "-o", outputDirectoryURL.path])
        }
    }

    func executeCommand(executableURL: URL, args: [String]) -> String {
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        let task = Process()
        task.executableURL = executableURL
        task.arguments = args
        task.standardOutput = outputPipe
        task.standardError = errorPipe

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            fatalError("Something went wrong when trying to invoke \(executableURL.path)")
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let _ = String(decoding: outputData, as: UTF8.self)
        let standardError = String(decoding: errorData, as: UTF8.self)
        
        return standardError
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
