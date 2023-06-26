import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general
    }
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
        }
        .padding(20)
        .frame(width: 375, height: 150)
    }
}

struct GeneralSettingsView: View {
    var body: some View {
        Form {
            Section {
                DeleteFilesButton("Delete all data", afterWithPrompt: {
                    // noop, deletion with prompting is handled in the button
                    // but side effects may be placed here if desired.
                })
            }
        }
        .padding(20)
    }
}
