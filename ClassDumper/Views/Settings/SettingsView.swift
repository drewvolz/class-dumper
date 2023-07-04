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
        .frame(width: 500, alignment: .leading)
    }
}
