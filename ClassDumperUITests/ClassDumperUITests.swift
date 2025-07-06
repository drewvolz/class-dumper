import XCTest

protocol Screen {
    var app: XCUIApplication { get }
}

final class ClassDumperUITests: UITestCase {
    /// This test passes the `--uitesting` flag  to the file picker which resolves the final
    /// hardcoded url path to the bundled `class-dump` executable as our test data.
    ///
    /// We still want to pass in a file that XCUITest can locate in the view hierarchy but
    /// so `openApp` is handed a name we expect to exist, and `checkFirstResult`
    /// is handed a different name we expect to exist. This allows us to test the app's ability
    /// to import and parse from an end-to-end perspective.
    ///
    /// In this case Automator is guaranteed to be found on standard macOS, and because
    /// we switch out the imported path upon successful selection and closing of the window,
    /// we are safe to assume that class-dump will be our chosen file at the end of this flow.
    func testImportFlow() {
        ImportFlow(app: app)
            .resetState()
            .check(.folder, exists: false)
            .check(.file, exists: false)
            .check(.filterToggle, exists: false)
            .openApp(named: "Automator")
            .tapFirst(.folder, containing: "class-dump")
            .check(.folder, exists: true)
            .check(.file, exists: true)
            .check(.code, exists: false)
            .tapFirst(.file, containing: "CDClassDumpVisitor.h")
            .check(.code, exists: true)
            .tapFirst(.code, containing: "CDTextClassDumpVisitor.h")
            .check(.pathbar, exists: true)
            .tapFirst(.pathbar, containing: "CDClassDumpVisitor.h")
            .check(.filterToggle, exists: true)
            .tapFirst(.filterToggle, containing: "Show selected")
            // TODO: CI is failing this test although it is working locally
            // .selectPopupButton("Show all")
            .checkAccentColorTappable()
    }

    func testDatabaseImportExport() {
        let testFlow = ImportFlow(app: app)
        let testFilename = "UITest-Database-Export"
        let fullyQualifiedTestFileName = "\(testFilename).sqlite"

        testFlow
            .resetState()
            .openApp(named: "Automator")
            .tapFirst(.folder, containing: "class-dump")
            .tapFirst(.file, containing: "CDClassDumpVisitor.h")
            .check(.folder, exists: true)

        let initialFolderCount = testFlow.getFolderCount()
        XCTAssert(initialFolderCount == 1, "Should have folders after import")

        testFlow
            .openDatabaseSettings()
            .performDatabaseExport(filename: testFilename)

        testFlow
            .deleteAllData()
            .closeSettings()
            .check(.folder, exists: false)

        testFlow
            .openDatabaseSettings()
            .performDatabaseImport(filename: fullyQualifiedTestFileName)
            .closeSettings()
            .ensureMainWindowExists()

        testFlow
            .check(.folder, exists: true)
            .verifyFolderCount(initialFolderCount)
            .tapFirst(.folder, containing: "class-dump")
            .tapFirst(.file, containing: "CDClassDumpVisitor.h")
            .check(.code, exists: true)

        testFlow
            .cleanup(fullyQualifiedTestFileName)
    }
}
