import SwiftUI

enum PlistKey: String {
    case Build = "CFBundleVersion"
    case Name = "CFBundleName"
    case Identifier = "CFBundleIdentifier"
    case Version = "CFBundleShortVersionString"
}

extension NSApplication {
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: PlistKey.Version.rawValue) as? String ?? ""
    }
    
    static var buildNumber: String {
        return Bundle.main.object(forInfoDictionaryKey: PlistKey.Build.rawValue) as? String ?? ""
    }

    static var bundleName: String {
        return Bundle.main.object(forInfoDictionaryKey: PlistKey.Name.rawValue) as? String ?? ""
    }

    static var bundleIdentifier: String {
        return Bundle.main.object(forInfoDictionaryKey: PlistKey.Identifier.rawValue) as? String ?? ""
    }
}
