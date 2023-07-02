import Files
import SwiftUI

/// A helper button that creates files in the database
struct CreateFileButton: View {
    @Environment(\.fileRepository) private var fileRepository
    @EnvironmentObject var alertController: AlertController
    
    @AppStorage("enableVerboseImportErrorLogging") var enableVerboseImportErrorLogging = false

    @State private var importing = false
    private var titleKey: LocalizedStringKey
    
    init(_ titleKey: LocalizedStringKey = "Add new file") {
        self.titleKey = titleKey
    }
    
    var body: some View {
        Button {
            importing = true
        } label: {
            Label(titleKey, systemImage: "folder.badge.plus")
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

extension CreateFileButton {
    func onFileImport(file: URL) {
        // TODO: allow the user to configure the save location
        let outputDirectoryURL = outputDirectory
            .appendingPathComponent(file.deletingPathExtension().lastPathComponent)

        try? FileManager.default.createDirectory(atPath: outputDirectoryURL.path, withIntermediateDirectories: true)

        if let path = Bundle.main.url(forResource: "class-dump", withExtension: "") {
            let errorOutput = executeCommand(executableURL:path, args: [file.path, "-H", "-o", outputDirectoryURL.path])
            checkErrorOutput(message: errorOutput, outputDirectory: outputDirectoryURL)
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

    func checkErrorOutput(message: String, outputDirectory: URL) {
        if !message.isEmpty {
            var messageTitle = ""
            var messageContent = ""

            // the most common error we'll come across is when no Mach-O files are generated
            let noRuntimeInfoWarning = "does not contain any Objective-C runtime information"

            if message.contains(noRuntimeInfoWarning) {
                messageTitle = "Nothing to parse"
                messageContent = "\(outputDirectory.lastPathComponent) \(noRuntimeInfoWarning)"
            } else {
                messageTitle = "An unexpected error occurred"
                messageContent = message.formatConsoleOutput(skip: enableVerboseImportErrorLogging)
            }

            alertController.info = AlertInfo(
                id: .importNoObjcRuntimeInformation,
                title: messageTitle,
                message: messageContent,
                level: .message
            )
        }
    }
}

/// A helper button that deletes files in the database
struct DeleteFilesButton: View {
    @Environment(\.fileRepository) private var fileRepository
    @EnvironmentObject var alertController: AlertController

    private enum Mode {
        case deleteFolder
        case deleteAfter(() -> Void)
        case deleteBefore(() -> Void)
        case deleteAllRecordsWithPrompt(() -> Void)
    }
    
    private var titleKey: LocalizedStringKey
    private var mode: Mode

    /// Used only for folder deletion
    private var folderKey: String = ""

    /// Creates a button that simply deletes folders and their records.
    init(_ titleKey: LocalizedStringKey, folderKey: String) {
        self.titleKey = titleKey
        self.mode = .deleteFolder
        self.folderKey = folderKey
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
    
    /// Creates a button that deletes files only after confirming, then runs an `action`.
    init(
        _ titleKey: LocalizedStringKey,
        afterWithPrompt action: @escaping () -> Void)
    {
        self.titleKey = titleKey
        self.mode = .deleteAllRecordsWithPrompt(action)
    }
    
    var body: some View {
        Button {
            switch mode {
            case .deleteFolder:
                _ = try! fileRepository.deleteFolder(folderKey: folderKey)
                
            case let .deleteAfter(action):
                action()
                Task {
                    try await Task.sleep(nanoseconds: 100_000_000)
                    try fileRepository.deleteAllFiles()
                }
                
            case let .deleteBefore(action):
                _ = try! fileRepository.deleteAllFiles()
                action()
                
            case let .deleteAllRecordsWithPrompt(action):
                alertController.info = AlertInfo(
                    id: .settingsDeleteSavedDataPrompt,
                    title: "Are you sure you want to delete the saved data?",
                    message: "There is no undoing this action.",
                    level: .warning,
                    primaryButtonMessage: "Delete",
                    primaryButtonAction: {
                        _ = try! fileRepository.deleteAllFiles()
                        action()
                    }
                )
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
                CreateFileButton()
                DeleteFilesButton("Delete files", folderKey: "")
            }
            .informationBox()
            .padding()
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
