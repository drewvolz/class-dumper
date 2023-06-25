import Files
import SwiftUI

struct FileView: View {
    @Environment(\.redactionReasons) var redactionReasons

    var file: File
    var editAction: (() -> Void)?
    
    var body: some View {
        HStack {
            Label {
                Text(file.name)
            } icon: {
                Image(systemName: "doc")
                    .foregroundColor(.accentColor)
            }
            
            if let editAction {
                Button("Edit", action: editAction)
            }
        }
    }
}

struct FileView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            FileView(file: .makeRandom(), editAction: { })
            FileView(file: .placeholder).redacted(reason: .placeholder)
        }
        .padding()
    }
}
