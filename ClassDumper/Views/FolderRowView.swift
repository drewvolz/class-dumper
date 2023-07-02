import Files
import SwiftUI
import GRDB
import GRDBQuery

typealias FolderRowResponse = Dictionary<String?, Int>

struct FolderRowRequest: Queryable {
    static var defaultValue: FolderRowResponse { FolderRowResponse() }
    
    func publisher(in fileRepository: FileRepository) -> DatabasePublishers.Value<FolderRowResponse> {
        return ValueObservation.tracking { db in
            let results = try File
                .order(Column("folder"))
                .fetchAll(db)
                .map { ($0.folder, 1) }

            // TODO: Dictionary doesn't preserve order, need to implement an alternative
            // which could be done with a direct SQL call to improve a few aspects:
            // 1. Not fetching the whole database just to get an aggregate of folder names and counts
            // 2. Delivering results sorted by grdb
            return Dictionary(results, uniquingKeysWith: +)
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
        func DeleteButton(for folderName: String) -> some View {
            if deletionEnabled {
                DeleteFilesButton("", folderKey: folderName)
            }
        }
        
        @ViewBuilder
        func Row(for folderName: String, badge: Int) -> some View {
            Label {
                NavigationLink(destination: FileRowView()) {
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
                    if let folderName = folder {
                        Row(for: folderName, badge: count)
                        DeleteButton(for: folderName)
                    }
                }
            }
            .listStyle(SidebarListStyle())
        }
    }
}
