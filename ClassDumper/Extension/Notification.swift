import Foundation

enum NotificationName: String {
    case NewFilesAddedNotification
    case DirectoryDeletedNotification
    case ResetContentNotification
}

extension Notification.Name {
    static let newFilesAddedNotification = Notification.Name(NotificationName.NewFilesAddedNotification.rawValue)
    static let directoryDeletedNotification = Notification.Name(NotificationName.DirectoryDeletedNotification.rawValue)
    static let resetContentNotification = Notification.Name(NotificationName.ResetContentNotification.rawValue)
}
