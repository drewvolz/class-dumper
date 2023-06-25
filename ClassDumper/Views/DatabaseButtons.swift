import Files
import SwiftUI
import UniformTypeIdentifiers

/// A helper button that creates files in the database
struct CreateFileButton: View {
    @Environment(\.fileRepository) private var fileRepository

    @State private var importing = false
    private var readableContentTypes: [UTType] =  [.application, .data, .executable]
    private var titleKey: LocalizedStringKey
    
    init(_ titleKey: LocalizedStringKey) {
        self.titleKey = titleKey
    }
    
    var body: some View {
        Button {
            importing = true
        } label: {
            Label(titleKey, systemImage: "plus")
        }
        .fileImporter(
            isPresented: $importing,
            allowedContentTypes: readableContentTypes
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

extension CreateFileButton {
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

/// A helper button that deletes files in the database
struct DeleteFilesButton: View {
    private enum Mode {
        case delete
        case deleteAfter(() -> Void)
        case deleteBefore(() -> Void)
    }
    
    @Environment(\.fileRepository) private var fileRepository
    private var titleKey: LocalizedStringKey
    private var mode: Mode
    
    /// Creates a button that simply deletes files.
    init(_ titleKey: LocalizedStringKey) {
        self.titleKey = titleKey
        self.mode = .delete
    }
    
    /// Creates a button that deletes files soon after performing `action`.
    init(
        _ titleKey: LocalizedStringKey,
        after action: @escaping () -> Void)
    {
        self.titleKey = titleKey
        self.mode = .deleteAfter(action)
    }
    
    /// Creates a button that deletes files immediately after performing `action`.
    init(
        _ titleKey: LocalizedStringKey,
        before action: @escaping () -> Void)
    {
        self.titleKey = titleKey
        self.mode = .deleteBefore(action)
    }
    
    var body: some View {
        Button {
            switch mode {
            case .delete:
                _ = try! fileRepository.deleteAllFile()
                
            case let .deleteAfter(action):
                action()
                Task {
                    try await Task.sleep(nanoseconds: 100_000_000)
                    try fileRepository.deleteAllFile()
                }
                
            case let .deleteBefore(action):
                _ = try! fileRepository.deleteAllFile()
                action()
            }
        } label: {
            Label(titleKey, systemImage: "trash")
        }
    }
}

// For tracking the file count in the preview
import GRDB
import GRDBQuery

struct DatabaseButtons_Previews: PreviewProvider {
    struct FileCountRequest: Queryable {
        static var defaultValue: Int { 0 }
        
        func publisher(in fileRepository: FileRepository) -> DatabasePublishers.Value<Int> {
            ValueObservation
                .tracking(File.fetchCount)
                .publisher(in: fileRepository.reader, scheduling: .immediate)
        }
    }
    
    struct Preview: View {
        @Query(FileCountRequest())
        var fileCount: Int
        
        var body: some View {
            VStack {
                Text("Number of files: \(fileCount)")
                CreateFileButton("Create File")
                DeleteFilesButton("Delete Files")
            }
            .informationBox()
            .padding()
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
