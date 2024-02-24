import Files
import SwiftUI
import GRDB
import GRDBQuery
import OrderedCollections

typealias FolderRowResponse = OrderedDictionary<String, Int>

struct FolderRowRequest: Queryable {
    static var defaultValue: FolderRowResponse { FolderRowResponse() }
    
    func publisher(in fileRepository: FileRepository) -> DatabasePublishers.Value<FolderRowResponse> {
        return ValueObservation.tracking { db in
            let results = try File
                .order(Column("folder"))
                .fetchAll(db)
                .map { ($0.folder, 1) }

            return OrderedDictionary(results, uniquingKeysWith: +)
        }
        .publisher(in: fileRepository.reader, scheduling: .immediate)
    }
}

extension AppView {
    
    struct FolderRowView: View {
        @Query(FolderRowRequest())
        var folderRows: FolderRowResponse

        var deletionEnabled: Bool
        
        @ViewBuilder
        func Row(for folderName: String, badge: Int) -> some View {
            Label {
                NavigationLink(destination: FileRowView(selectedFolder: folderName)) {
                    Text(folderName)
                }
            } icon: {
                Image(systemName: "folder")
                    .foregroundColor(.accentColor)
            }
            .badge(badge)
        }
        
        var body: some View {
            List(Array(folderRows), id:\.key) { folder, count in
                HStack {
                    Row(for: folder, badge: count)
                        .accessibilityIdentifier(Keys.Sidebar.Row)
                        .contextMenu {
                           DeleteFilesButton("Delete", folderKey: folder)
                        }

                    if deletionEnabled {
                            DeleteFilesButton("", folderKey: folder)
                                .foregroundColor(.red)
                                .buttonStyle(BorderlessButtonStyle())
                                .labelStyle(IconOnlyLabelStyle())
                        }
                    }
            }
            .animation(.default, value: folderRows)
            .listStyle(SidebarListStyle())
            .accessibilityIdentifier(Keys.Sidebar.List)
        }
    }
}
