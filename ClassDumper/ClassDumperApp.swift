import GRDBQuery
import SwiftUI

@main
struct ClassDumperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var alertController = AlertController()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(\.fileRepository, .shared)
                .environmentObject(alertController)
                .alert(item: $alertController.info, content: { info in
                    Alert(title: Text(info.title),
                          message: Text(info.message.truncate(length: 1000)),
                          primaryButton: .destructive(Text(info.primaryButtonMessage)) {
                            info.primaryButtonAction()
                          },
                          secondaryButton: .cancel()
                    )
                })
        }
        .commands {
            MenuCommands()
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
