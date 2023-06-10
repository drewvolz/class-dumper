import SwiftUI

struct MenuCommands: Commands {
    @SwiftUI.Environment(\.openURL) var openURL: OpenURLAction

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            AppInfo()
        }

        CommandGroup(replacing: .help) {
            HelpSection()
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
                            NSAttributedString.Key.font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
                        ]
                    ),
                    NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© 2023 Drew Volz"
                ]
            )
        }
    }

    func HelpSection() -> some View {
        Group {
            Button("Github Repo") {
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
}
