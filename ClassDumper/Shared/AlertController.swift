import SwiftUI

typealias Action = () -> ()?
var closure: (() -> Void) = {}

struct AlertInfo: Identifiable {
    enum AlertType {
        case importNoObjcRuntimeInformation
        case settingsDeleteSavedDataPrompt
        case settingsDeleteSavedDataError
    }

    enum AlertLevel {
        case message
        case warning
    }

    init(id: AlertType,
         title: String,
         message: String,
         level: AlertLevel,
         primaryButtonMessage: String = "",
         primaryButtonAction: @escaping Action = closure
    ) {
       self.id = id
       self.title = title
       self.message = message
       self.level = level
       self.primaryButtonMessage = primaryButtonMessage
       self.primaryButtonAction = primaryButtonAction
    }

    let id: AlertType
    let title: String
    let level: AlertLevel
    let message: String
    let primaryButtonMessage: String
    let primaryButtonAction: () -> Void?
}

class AlertController: ObservableObject {
    @Published var info: AlertInfo?
}
