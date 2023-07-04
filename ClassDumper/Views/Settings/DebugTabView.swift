import SwiftUI

struct DebugSettingsView: View {
    @AppStorage("enableVerboseImportErrorLogging") var enableVerboseImportErrorLogging = Preferences.Defaults.verboseErrors
    @AppStorage("dialogLengthImportErrorLogging") var dialogLengthImportErrorLogging = Preferences.Defaults.dialogLength

    let helpLogging = """
This setting could be useful if you need to see the original message.

Enabling this will show the original error message without truncation \
or removal of text, but depending on length, it could present a dialog \
that extends beyond the screen height.

Note that enabling this will disable the error length preference.
"""

    let helpErrorLength = """
Represents the max message length shown in an error dialog. \
The current output is truncated to so this may be useful to override \
if you need a different length.

Note that verbose error dialogs will disable this setting.
"""

    let defaultCharacterLengthFormatted = String(Preferences.Defaults.dialogLength.formatted())

    var body: some View {
        Group {
            Toggle("Show unfiltered error dialog messages", isOn: $enableVerboseImportErrorLogging)
                .help(helpLogging)

            HStack {
                if !$enableVerboseImportErrorLogging.wrappedValue {
                    TextField(defaultCharacterLengthFormatted, value: $dialogLengthImportErrorLogging, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .fixedSize()
                } else {
                    TextField(defaultCharacterLengthFormatted, value: .constant(Preferences.Defaults.dialogLength), format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .fixedSize()
                    .disabled(true)
                }

                Text("characters in the shown message")
            }
            .help(helpErrorLength)
        }
        .modifier(PreferencesTabViewModifier(sectionTitle: "Errors"))
    }
}
