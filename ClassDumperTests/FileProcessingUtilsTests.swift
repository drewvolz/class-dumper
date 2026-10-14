@testable import Class_Dumper
import XCTest

final class FileProcessingUtilsTests: XCTestCase {
    private var scratchDirectory: URL!

    override func setUpWithError() throws {
        scratchDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("FileProcessingUtilsTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: scratchDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: scratchDirectory)
    }

    func testExecuteCommandThrowsWhenExecutableCannotLaunch() throws {
        let notAnExecutable = scratchDirectory.appendingPathComponent("not-an-executable")
        try Data("plain text".utf8).write(to: notAnExecutable)

        XCTAssertThrowsError(try FileProcessingUtils.executeCommand(executableURL: notAnExecutable, args: []))
    }

    func testBundledClassDumpRunsOnThisArchitecture() throws {
        let classDump = try XCTUnwrap(Bundle.main.url(forResource: "class-dump", withExtension: ""))

        let standardError = try FileProcessingUtils.executeCommand(
            executableURL: classDump,
            args: ["/bin/ls", "-t", "-H", "-o", scratchDirectory.path]
        )

        XCTAssertEqual(
            standardError,
            "Warning: This file does not contain any Objective-C runtime information: \(scratchDirectory.lastPathComponent)\n"
        )
    }
}
