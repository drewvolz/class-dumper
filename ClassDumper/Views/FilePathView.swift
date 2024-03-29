import SwiftUI

struct FilePathView: View {
    @AppStorage("accent") var accent = CodableColor(.accentColor)

    var folderName: String
    var fileName: String

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "folder.fill")
                        .foregroundColor(accent.toColor())
                    Text(folderName)
                }

                Image(systemName: "chevron.right")
                    .imageScale(.small)

                HStack(spacing: 4) {
                    Image(systemName: "doc.fill")
                        .foregroundColor(accent.toColor())
                    Text(fileName)
                        .accessibilityIdentifier(Keys.Detail.PathBarFile)
                }
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier(Keys.Detail.PathBar)
    }
}

#Preview {
    FilePathView(folderName: "Test App", fileName: "TestFile.swift")
}

#Preview {
    FilePathView(
        folderName: "Test App",
        fileName: "TestFileWithReallyLongNameThatShouldTruncateInTheMiddleIfItGetsLongerThanExpected.swift"
    )
}
