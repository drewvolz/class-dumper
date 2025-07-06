import SwiftUI
import UniformTypeIdentifiers
import Files
import GRDB

struct DatabaseSettingsView: View {
    @AppStorage("accent") var accent = CodableColor(.accentColor)
    @State private var showingImportPanel = false
    @State private var showingExportPanel = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DatabaseInfo()
            ImportDatabase()
            ExportDatabase()
            ResetDataButton()
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }
}

extension DatabaseSettingsView {
    @ViewBuilder
    func DatabaseInfo() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let databaseURL = getDatabaseURL() {
                Button(action: {
                    NSWorkspace.shared.selectFile(databaseURL.path, inFileViewerRootedAtPath: databaseURL.deletingLastPathComponent().path)
                }) {
                    Text(databaseURL.path)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.blue)
                        .textSelection(.enabled)
                }
                .buttonStyle(.plain)
            }
        }
        .modifier(PreferencesTabViewModifier(sectionTitle: "Location"))
    }

    @ViewBuilder
    func ResetDataButton() -> some View {
        DeleteFilesButton("Delete all saved data", afterWithPrompt: {
            // noop, deletion with prompting is handled in the button
            // but side effects may be placed here if desired.
        })
        .modifier(PreferencesTabViewModifier(sectionTitle: "Reset"))
    }

    @ViewBuilder
    func ImportDatabase() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button("Import Database") {
                showingImportPanel = true
            }
            .buttonStyle(.borderedProminent)
            .tint(accent.toColor())

            Text("Importing will replace the current database.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .modifier(PreferencesTabViewModifier(sectionTitle: "Import"))
        .fileImporter(
            isPresented: $showingImportPanel,
            allowedContentTypes: [UTType(filenameExtension: "sqlite")!, UTType(filenameExtension: "db")!],
            allowsMultipleSelection: false
        ) { result in
            handleImportResult(result)
        }
    }

    @ViewBuilder
    func ExportDatabase() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button("Export Database") {
                showingExportPanel = true
            }
            .buttonStyle(.bordered)
            .tint(accent.toColor())
        }
        .modifier(PreferencesTabViewModifier(sectionTitle: "Export"))
        .fileExporter(
            isPresented: $showingExportPanel,
            document: DatabaseDocument(),
            contentType: UTType(filenameExtension: "sqlite")!,
            defaultFilename: "ClassDumper-Database-Backup-\(Date().fileBackupString()).sqlite"
        ) { result in
            handleExportResult(result)
        }
    }

    private func getDatabaseURL() -> URL? {
        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory, in: .userDomainMask,
                appropriateFor: nil, create: true
            )
            let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)
            let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
            return databaseURL
        } catch {
            return nil
        }
    }

    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case let .success(urls):
            guard let url = urls.first else { return }

            var didStartAccessing = false
            if url.startAccessingSecurityScopedResource() {
                didStartAccessing = true
            }
            defer {
                if didStartAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            do {
                let fileManager = FileManager.default
                let appSupportURL = try fileManager.url(
                    for: .applicationSupportDirectory, in: .userDomainMask,
                    appropriateFor: nil, create: true
                )
                let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)
                let databaseURL = directoryURL.appendingPathComponent("db.sqlite")

                FileRepository.shared.close()
                
                Thread.sleep(forTimeInterval: 0.1)
                
                let baseURL = databaseURL.deletingPathExtension()
                let extensions = ["", "-wal", "-shm", "-journal"]
                for ext in extensions {
                    let fileURL = baseURL.appendingPathExtension(ext.isEmpty ? "sqlite" : "sqlite\(ext)")
                    if fileManager.fileExists(atPath: fileURL.path) {
                        try? fileManager.removeItem(at: fileURL)
                    }
                }

                try fileManager.copyItem(at: url, to: databaseURL)

                let tempDbPool = try DatabasePool(path: databaseURL.path)
                _ = try tempDbPool.read { db in
                    let tables = try String.fetchAll(db, sql: "SELECT name FROM sqlite_master WHERE type='table'")

                    if tables.contains("file") {
                        _ = try String.fetchOne(db, sql: "SELECT sql FROM sqlite_master WHERE name='file'") ?? ""
                        _ = try String.fetchAll(db, sql: "SELECT name FROM file LIMIT 3")
                        return try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM file") ?? 0
                    } else {
                        print("No 'file' table found in imported database")
                        return 0
                    }
                }

                try tempDbPool.close()

                FileRepository.recreateConnectionWithoutMigration()

                try FileRepository.shared.checkpoint()

                NotificationCenter.default.post(name: .databaseImportedNotification, object: nil)

                alertTitle = "Import Successful"
                alertMessage = "Database has been imported successfully."
                showingAlert = true

            } catch {
                alertTitle = "Import Failed"
                alertMessage = "Failed to import database: \(error.localizedDescription)"
                showingAlert = true
            }

        case let .failure(error):
            alertTitle = "Import Failed"
            alertMessage = "Failed to import database: \(error.localizedDescription)"
            showingAlert = true
        }
    }

    private func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case let .success(url):
            do {
                if let databaseURL = getDatabaseURL(),
                   FileManager.default.fileExists(atPath: databaseURL.path)
                {
                    try FileRepository.shared.checkpoint()

                    let tempExportURL = databaseURL.appendingPathExtension("export_temp")

                    try FileRepository.shared.vacuumInto(path: tempExportURL.path)

                    let databaseData = try Data(contentsOf: tempExportURL)
                    
                    try? FileManager.default.removeItem(at: tempExportURL)

                    try databaseData.write(to: url)

                    alertTitle = "Export Successful"
                    alertMessage = "Database has been exported successfully."
                } else {
                    alertTitle = "Export Failed"
                    alertMessage = "No database found to export."
                }
            } catch {
                alertTitle = "Export Failed"
                alertMessage = "Failed to export database: \(error.localizedDescription)"
            }
            showingAlert = true

        case let .failure(error):
            alertTitle = "Export Failed"
            alertMessage = "Failed to export database: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// Helper struct for file export
struct DatabaseDocument: FileDocument {
    static var readableContentTypes: [UTType] { [UTType(filenameExtension: "sqlite")!] }

    init() {}

    init(configuration _: ReadConfiguration) throws {}

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: Data())
    }
}

extension Date {
    func fileBackupString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd-HH_mm_ss"
        return formatter.string(from: self)
    }
}
