import GRDBQuery
import SwiftUI

@main
struct ClassDumperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var alertController = AlertController()
    @AppStorage("accent") var accent = CodableColor(.accentColor)
    @State private var databaseVersion = 0

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(\.fileRepository, .shared)
                .environmentObject(alertController)
                .alert(item: $alertController.info) { info in
                   buildAlert(info)
                }
                .onReceive(NotificationCenter.default.publisher(for: .databaseImportedNotification)) { _ in
                    databaseVersion += 1
                }
                .id(databaseVersion)
        }
        .commands {
            // overwritten and custom commands
            MenuCommands(alertController: alertController)
            // provides font size
            TextFormattingCommands()
        }

        #if os(macOS)
            Settings {
                SettingsView()
                    .environment(\.fileRepository, .shared)
                    .environmentObject(alertController)
                    .onReceive(NotificationCenter.default.publisher(for: .databaseImportedNotification)) { _ in
                        databaseVersion += 1
                    }
                    .id(databaseVersion)
            }
        #endif
    }
}
