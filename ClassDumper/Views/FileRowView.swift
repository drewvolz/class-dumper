import Files
import GRDB
import GRDBQuery
import SwiftUI

typealias FileRowResponse = [(Int64?, String, String, String)]

struct FileRowRequest: Queryable {
    static var defaultValue: FileRowResponse { FileRowResponse() }

    func publisher(in fileRepository: FileRepository) -> DatabasePublishers.Value<FileRowResponse> {
        return ValueObservation.tracking { db in
            let results = try File
                .order(Column("name").ascNullsLast)
//                .filter(Column("folder") == "")
                .fetchAll(db)
                .map { ($0.id, $0.folder, $0.name, $0.contents) }

            return results
        }
        .publisher(in: fileRepository.reader, scheduling: .immediate)
    }
}

struct FileRowView: View {
    @AppStorage("scopedSearchPreference") var scopedSearchPreference = Preferences.Defaults.scopedSearch
    @AppStorage("accent") var accent = CodableColor(.accentColor)

    // query to fetch all data
    @Query(FileRowRequest())
    var allFileRows: FileRowResponse

    // filtering the active directory
    var filteredFileRows: FileRowResponse {
        allFileRows.filter { $0.1 == selectedFolder }
    }

    // data to render based upon scoped preference
    var fileRows: FileRowResponse {
        scopedSearchPreference == .all ? allFileRows : filteredFileRows
    }

    var selectedFolder: String

    @State private var searchText = ""

    private var filteredFileNames: FileRowResponse {
        if searchText.isEmpty {
            return fileRows
        } else {
            return fileRows.filter { item in
                let filename = item.2
                return filename.forSearch().contains(searchText.forSearch())
            }
        }
    }

    var body: some View {
        List(filteredFileNames, id: \.0) { _, folderName, fileName, content in
            NavigationLink(destination: DetailView(fileContents: content, folderName: folderName, fileName: fileName)) {
                Label {
                    Text(fileName)
                        .truncationMode(.middle)
                        .lineLimit(1)
                } icon: {
                    Image(systemName: "doc")
                        .symbolVariant(.fill)
                        .foregroundColor(accent.toColor())
                }
            }
            .accessibilityIdentifier(Keys.Middle.Row)
            .help(scopedSearchPreference == .all ? folderName : "")
        }
        .accessibilityIdentifier(Keys.Middle.List)
        .searchable(text: $searchText, prompt: "Search files")
    }
}
