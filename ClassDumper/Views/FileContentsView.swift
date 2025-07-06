import CodeEditor
import SwiftUI

struct DetailView: View {
    @AppStorage("codeViewerTheme") var theme: CodeEditor.ThemeName = Preferences.Defaults.themeName
    @AppStorage("codeViewerFontSize") var fontSize: Int = Preferences.Defaults.fontSize

    var fileContents: String
    var folderName: String
    var fileName: String

    var body: some View {
        CodeEditor(source: fileContents,
                   language: .objectivec,
                   theme: theme,
                   fontSize: .init(get: { CGFloat(fontSize) },
                                   set: { fontSize = Int($0) }),
                   flags: [.defaultViewerFlags])
            .accessibilityIdentifier(Keys.Detail.CodeViewer)

        FilePathView(folderName: folderName, fileName: fileName)
    }
}

#Preview {
    DetailView(fileContents: "File contents", folderName: "TestApp", fileName: "TestFile.Swift")
}
