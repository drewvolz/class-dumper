import SwiftUI

extension App {
    func buildAlert(_ info: AlertInfo) -> Alert {
        let messageText = Text(info.message)

        let primaryButton: Alert.Button = {
            let primaryButtonText = Text(info.primaryButtonMessage)

            switch info.level {
            case .message: return .default(primaryButtonText) {
                info.primaryButtonAction()
            }
            case .warning: return .destructive(primaryButtonText) {
                info.primaryButtonAction()
            }
            }
        }()

        if info.level == .message {
            return Alert(
                title: Text(info.title),
                message: messageText,
                dismissButton: primaryButton
            )
        }

        return Alert(
            title: Text(info.title),
            message: messageText,
            primaryButton: primaryButton,
            secondaryButton: .cancel()
        )
    }
}
