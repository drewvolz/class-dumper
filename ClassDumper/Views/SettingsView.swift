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

    let helpLogging = """
Provides the original error message without truncation or removal \
of log text. Please note that enabling this could present a dialog \
that extends beyond the screen height.

Note that this settings will disable the error length.

This setting could be useful if you need to see the original message.
"""
    
    let helpErrorLength = """
Represents the length of the error to output in a dialog from the CLI. \
The current output is truncated to so this may be useful to override \
if you need a different length.

Note that verbose error dialogs will disable this setting.
"""

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $enableVerboseImportErrorLogging) {}
                .toggleStyle(CheckboxToggleStyle())
                .formLabel(Text("Verbose error dialogs"))
                .help(helpLogging)

                TextField("", value: $dialogLengthImportErrorLogging, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .formLabel(Text("Error length"))
                    .help(helpErrorLength)
                    .disabled($enableVerboseImportErrorLogging.wrappedValue)
            }
        }
        .padding(20)
    }
}
