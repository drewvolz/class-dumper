import Foundation

enum NotificationName: String {
    case FolderSelectedFromFinderNotification
}

extension Notification.Name {
    static let folderSelectedFromFinderNotification = Notification.Name(NotificationName.FolderSelectedFromFinderNotification.rawValue)
}
