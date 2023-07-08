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
            .check(.folderlist, exists: false)
            .check(.filelist, exists: false)
            .openApp(named: "Automator")
            .tapFirstFolder(containing: "class-dump")
            .check(.folderlist, exists: true)
            .check(.filelist, exists: true)
            .check(.codeviewer, exists: false)
            .tapFirstFile(containing: "CDClassDumpVisitor.h")
            .check(.codeviewer, exists: true)
            .checkFirstLine(containing: "CDTextClassDumpVisitor.h")
    }
}
