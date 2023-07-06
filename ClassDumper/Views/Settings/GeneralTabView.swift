import SwiftUI
import CodeEditor

struct GeneralSettingsView: View {
    @AppStorage("codeViewerTheme") var theme: CodeEditor.ThemeName = Preferences.Defaults.themeName
    @AppStorage("codeViewerFontSize") var fontSize: Int = Preferences.Defaults.fontSize

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                Picker("", selection: $theme) {
                    ForEach(CodeEditor.availableThemes) { theme in
                        Text("\(theme.rawValue.capitalized)")
                            .tag(theme)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .fixedSize()
                .modifier(PreferencesTabViewModifier(sectionTitle: "Code theme"))

                Stepper(value: $fontSize, in: 1...1000) {
                    TextField("", text: $fontSize.toTextFieldLabel)
                        .labelsHidden()
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 55, maxWidth: 85)
                        .fixedSize()
                }
                .modifier(PreferencesTabViewModifier(sectionTitle: "Font size"))

                DeleteFilesButton("Delete all saved data", afterWithPrompt: {
                    // noop, deletion with prompting is handled in the button
                    // but side effects may be placed here if desired.
                })
                .modifier(PreferencesTabViewModifier(sectionTitle: "Database"))
        }
    }
}
