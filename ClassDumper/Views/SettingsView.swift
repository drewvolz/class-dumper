import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general
        case debug
    }

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            
            DebugSettingsView()
                .tabItem {
                    Label("Debug", systemImage: "ladybug")
                }
                .tag(Tabs.debug)
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

struct DebugSettingsView: View {

    var body: some View {
        Form {
        }
        .padding(20)
    }
}
