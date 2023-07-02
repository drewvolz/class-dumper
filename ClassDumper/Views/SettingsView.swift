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
    @AppStorage("enableVerboseImportErrorLogging") var enableVerboseImportErrorLogging = false
    @AppStorage("dialogLengthImportErrorLogging") var dialogLengthImportErrorLogging = 1000

    let helpErrorLength = """
Represents the length of the error to output in a dialog from the CLI. \
The current output is truncated to so this may be useful to override \
if you need a different length.

Note that verbose error dialogs will disable this setting.
"""

    var body: some View {
        Form {
            Section(header: Text("Error dialogs")) {
                Toggle(isOn: $enableVerboseImportErrorLogging) {
                    Text("Enable verbose import error messages")
                }
                .toggleStyle(CheckboxToggleStyle())

                LabeledContent {
                    TextField("", value: $dialogLengthImportErrorLogging, format: .number)
                        .disabled($enableVerboseImportErrorLogging.wrappedValue)
                } label: {
                    Text("Error length")
                }
                .help(helpErrorLength)
            }
        }
        .padding(20)
    }
}
