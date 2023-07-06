import SwiftUI
import CodeEditor

struct Keys {
    static let UITesting = "--uitesting"
}

let savedOutputDirectoryBase = URL.documentsDirectory
let savedOutputDirectory = NSApplication.bundleName.removeSpaces()
let outputDirectory = savedOutputDirectoryBase.appendingPathComponent(savedOutputDirectory)

struct Preferences {
    enum Defaults {
        // error dialogs
        static var verboseErrors = false
        static var dialogLength = 1000

        // source code viewer
        static var themeName: CodeEditor.ThemeName = .default
        static var fontSize: Int = Int(NSFont.systemFontSize)
    }
}
