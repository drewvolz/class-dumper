import SwiftUI

struct Keys {
    static let UITesting = "--uitesting"
}

let savedOutputDirectoryBase = URL.documentsDirectory
let savedOutputDirectory = NSApplication.bundleName.removeSpaces()
let outputDirectory = savedOutputDirectoryBase.appendingPathComponent(savedOutputDirectory)

struct Preferences {
    enum Defaults {
        static var verboseErrors = false
        static var dialogLength = 1000
    }
}
