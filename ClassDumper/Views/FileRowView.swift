import Files
import SwiftUI
import GRDB
import GRDBQuery

typealias FileRowResponse = [(String?, String?, String?)]

struct FileRowRequest: Queryable {
    static var defaultValue: FileRowResponse { FileRowResponse() }

    func publisher(in fileRepository: FileRepository) -> DatabasePublishers.Value<FileRowResponse> {
        return ValueObservation.tracking { db in
            let results = try File
                .order(Column("name").ascNullsLast)
//                .filter(Column("folder") == "")
                .fetchAll(db)
                .map { ($0.folder, $0.name, $0.contents) }

            return results
        }
        .publisher(in: fileRepository.reader, scheduling: .immediate)
    }
}

struct FileRowView: View {
    @Query(FileRowRequest())
    var fileRows: FileRowResponse
    var selectedFolder: String
    
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
    
    var body: some View {
        List(fileRows, id:\.1) { folderName, fileName, content in
            if let name = fileName, folderName == selectedFolder {
                NavigationLink(destination: DetailView(fileContents: content ?? "")) {
                    Label {
                        Text(name)
                    } icon: {
                        Image(systemName: "doc")
                            .symbolVariant(.fill)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }
}

