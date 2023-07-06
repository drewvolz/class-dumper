import XCTest
import GRDB
import Files

final class FileRepositoryTests: XCTestCase {
    func testInsert() throws {
        // Given a properly configured and empty in-memory repo
        let dbQueue = try DatabaseQueue(configuration: FileRepository.makeConfiguration())
        let repo = try FileRepository(dbQueue)
        
        // When we insert a file
        let insertedFile = try repo.insert(File(name: "Arthur", folder: "test", contents: "123"))
        
        // Then the inserted file has an id
        XCTAssertNotNil(insertedFile.id)
        
        // Then the inserted file exists in the database
        let fetchedFile = try XCTUnwrap(repo.reader.read(File.fetchOne))
        XCTAssertEqual(fetchedFile, insertedFile)
    }
    
    func testUpdate() throws {
        // Given a properly configured in-memory repo that contains a file
        let dbQueue = try DatabaseQueue(configuration: FileRepository.makeConfiguration())
        let repo = try FileRepository(dbQueue)
        let insertedFile = try repo.insert(File(name: "Arthur", folder: "test", contents: "123"))

        // When we update a file
        var updatedFile = insertedFile
        updatedFile.name = "Barbara"
        updatedFile.folder = "test2"
        updatedFile.contents = "234"
        try repo.update(updatedFile)
        
        // Then the file is updated
        let fetchedFile = try XCTUnwrap(repo.reader.read(File.fetchOne))
        XCTAssertEqual(fetchedFile, updatedFile)
    }
    
    func test() throws {
        // Given a properly configured in-memory repo that contains a file
        let dbQueue = try DatabaseQueue(configuration: FileRepository.makeConfiguration())
        let repo = try FileRepository(dbQueue)
        _ = try repo.insert(File(name: "Arthur", folder: "test", contents: "123"))

        // When we delete all files
        try repo.deleteAllFiles()
        
        // Then no file exists
        let count = try repo.reader.read(File.fetchCount(_:))
        XCTAssertEqual(count, 0)
    }
}
