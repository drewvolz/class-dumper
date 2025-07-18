import SwiftUI

struct DebugSettingsView: View {
    @AppStorage("enableVerboseImportErrorLogging") var enableVerboseImportErrorLogging = Preferences.Defaults.verboseErrors
    @AppStorage("dialogLengthImportErrorLogging") var dialogLengthImportErrorLogging = Preferences.Defaults.dialogLength
    @AppStorage("accent") var accent = CodableColor(.accentColor)

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
        VStack(alignment: .leading, spacing: 20) {
            Toggle("Show unfiltered error dialog messages", isOn: $enableVerboseImportErrorLogging)
                .help(helpLogging)

            HStack {
                // TODO: Ideally we could use a singular `TextField` for both disabled states of input (see "disabled" and "value")
                if !$enableVerboseImportErrorLogging.wrappedValue {
                    TextField(defaultCharacterLengthFormatted, value: $dialogLengthImportErrorLogging, format: .number)
                        .modifier(ErrorLengthViewModifier())
                } else {
                    TextField(defaultCharacterLengthFormatted, value: .constant(Preferences.Defaults.dialogLength), format: .number)
                        .modifier(ErrorLengthViewModifier())
                        .disabled(true)
                }

                /**
                 * We'd like to use `Morphology` and `Morphology.GrammaticalNumber` here to take advantage of inflection
                 * rules for `.zero`, `.singular`, and `.plural` but that would return both the morphed string and the count
                 * that we inflected on e.g. "1 character" or "1,000 characters". Because we are displaying the control next to the output,
                 * we do not want that duplicated. It's not suitable to write our own grammar, coerce the output into an array of characters,
                 * split by whitespace, and return the last component (the changed input).
                 */
                Text("\(dialogLengthImportErrorLogging == 1 ? "character" : "characters") in the message")
            }
            .help(helpErrorLength)
        }
        .tint(accent.toColor())
        .modifier(PreferencesTabViewModifier(sectionTitle: "Errors"))
    }
}

extension DebugSettingsView {
    struct ErrorLengthViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.trailing)
                .frame(minWidth: 55, maxWidth: 85)
                .fixedSize()
        }
    }
}
