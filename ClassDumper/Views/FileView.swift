import Players
import SwiftUI

struct FileView: View {
    @Environment(\.redactionReasons) var redactionReasons

    var player: Player
    var editAction: (() -> Void)?
    
    var body: some View {
        HStack {
            avatar()
            
            VStack(alignment: .leading) {
                Text(player.name).bold().font(.title3)
                Text("Score: \(player.score)")
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
                AsyncImage(
                    url: URL(string: "https://picsum.photos/seed/\(player.photoID)/200"),
                    content: { image in
                        image.resizable()
                    },
                    placeholder: {
                        Color(.systemGray)
                    })
//            } else {
//                Color(uiColor: .white)
//            }
        }
        .frame(width: 70, height: 70)
        .cornerRadius(10)
    }
}

struct FileView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            FileView(player: .makeRandom(), editAction: { })
            FileView(player: .placeholder).redacted(reason: .placeholder)
        }
        .padding()
    }
}
