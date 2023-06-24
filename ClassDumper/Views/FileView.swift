import Files
import SwiftUI

struct FileView: View {
    @Environment(\.redactionReasons) var redactionReasons

    var file: File
    var editAction: (() -> Void)?
    
    var body: some View {
        HStack {
            avatar()
            
            VStack(alignment: .leading) {
                Text(file.name).bold().font(.title3)
                Text("Name: \(file.name)")
            }
            
            Spacer()
            
            if let editAction {
                Button("Edit", action: editAction)
            }
        }
    }
    
    func avatar() -> some View {
        Group {
//            if redactionReasons.isEmpty {
//                AsyncImage(
//                    url: URL(string: "https://picsum.photos/seed/\(file.photoID)/200"),
//                    content: { image in
//                        image.resizable()
//                    },
//                    placeholder: {
//                        Color(.systemGray)
//                    })
//            } else {
            Color(.white)
//            }
        }
        .frame(width: 70, height: 70)
        .cornerRadius(10)
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
