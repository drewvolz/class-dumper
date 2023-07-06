import SwiftUI
import CodeEditor

struct DetailView: View {
    @AppStorage("codeViewerTheme") var theme: CodeEditor.ThemeName = Preferences.Defaults.themeName
    @AppStorage("codeViewerFontSize") var fontSize: Int = Preferences.Defaults.fontSize

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
