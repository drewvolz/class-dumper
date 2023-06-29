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

extension App {
    func buildAlert(_ info: AlertInfo) -> Alert {
        let messageText = Text(info.message.truncate(length: 1000))
        let primaryButtonText = Text(info.primaryButtonMessage)

        let primaryButton: Alert.Button = {
            switch info.level {
            case .message: return .default(primaryButtonText)
            case .warning: return .destructive(primaryButtonText)
            }
        }()

        return Alert(
            title: Text(info.title),
            message: messageText,
            primaryButton: primaryButton,
            secondaryButton: .cancel()
        )
    }
}
