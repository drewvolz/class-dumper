import SwiftUI
import CodeEditor

let savedOutputDirectoryBase = URL.documents
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

        // scoped search view
        static var scopedSearch = Preferences.FilterScope.default
        
        // drag and drop import
        static var confirmBeforeImport = false
    }
}


extension Preferences {
    struct FilterScope: TypedString {
        public let rawValue : String

        @inlinable
        public init(rawValue: String) { self.rawValue = rawValue }

        static var `default` = Preferences.FilterScope(rawValue: "scoped")
        static var all  = Preferences.FilterScope(rawValue: "all")

        static var allCases: [FilterScope] {
            return [.default, .all]
        }
    }
}
