import GRDB

// Equatable for testability
/// A file.
public struct File: Codable, Equatable {
    private(set) public var id: Int64?
    public var name: String?
    public var folder: String?
    public var contents: String?

    public init(
        id: Int64? = nil,
        name: String?,
        folder: String?,
        contents: String?)
    {
        self.id = id
        self.name = name
        self.folder = folder
        self.contents = contents
    }
}

extension File: FetchableRecord, MutablePersistableRecord {
    public static let persistenceConflictPolicy = PersistenceConflictPolicy(insert: .replace, update: .replace)

    // Update auto-incremented id upon successful insertion
    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
