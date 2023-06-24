import Foundation
import GRDB
import Files

// A `FileRepository` extension for creating various repositories for the
// app, tests, and previews.
extension FileRepository {
    /// The on-disk repository for the application.
    static let shared = makeShared()
    
    /// Returns an on-disk repository for the application.
    private static func makeShared() -> FileRepository {
        do {
            // Apply recommendations from
            // <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>
            //
            // Create the "Application Support/Database" directory if needed
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory, in: .userDomainMask,
                appropriateFor: nil, create: true)
            let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

            // Open or create the database
            let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
            NSLog("Database stored at \(databaseURL.path)")
            let dbPool = try DatabasePool(
                path: databaseURL.path,
                // Use default FileRepository configuration
                configuration: FileRepository.makeConfiguration())

            // Create the FileRepository
            let fileRepository = try FileRepository(dbPool)
            
            return fileRepository
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //
            // Typical reasons for an error here include:
            // * The parent directory cannot be created, or disallows writing.
            // * The database is not accessible, due to permissions or data protection when the device is locked.
            // * The device is out of space.
            // * The database could not be migrated to its latest schema version.
            // Check the error message to determine what the actual problem was.
            fatalError("Unresolved error \(error)")
        }
    }
    
    /// Returns an empty in-memory repository, for previews and tests.
    static func empty() -> FileRepository {
        try! FileRepository(DatabaseQueue(configuration: FileRepository.makeConfiguration()))
    }
    
    /// Returns an in-memory repository that contains one file,
    /// for previews and tests.
    ///
    /// - parameter fileId: The ID of the inserted file.
    static func populated(fileId: Int64? = nil) -> FileRepository {
        let repo = self.empty()
        _ = try! repo.insert(File.makeRandom(id: fileId))
        return repo
    }
}
