import XCTest

struct ImportFlow: Screen {
    let app: XCUIApplication

    enum Shortcut: String {
        case filepicker = "o"
        case settings = ","
    }

    enum Section {
        case navbar
        case content
        case detail
    }

    enum Component {
        case folder
        case file
        case code
    }

    struct TestComponent {
        var id: String
        var rowId: String
        var section: Section
        var component: XCUIElement
    }

    var folderlist: TestComponent {
        TestComponent(id: Keys.Sidebar.List,
                      rowId: Keys.Sidebar.Row,
                      section: .navbar,
                      component: app.outlines[Keys.Sidebar.List])
    }

    var filelist: TestComponent {
        TestComponent(id: Keys.Middle.List,
                      rowId: Keys.Middle.Row,
                      section: .content,
                      component: app.tables[Keys.Middle.List])
    }

    var codeviewer: TestComponent {
        TestComponent(id: Keys.Detail.CodeViewer,
                      rowId: "",
                      section: .detail,
                      component: app.scrollViews[Keys.Detail.CodeViewer])
    }

    func getComponent(for element: Component) -> TestComponent {
        switch element {
        case .folder:
            return folderlist
        case .file:
            return filelist
        case .code:
            return codeviewer
        }
    }

    func check(_ element: Component, exists: Bool) -> Self {
        let forElement = getComponent(for: element)

        if exists {
            XCTAssert(forElement.component.waitForExistence(timeout: 5))
        } else {
            XCTAssertFalse(forElement.component.exists)
        }

        return self
    }

    func tapFirst(_ element: Component, containing: String) -> Self {
        let forElement = getComponent(for: element)

        tapFirstRow(label: containing,
                    parent: forElement.component,
                    target: forElement.section,
                    rowId: forElement.rowId)

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
    private func tapFirstRow(
        label: String,
        parent: XCUIElement,
        target: Section,
        rowId: String)
    -> Self {
        var row: XCUIElementQuery

        switch target {
        case .navbar:
            row = parent.buttons.matching(identifier: rowId)
            XCTAssertTrue(row.element.label == label)
            row[label].tap()
            break
        case .content:
            row = parent.buttons.matching(identifier: rowId)
            XCTAssertTrue(row[label].label == label)
            row[label].tap()
            break
        case .detail:
            row = parent.textViews
            guard let found = row.firstMatch.value as? String else {
                fatalError("Could not tap or locate: {label:\(label), parent:\(parent), target: \(target), row: \(rowId)")
            }
            XCTAssertTrue(found.contains(label))
            row.firstMatch.tap()
            break
        }
        
        return self
    }
}
