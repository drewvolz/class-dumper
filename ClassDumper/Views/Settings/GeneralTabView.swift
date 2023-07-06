import SwiftUI
import CodeEditor

struct GeneralSettingsView: View {
    @AppStorage("codeViewerTheme") var theme: CodeEditor.ThemeName = Preferences.Defaults.themeName

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
                
                DeleteFilesButton("Delete all saved data", afterWithPrompt: {
                    // noop, deletion with prompting is handled in the button
                    // but side effects may be placed here if desired.
                })
                .modifier(PreferencesTabViewModifier(sectionTitle: "Database"))
        }
    }
}
