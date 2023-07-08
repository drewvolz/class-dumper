import XCTest

struct Sidebar: Screen {
    let app: XCUIApplication

    enum Shortcut: String {
        case filepicker = "o"
        case settings = ","
    }

    var list: XCUIElement {
        app.outlines[Keys.Sidebar.List]
    }

    func checkListExists() -> Self {
        XCTAssert(list.waitForExistence(timeout: 5))
        return self
    }

    func checkListDoesNotExist() -> Self {
        XCTAssertFalse(list.exists)
        return self
    }
    
    func resetState() -> Self {
        open(.settings)

        app.windows.buttons["General"].tap()

        app.windows.buttons["Delete all saved data"].tap()

        app.windows.buttons["Delete"].tap()

        return self
    }

    fileprivate func open(_ shortcut: Shortcut) {
        app.typeKey(shortcut.rawValue, modifierFlags: .command)
    }

    func openApp(named appName: String) -> Self {
        open(.filepicker)

        app.sheets.firstMatch.outlineRows.staticTexts["Applications"].tap()

        // taking advantage of finder directing keyboard input towards the middle column
        app.typeText(appName)
        app.typeKey(.return, modifierFlags: [])

        return self
    }

    @discardableResult
    func checkFirstResult(contains text: String) -> Self {
        let row = list.buttons.matching(identifier: Keys.Sidebar.Row)

        XCTAssertTrue(row.element.label == text)

        row.firstMatch.tap()

        return self
    }
}
