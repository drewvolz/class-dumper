import XCTest

struct ImportFlow: Screen {
    let app: XCUIApplication

    enum Shortcut: String {
        case filepicker = "o"
        case settings = ","
    }

    private enum FocusField {
        case navbar
        case content
        case detail
    }

    enum Component {
        case folderlist
        case filelist
        case codeviewer
    }

    var folderList: XCUIElement {
        app.outlines[Keys.Sidebar.List]
    }

    var fileList: XCUIElement {
        app.tables[Keys.Middle.List]
    }
    
    var codeViewer: XCUIElement {
        app.scrollViews[Keys.Detail.CodeViewer]
    }
    
    func check(_ element: Component, exists: Bool) -> Self {
        var forElement: XCUIElement

        switch element {
        case .folderlist:
            forElement = folderList
        case .filelist:
            forElement = fileList
        case .codeviewer:
            forElement = codeViewer
        }

        if exists {
            XCTAssert(forElement.waitForExistence(timeout: 5))
        } else {
            XCTAssertFalse(forElement.exists)
        }

        return self
    }

    func tapFirstFolder(containing: String) -> Self {
        tapFirstRow(label: containing,
                    parent: folderList,
                    target: .navbar,
                    identifier: Keys.Sidebar.Row)
        return self
    }

    func tapFirstFile(containing: String) -> Self {
        tapFirstRow(label: containing,
                    parent: fileList,
                    target: .content,
                    identifier: Keys.Middle.Row)
        return self
    }

    @discardableResult
    func checkFirstLine(containing: String) -> Self {
        tapFirstRow(label: containing,
                    parent: codeViewer,
                    target: .detail,
                    identifier: Keys.Detail.CodeViewer)
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
    private func tapFirstRow(
        label: String,
        parent: XCUIElement,
        target: FocusField,
        identifier: String)
    -> Self {
        var row: XCUIElementQuery

        switch target {
        case .navbar:
            row = parent.buttons.matching(identifier: identifier)
            XCTAssertTrue(row.element.label == label)
            row.firstMatch.tap()
            break
        case .content:
            row = parent.buttons.matching(identifier: identifier)
            row[label].tap()
            break
        case .detail:
            row = parent.textViews
            guard let found = row.firstMatch.value as? String else {
                fatalError("Could not tap or locate: {label:\(label), parent:\(parent)")
            }
            XCTAssertTrue(found.contains(label))
            row.firstMatch.tap()
            break
        }
        
        return self
    }
}
