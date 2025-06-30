import Files
import SwiftUI

/// A helper button that creates files in the database
struct CreateFileButton: View {
    @Environment(\.fileRepository) private var fileRepository
    @EnvironmentObject var alertController: AlertController

    private var titleKey: LocalizedStringKey
    
    init(_ titleKey: LocalizedStringKey = "Open…") {
        self.titleKey = titleKey
    }
    
    private var panel: NSOpenPanel = {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application, .executable, .symbolicLink, .aliasFile]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.treatsFilePackagesAsDirectories = true
        return panel
    }()

    private func openPanel() {
        switch panel.runModal() {
        case .OK:
            guard let url = panel.url else {
                print("Unable to read file url path from NSOpenPanel.")
                return
            }
            success(with: url)
        case .cancel:
            break // noop, need something on this line with breaks being implicit
        case .abort, .stop:
            print("Abort or stop result from NSOpenPanel. No filepath to pass.")
        default:
            print("Something went really wrong with NSOpenPanel. Unable to read file contents")
        }
    }

    var body: some View {
        Button {
            openPanel()
        } label: {
            Label(titleKey, systemImage: "folder.badge.plus")
        }
        .keyboardShortcut("o", modifiers: [.command])
    }
}

extension CreateFileButton {

    func getSelectedFilePath(for path: URL) -> URL {
        var selectedPath = path
        let bundledPath = Bundle.main.url(forResource: "class-dump", withExtension: "")

        if CommandLine.arguments.contains(Keys.UITesting), let bundled = bundledPath {
            selectedPath = bundled
        }

        return selectedPath
    }

    func success(with path: URL) {
        onFileImport(file: getSelectedFilePath(for: path))
        NotificationCenter.default.post(name: .folderSelectedFromFinderNotification, object: nil)
    }

    func onFileImport(file: URL) {
        let result = FileProcessingUtils.processFile(fileURL: file, alertController: alertController)

        switch result {
        case .success:
            NotificationCenter.default.post(name: .folderSelectedFromFinderNotification, object: nil)
        case .failure:
            // error is already handled by FileProcessingUtils.checkErrorOutput
            break
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
