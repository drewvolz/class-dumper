import SwiftUI

struct FilePathView: View {
    var folderName: String
    var fileName: String

    var body: some View {
        Group {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.accentColor)
                    Text(folderName)
                }

                Image(systemName: "chevron.right")
                    .imageScale(.small)

                HStack(spacing: 4) {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.accentColor)
                    Text(fileName)
                }
            }
                .truncationMode(.middle)
                .lineLimit(1)
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
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
