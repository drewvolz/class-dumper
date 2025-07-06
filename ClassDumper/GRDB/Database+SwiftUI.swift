import Files
import GRDBQuery
import SwiftUI

// MARK: - Give SwiftUI access to the file repository

// Define a new environment key that grants access to a `FileRepository`.
//
// The technique is documented at
// <https://developer.apple.com/documentation/swiftui/environmentkey>.
private struct FileRepositoryKey: EnvironmentKey {
    /// The default appDatabase is an empty in-memory repository.
    static let defaultValue = FileRepository.empty()
}

extension EnvironmentValues {
    var fileRepository: FileRepository {
        get { self[FileRepositoryKey.self] }
        set { self[FileRepositoryKey.self] = newValue }
    }
}

// MARK: - @Query convenience

// Help views and previews observe the database with the @Query property wrapper.
// See <https://swiftpackageindex.com/groue/grdbquery/documentation/grdbquery/gettingstarted>
extension Query where Request.DatabaseContext == FileRepository {
    /// Creates a `Query`, given an initial `Queryable` request that
    /// uses `FileRepository` as a `DatabaseContext`.
    init(_ request: Request) {
        self.init(request, in: \.fileRepository)
    }
}
