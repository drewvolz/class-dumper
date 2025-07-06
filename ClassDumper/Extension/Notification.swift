import Foundation

enum NotificationName: String {
    case FolderSelectedFromFinderNotification
    case DatabaseImportedNotification
}

extension Notification.Name {
    static let folderSelectedFromFinderNotification = Notification.Name(NotificationName.FolderSelectedFromFinderNotification.rawValue)
    static let databaseImportedNotification = Notification.Name(NotificationName.DatabaseImportedNotification.rawValue)
}
