import SwiftUI

extension Binding where Value == Int {
    var toTextFieldLabel: Binding<String> {
        Binding<String>(
            get: {
                wrappedValue.formatted()
            },
            set: {
                if let value = Int($0) {
                    wrappedValue = value
                }
            }
        )
    }
}
