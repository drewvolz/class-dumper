import SwiftUI

struct MenuCommands: Commands {
    @SwiftUI.Environment(\.openURL) var openURL: OpenURLAction
    @ObservedObject var alertController: AlertController

    init(alertController: AlertController) {
        _alertController = ObservedObject(wrappedValue: alertController)
    }

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            AppInfo()
        }

        CommandGroup(replacing: .help) {
            HelpSection()
        }

        CommandGroup(after: .printItem) {
            CreateFileButton().environmentObject(alertController)
            FindSection()
        }
    }
}

extension MenuCommands {
    func AppInfo() -> some View {
        Button("About \(NSApplication.bundleName)") {
            NSApplication.shared.orderFrontStandardAboutPanel(
                options: [
                    NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                        string: "A GUI around the command-line class-dump utility for examining Objective-C runtime information stored in Mach-O files.",
                        attributes: [
                            NSAttributedString.Key.font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular),
                        ]
                    ),
                    NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© 2023 Drew Volz",
                ]
            )
        }
    }

    func HelpSection() -> some View {
        Group {
            Button("Github repo") {
                if let githubUrl = URL(string: Endpoint.githubBaseUrl) {
                    openURL(githubUrl)
                }
            }

            Divider()

            Button("Report a bug") {
                let issueEndpoint: Endpoint = .issue(.Bug)
                if let issueUrl: URL = issueEndpoint.url {
                    openURL(issueUrl)
                }
            }

            Button("Request a new feature") {
                let featureEndpoint: Endpoint = .issue(.Feature)
                if let featureUrl: URL = featureEndpoint.url {
                    openURL(featureUrl)
                }
            }
        }
    }

    /// Questionable workaround for getting the find shortcut to trigger the searchfield on macOS
    func FindSection() -> some View {
        Button("Find") {
            if let toolbar = NSApp.keyWindow?.toolbar,
               let search = toolbar.items.first(where: { $0.itemIdentifier.rawValue == "com.apple.SwiftUI.search" }) as? NSSearchToolbarItem
            {
                search.beginSearchInteraction()
            }
        }.keyboardShortcut("f", modifiers: .command)
    }
}
