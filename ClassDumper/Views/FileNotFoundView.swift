import SwiftUI

/// The view that is displayed when a file can not be found.
struct FileNotFoundView: View {
    var body: some View {
        ZStack {
            Color(.systemGray).ignoresSafeArea()
            VStack {
                Spacer()
                Text("404").font(Font.system(size: 64)).fontWeight(.heavy)
                Text("😵").font(Font.system(size: 100))
                Spacer()
                Spacer()
                Spacer()
            }.padding()
        }
    }
}

struct FileNotFoundView_Previews: PreviewProvider {
    static var previews: some View {
        FileNotFoundView()
    }
}
