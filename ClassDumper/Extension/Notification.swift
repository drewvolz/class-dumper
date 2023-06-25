import Foundation

enum NotificationName: String {
    case FolderSelectedFromFinderNotification
    case DirectoryDeletedNotification
    case ResetContentNotification
}

extension Notification.Name {
    static let folderSelectedFromFinderNotification = Notification.Name(NotificationName.FolderSelectedFromFinderNotification.rawValue)
    static let directoryDeletedNotification = Notification.Name(NotificationName.DirectoryDeletedNotification.rawValue)
    static let resetContentNotification = Notification.Name(NotificationName.ResetContentNotification.rawValue)
}
