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
    
    @State private var searchText = ""
    
    private var filteredFileNames: Array<(Optional<String>, Optional<String>, Optional<String>)> {
        if searchText.isEmpty {
            return fileRows
        } else {
            return fileRows.filter { $0.1?.forSearch().contains(searchText.forSearch()) ?? false }
        }
    }
    
    var body: some View {
        List(filteredFileNames, id:\.1) { folderName, fileName, content in
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
        .searchable(text: $searchText, prompt: "Search files")
    }
}

