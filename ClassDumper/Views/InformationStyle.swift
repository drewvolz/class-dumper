import SwiftUI

/// The style for information text
struct InformationStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.accentColor)
            .font(.callout)
    }
}

/// The style for information boxes
struct InformationBox: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color.accentColor.opacity(0.07))
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .cornerRadius(10)
    }
}

extension View {
    func informationStyle() -> some View {
        modifier(InformationStyle())
    }
    
    func informationBox() -> some View {
        modifier(InformationBox())
    }
}

struct Information_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Info 1")
                .informationStyle()
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque et.")
                .informationStyle()
            Button("OK") { }
        }
        .informationBox()
        .padding()
    }
}
