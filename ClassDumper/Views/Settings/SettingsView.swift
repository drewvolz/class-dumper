import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general
        case database
        case debug
    }

    var body: some View {
        @AppStorage("accent") var accent = CodableColor(.accentColor)

        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)

            DatabaseSettingsView()
                .tabItem {
                    Label("Database", systemImage: "externaldrive")
                }
                .tag(Tabs.database)

            DebugSettingsView()
                .tabItem {
                    Label("Debug", systemImage: "ladybug")
                }
                .tag(Tabs.debug)
        }
        .tint(accent.toColor())
        .padding(20)
        .frame(width: 500, alignment: .leading)
    }
}
