import Foundation
import GRDB
import os.log

/// A repository of files.
///
/// You create a `FileRepository` with a
/// [connection to an SQLite database](https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections),
/// created with a configuration returned from
/// ``makeConfiguration(_:)``.
///
/// For example:
///
/// ```swift
/// // Create an in-memory FileRepository
/// let config = FileRepository.makeConfiguration()
/// let dbQueue = try DatabaseQueue(configuration: config)
/// let repository = try FileRepository(dbQueue)
/// ```
///
/// ## Topics
///
/// ### Creating a repository
///
/// - ``init(_:)``
/// - ``makeConfiguration(_:)``
///
/// ### Performing read-only accesses
///
/// - ``reader``
///
/// ### Performing writes
///
/// - ``deleteAllFiles()``
/// - ``insert(_:)``
/// - ``update(_:)``
public struct FileRepository {
    /// Creates a `FileRepository`, and makes sure the database schema
    /// is ready.
    ///
    /// - important: Create the `DatabaseWriter` with a configuration
    ///   returned by ``makeConfiguration(_:)``.
    public init(_ dbWriter: some GRDB.DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    /// Provides access to the database.
    ///
    /// Application can use a `DatabasePool`, while SwiftUI previews and tests
    /// can use a fast in-memory `DatabaseQueue`.
    ///
    /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>
    private let dbWriter: any DatabaseWriter
    
    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
#if DEBUG
        // Speed up development by nuking the database when migrations change
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations#The-eraseDatabaseOnSchemaChange-Option>
        migrator.eraseDatabaseOnSchemaChange = true
#endif

        migrator.registerMigration("createFile") { db in
            // Create a table
            // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseschema>
            try db.create(table: "file") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("folder", .text).notNull()
                t.column("contents", .text)
            }

            // create a unique index to force records to be unique by both file name and folder name
            try db.create(index: "byFolder", on: "file", columns: ["name", "folder"], unique: true)
        }
        
        // Migrations for future application versions will be inserted here:
        // migrator.registerMigration(...) { db in
        //     ...
        // }
        
        return migrator
    }
}

// MARK: - Database Configuration

extension FileRepository {
    private static let sqlLogger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "SQL")
    
    /// Returns a database configuration suited for `FileRepository`.
    ///
    /// SQL statements are logged if the `SQL_TRACE` environment variable
    /// is set.
    ///
    /// - parameter base: A base configuration.
    public static func makeConfiguration(_ base: Configuration = Configuration()) -> Configuration {
        var config = base
        
        // An opportunity to add required custom SQL functions or
        // collations, if needed:
        // config.prepareDatabase { db in
        //     db.add(function: ...)
        // }
        
        // Log SQL statements if the `SQL_TRACE` environment variable is set.
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/database/trace(options:_:)>
        if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
            config.prepareDatabase { db in
                db.trace {
                    // It's ok to log statements publicly. Sensitive
                    // information (statement arguments) are not logged
                    // unless config.publicStatementArguments is set
                    // (see below).
                    os_log("%{public}@", log: sqlLogger, type: .debug, String(describing: $0))
                }
            }
        }
        
#if DEBUG
        // Protect sensitive information by enabling verbose debugging in
        // DEBUG builds only.
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/configuration/publicstatementarguments>
        config.publicStatementArguments = true
#endif
        
        return config
    }
}

// MARK: - Database Access: Writes
// The write methods execute invariant-preserving database transactions.
// In this demo repository, they are pretty simple.

extension FileRepository {
    /// Inserts a file and returns the inserted file.
    public func insertOne(_ file: File) throws -> File {
        try dbWriter.write { db in
            return try file.inserted(db)
        }
    }
    
    /// Updates the file.
    public func update(_ file: File) throws {
        try dbWriter.write { db in
            try file.update(db)
        }
    }

    
    /// Deletes all files.
    public func deleteAllFiles() throws {
        try dbWriter.write { db in
            _ = try File.deleteAll(db)
        }
    }
}

// MARK: - Database Access: Reads

// This demo app does not provide any specific reading method, and instead
// gives an unrestricted read-only access to the rest of the application.
// In your app, you are free to choose another path, and define focused
// reading methods.
extension FileRepository {
    /// Provides a read-only access to the database.
    public var reader: any GRDB.DatabaseReader {
        dbWriter
    }
}
