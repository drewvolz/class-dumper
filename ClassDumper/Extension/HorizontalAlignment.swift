import SwiftUI

/// Alignment guide for aligning a text field in a `Form`.
/// Credit to Jim Dovey  https://developer.apple.com/forums/thread/126268
extension HorizontalAlignment {
    private enum ControlAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[HorizontalAlignment.center]
        }
    }
    
    static let controlAlignment = HorizontalAlignment(ControlAlignment.self)
}

public extension View {
    /// Attaches a label to this view for laying out in a `Form`
    /// - Parameter view: the label view to use
    /// - Returns: an `HStack` with an alignment guide for placing in a form
    func formLabel<V: View>(_ view: V) -> some View {
        HStack {
            view
            self.alignmentGuide(.controlAlignment) { $0[.leading] }
        }
        .alignmentGuide(.leading) { $0[.controlAlignment] }

    }
}
