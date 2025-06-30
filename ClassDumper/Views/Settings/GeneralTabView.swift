import SwiftUI
import CodeEditor

struct GeneralSettingsView: View {
    @AppStorage("accent") var accent = CodableColor(.accentColor)
    @AppStorage("codeViewerTheme") var theme: CodeEditor.ThemeName = Preferences.Defaults.themeName
    @AppStorage("codeViewerFontSize") var fontSize: Int = Preferences.Defaults.fontSize
    @AppStorage("confirmBeforeImport") var confirmBeforeImport: Bool = Preferences.Defaults.confirmBeforeImport

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            AccentColor()
            ThemePicker()
            FontSizePicker()
            ResetDataButton()
            ImportSettings()
        }
    }
}

extension GeneralSettingsView {
    
    @ViewBuilder
    func AccentColor() -> some View {
        LazyHGrid(rows: [GridItem(.flexible(minimum: 30, maximum: .infinity))], alignment: .top, spacing: 1) {
            ForEach(accents) { option in
                Button {
                    accent = option.color
                } label: {
                    VStack {
                        Circle()
                            .fill(option.color.toColor())
                            .frame(width: 15, height: 15)
                            .padding(5)
                            .accessibilityIdentifier("\(Keys.Settings.AccentColorButton)-\(option.name)")
                            .overlay(content: {
                                if accent == option.color {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 6, height: 6, alignment: .center)
                                        .accessibilityLabel("Selected accent color")
                                }
                            })

                        Text(accent == option.color ? option.name : "")
                            .frame(minHeight: 5)
                            .fixedSize(horizontal: true, vertical: false)
                            .frame(width: 35)
                            .focusable(false)
                            .accessibilityLabel(option.name)
                    }
                    .tag(option.id)
                }
                .buttonStyle(.plain)
            }
        }
        .modifier(PreferencesTabViewModifier(sectionTitle: "Accent color"))
    }

    @ViewBuilder
    func ThemePicker() -> some View {
        Picker("", selection: $theme) {
            ForEach(CodeEditor.availableThemes) { theme in
                Text("\(theme.rawValue.capitalized)")
                    .tag(theme)
            }
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .fixedSize()
        .tint(accent.toColor())
        .modifier(PreferencesTabViewModifier(sectionTitle: "Code theme"))
    }
    
    @ViewBuilder
    func FontSizePicker() -> some View {
        Stepper(value: $fontSize, in: 1...1000) {
            TextField("", text: $fontSize.toTextFieldLabel)
                .labelsHidden()
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .frame(minWidth: 55, maxWidth: 85)
                .fixedSize()
        }
        .tint(accent.toColor())
        .modifier(PreferencesTabViewModifier(sectionTitle: "Font size"))
    }
    
    @ViewBuilder
    func ResetDataButton() -> some View {
        DeleteFilesButton("Delete all saved data", afterWithPrompt: {
            // noop, deletion with prompting is handled in the button
            // but side effects may be placed here if desired.
        })
        .modifier(PreferencesTabViewModifier(sectionTitle: "Database"))
    }
    
    @ViewBuilder
    func ImportSettings() -> some View {
        Toggle("Confirm before importing files", isOn: $confirmBeforeImport)
        .modifier(PreferencesTabViewModifier(sectionTitle: "Import"))
    }
}
