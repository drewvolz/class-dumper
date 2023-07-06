import SwiftUI

func DetailView(fileContents: String) -> some View {
    Group{
        ZStack {
            TextEditor(text: .constant(fileContents))
                .padding(8)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(Color(NSColor.labelColor))
        }
        .background(Color(NSColor.textBackgroundColor))
    }
}
