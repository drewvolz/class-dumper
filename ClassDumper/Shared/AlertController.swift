import SwiftUI

typealias Action = () -> ()?
var closure: (() -> Void) = {}

struct AlertInfo: Identifiable {
    enum AlertType {
        case settingsDeleteSavedDataPrompt
        case settingsDeleteSavedDataError
    }

    init(id: AlertType,
         title: String,
         message: String,
         primaryButtonMessage: String = "",
         primaryButtonAction: @escaping Action = closure) {
       self.id = id
       self.title = title
       self.message = message
       self.primaryButtonMessage = primaryButtonMessage
       self.primaryButtonAction = primaryButtonAction
    }

    let id: AlertType
    let title: String
    let message: String
    let primaryButtonMessage: String
    let primaryButtonAction: () -> Void?
}

class AlertController: ObservableObject {
    @Published var info: AlertInfo?
}
