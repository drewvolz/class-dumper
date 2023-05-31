import SwiftUI

struct MenuCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            AppInfo()
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
}
