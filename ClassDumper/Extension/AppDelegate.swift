import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_: Notification) {
        if CommandLine.arguments.contains(Keys.UITesting) {
            resetState()
        }

        func resetState() {
            UserDefaults.standard.removePersistentDomain(forName: PlistKey.Identifier.rawValue)
        }
    }
}
