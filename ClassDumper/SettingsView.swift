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
    @EnvironmentObject var alertController: AlertController

    var body: some View {
        Form {
            Section {
                Button(action: {
                    alertController.info = AlertInfo(
                        id: .settingsDeleteSavedDataPrompt,
                        title: "Are you sure you want to delete the saved data?",
                        message: "There is no undoing this action.",
                        primaryButtonMessage: "Delete",
                        primaryButtonAction: {
                            try? deleteSavedData()
                        }
                    )
                }, label: {
                    Text("Delete all data")
                })
            }
        }
        .padding(20)
    }
}

extension GeneralSettingsView {
    func deleteSavedData() throws {
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: outputDirectory.relativePath))
            NotificationCenter.default.post(name: .resetContentNotification, object: nil)
        } catch {
            print("There was an error when trying to delete the saved data.")
        }
    }
}
