import GRDBQuery
import SwiftUI

@main
struct ClassDumperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var alertController = AlertController()
    @AppStorage("accent") var accent = CodableColor(.accentColor)

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(\.fileRepository, .shared)
                .environmentObject(alertController)
                .alert(item: $alertController.info) { info in
                   buildAlert(info)
                }
        }
        .commands {
            // overwritten and custom commands
            MenuCommands()
            // provides font size
            TextFormattingCommands()
        }

        #if os(macOS)
        Settings {
           SettingsView()
                .environment(\.fileRepository, .shared)
                .environmentObject(alertController)
        }
        #endif
    }
}
