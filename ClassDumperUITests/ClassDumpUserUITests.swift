import XCTest

protocol Screen {
    var app: XCUIApplication { get }
}

final class ClassDumperUITests: UITestCase {
    // TODO: CI: copy the embedded class-dump executable as the test file
    let testDump = "class-dump"

    func testSidebar() {
        Sidebar(app: app)
            .resetState()
            .checkListDoesNotExist()
            .openApp(named: testDump)
            .checkListExists()
            .checkFirstResult(contains: testDump)
    }
}
