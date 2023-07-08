import XCTest

class UITestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments.append(Keys.UITesting)
        app.launch()
    }
}
