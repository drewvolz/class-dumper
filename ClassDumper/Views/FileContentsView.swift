import SwiftUI
import CodeEditor

struct DetailView: View {
    @AppStorage("codeViewerTheme") var theme: CodeEditor.ThemeName = Preferences.Defaults.themeName
    @AppStorage("fontsize") var fontSize = Int(NSFont.systemFontSize)

    var fileContents: String

    var body: some View {
        CodeEditor(source: fileContents,
                   language: .objectivec,
                   theme: theme,
                   fontSize: .init(get: { CGFloat(fontSize)  },
                                   set: { fontSize = Int($0) }),
                   flags: [.defaultViewerFlags])
    }
}
