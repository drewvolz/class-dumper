import SwiftUI

struct Keys {
    static let UITesting = "--uitesting"
}

let savedOutputDirectoryBase = URL.documentsDirectory
let savedOutputDirectory = NSApplication.bundleName.removeSpaces()
let outputDirectory = savedOutputDirectoryBase.appendingPathComponent(savedOutputDirectory)
