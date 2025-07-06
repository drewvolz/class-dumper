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
        case filter
    }

    enum Component {
        case folder
        case file
        case code
        case pathbar
        case filterToggle
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
                      component: app.outlines[Keys.Middle.List])
    }

    var codeviewer: TestComponent {
        TestComponent(id: Keys.Detail.CodeViewer,
                      rowId: "",
                      section: .detail,
                      component: app.scrollViews[Keys.Detail.CodeViewer])
    }

    var pathbar: TestComponent {
        TestComponent(id: Keys.Detail.PathBar,
                      rowId: "",
                      section: .detail,
                      component: app.scrollViews[Keys.Detail.PathBar])
    }

    var filterToggle: TestComponent {
        TestComponent(id: Keys.Filters.FilterFiles,
                      rowId: "",
                      section: .filter,
                      component: app.popUpButtons[Keys.Filters.FilterFiles])
    }

    func getComponent(for element: Component) -> TestComponent {
        switch element {
        case .folder:
            return folderlist
        case .file:
            return filelist
        case .code:
            return codeviewer
        case .pathbar:
            return pathbar
        case .filterToggle:
            return filterToggle
        }
    }

    @discardableResult
    func check(_ element: Component, exists: Bool) -> Self {
        let forElement = getComponent(for: element)

        if exists {
            XCTAssert(forElement.component.waitForExistence(timeout: 5))
        } else {
            XCTAssertFalse(forElement.component.exists)
        }

        return self
    }

    @discardableResult
    func tapFirst(_ element: Component, containing: String) -> Self {
        let forElement = getComponent(for: element)

        tapFirstRow(element,
                    label: containing,
                    parent: forElement.component,
                    target: forElement.section,
                    rowId: forElement.rowId)

        return self
    }

    @discardableResult
    func selectPopupButton(_ containing: String) -> Self {
        let firstPredicate = NSPredicate(format: "title BEGINSWITH '\(containing)'")
        let desiredOption = filterToggle.component.menuItems.element(matching: firstPredicate)
        desiredOption.tap()

        return self
    }

    func resetState() -> Self {
        open(.settings)

        app.windows.buttons["Database"].tap()

        let deleteButton = app.windows.buttons["Delete all saved data"]
        if deleteButton.exists {
            deleteButton.tap()
            app.windows.buttons["Delete"].tap()
        }

        return self
    }

    @discardableResult
    func openDatabaseSettings() -> Self {
        open(.settings)
        app.windows.buttons["Database"].tap()
        return self
    }

    @discardableResult
    func testDatabaseExport() -> Self {
        let exportButton = app.windows.buttons["Export Database"]
        XCTAssert(exportButton.exists)
        XCTAssert(exportButton.isEnabled)

        exportButton.tap()

        // Verify file save dialog appears
        XCTAssert(app.sheets.firstMatch.waitForExistence(timeout: 3))

        // Cancel for test purposes
        app.sheets.firstMatch.buttons["Cancel"].tap()

        return self
    }

    @discardableResult
    func testDatabaseImport() -> Self {
        let importButton = app.windows.buttons["Import Database"]
        XCTAssert(importButton.exists)
        XCTAssert(importButton.isEnabled)

        importButton.tap()

        // Verify file open dialog appears
        XCTAssert(app.sheets.firstMatch.waitForExistence(timeout: 3))

        // Cancel for test purposes
        app.sheets.firstMatch.buttons["Cancel"].tap()

        return self
    }

    @discardableResult
    func performDatabaseExport(filename: String = "UITest-Database-Export.sqlite") -> Self {
        let exportButton = app.windows.buttons["Export Database"]
        XCTAssert(exportButton.exists && exportButton.isEnabled)
        exportButton.tap()

        XCTAssert(app.sheets.firstMatch.waitForExistence(timeout: 3))

        let desktopButton = app.sheets.firstMatch.popUpButtons.firstMatch
        desktopButton.tap()
        app.sheets.firstMatch.menuItems["Downloads"].tap()

        let filenameField = app.sheets.firstMatch.textFields.firstMatch
        filenameField.typeText(filename)

        app.sheets.firstMatch.buttons["Export"].tap()

        // Handle file replacement dialog if it appears
        if app.sheets.firstMatch.staticTexts.containing(NSPredicate(format: "label CONTAINS 'already exists'")).firstMatch.waitForExistence(timeout: 2) {
            // File already exists, click Replace
            if app.sheets.firstMatch.buttons["Replace"].exists {
                app.sheets.firstMatch.buttons["Replace"].tap()
            }
        }

        // Wait for save sheet to disappear first (with timeout)
        var sheetWaitCount = 0
        while app.sheets.firstMatch.exists && sheetWaitCount < 10 {
            Thread.sleep(forTimeInterval: 0.5)
            sheetWaitCount += 1
        }

        // Wait briefly and dismiss any success alert that appears
        Thread.sleep(forTimeInterval: 1.0) // Give UI time to show success feedback

        // Try different types of modal dialogs (SwiftUI can present these differently)
        if app.alerts.firstMatch.exists && app.alerts.firstMatch.buttons["OK"].exists {
            app.alerts.firstMatch.buttons["OK"].tap()
        } else if app.dialogs.firstMatch.exists && app.dialogs.firstMatch.buttons["OK"].exists {
            app.dialogs.firstMatch.buttons["OK"].tap()
        } else if app.sheets.firstMatch.exists && app.sheets.firstMatch.buttons["OK"].exists {
            app.sheets.firstMatch.buttons["OK"].tap()
        }

        return self
    }

    @discardableResult
    func performDatabaseImport(filename: String = "UITest-Database-Export.sqlite") -> Self {
        let importButton = app.windows.buttons["Import Database"]
        XCTAssert(importButton.exists && importButton.isEnabled)
        importButton.tap()

        XCTAssert(app.sheets.firstMatch.waitForExistence(timeout: 2))

        let openDownloadsButton = app.sheets.firstMatch.popUpButtons.firstMatch
        openDownloadsButton.tap()
        app.sheets.firstMatch.menuItems["Downloads"].tap()

        // Taking advantage of finder directing keyboard input towards the file list
        app.typeText(filename)
        app.typeKey(.return, modifierFlags: [])

        // Continue with the rest of the import flow only if we successfully found and opened the file

        // Wait for open sheet to disappear first (with timeout)
        var openSheetWaitCount = 0
        while app.sheets.firstMatch.exists && openSheetWaitCount < 10 {
            Thread.sleep(forTimeInterval: 0.5)
            openSheetWaitCount += 1
        }

        // Wait briefly and dismiss any success alert that appears
        Thread.sleep(forTimeInterval: 1.0) // Give UI time to show success feedback

        // Try different types of modal dialogs (SwiftUI can present these differently)
        if app.alerts.firstMatch.exists && app.alerts.firstMatch.buttons["OK"].exists {
            app.alerts.firstMatch.buttons["OK"].tap()
            // Wait for alert to fully dismiss
            while app.alerts.firstMatch.exists {
                Thread.sleep(forTimeInterval: 0.1)
            }
        } else if app.dialogs.firstMatch.exists && app.dialogs.firstMatch.buttons["OK"].exists {
            app.dialogs.firstMatch.buttons["OK"].tap()
            // Wait for dialog to fully dismiss
            while app.dialogs.firstMatch.exists {
                Thread.sleep(forTimeInterval: 0.1)
            }
        } else if app.sheets.firstMatch.exists && app.sheets.firstMatch.buttons["OK"].exists {
            app.sheets.firstMatch.buttons["OK"].tap()
            // Wait for sheet to fully dismiss
            while app.sheets.firstMatch.exists {
                Thread.sleep(forTimeInterval: 0.1)
            }
        }

        return self
    }

    @discardableResult
    func deleteAllData() -> Self {
        // Dismiss any lingering success alert from previous operation
        if app.alerts.firstMatch.exists && app.alerts.firstMatch.buttons["OK"].exists {
            app.alerts.firstMatch.buttons["OK"].tap()
            Thread.sleep(forTimeInterval: 0.5) // Wait for alert to dismiss
        } else if app.dialogs.firstMatch.exists && app.dialogs.firstMatch.buttons["OK"].exists {
            app.dialogs.firstMatch.buttons["OK"].tap()
            Thread.sleep(forTimeInterval: 0.5) // Wait for dialog to dismiss
        } else if app.sheets.firstMatch.exists && app.sheets.firstMatch.buttons["OK"].exists {
            app.sheets.firstMatch.buttons["OK"].tap()
            Thread.sleep(forTimeInterval: 0.5) // Wait for sheet to dismiss
        }

        let deleteButton = app.windows.buttons["Delete all saved data"]
        if deleteButton.exists && deleteButton.isHittable {
            deleteButton.tap()

            // Wait for confirmation dialog and confirm deletion
            if app.windows.buttons["Delete"].waitForExistence(timeout: 3) {
                app.windows.buttons["Delete"].tap()
            }
        }
        return self
    }

    @discardableResult
    func closeSettings() -> Self {
        // Be more specific about closing the settings window
        if app.windows["Class Dumper Settings"].exists {
            app.windows["Class Dumper Settings"].buttons[XCUIIdentifierCloseWindow].tap()
        } else if app.sheets.firstMatch.exists {
            // If settings is presented as a sheet, dismiss it
            app.typeKey(.escape, modifierFlags: [])
        } else {
            // Fallback to Command+W but only if we're sure we have a settings context
            app.typeKey("w", modifierFlags: .command)
        }
        return self
    }

    @discardableResult
    func ensureMainWindowExists() -> Self {
        // If no main window exists, create a new one
        if !app.windows.element(matching: .window, identifier: "*").firstMatch.exists {
            // Fallback to Command+n, to guarantee _a_ window is visible
            app.typeKey("n", modifierFlags: .command)
        }
        return self
    }

    @discardableResult
    func verifyFolderCount(_ expectedCount: Int) -> Self {
        let actualCount = getFolderCount()
        XCTAssertEqual(actualCount, expectedCount, "Folder count should match expected")
        return self
    }

    @discardableResult
    func getFolderCount() -> Int {
        return folderlist.component.children(matching: .outlineRow).count
    }

    @discardableResult
    func checkAccentColorTappable() -> Self {
        open(.settings)

        app.windows.buttons["General"].tap()

        let blueAccentButton = app.buttons["\(Keys.Settings.AccentColorButton)-Blue"]
        XCTAssert(blueAccentButton.exists)
        blueAccentButton.tap()

        return self
    }

    fileprivate func open(_ shortcut: Shortcut) {
        app.typeKey(shortcut.rawValue, modifierFlags: .command)
    }

    func openApp(named appName: String) -> Self {
        open(.filepicker)

        app.dialogs.firstMatch.outlineRows.staticTexts["Applications"].tap()

        // taking advantage of finder directing keyboard input towards the middle column
        app.typeText(appName)
        app.typeKey(.return, modifierFlags: [])

        return self
    }

    @discardableResult
    private func tapFirstRow(
        _ component: Component,
        label: String,
        parent: XCUIElement,
        target: Section,
        rowId: String
    )
        -> Self
    {
        var row: XCUIElementQuery

        switch target {
        case .navbar:
            row = parent.buttons.matching(identifier: rowId)
            XCTAssertTrue(row.element.label == label)
            row[label].tap()
        case .content:
            row = parent.buttons.matching(identifier: rowId)
            XCTAssertTrue(row[label].label == label)
            row[label].tap()
        case .detail:
            row = parent.textViews

            if component == .pathbar {
                row = parent.staticTexts.matching(identifier: Keys.Detail.PathBarFile)
            }

            guard let found = row.firstMatch.value as? String else {
                fatalError("Could not tap or locate: {label:\(label), parent:\(parent), target: \(target), row: \(rowId)")
            }
            XCTAssertTrue(found.contains(label))
            row.firstMatch.tap()
        case .filter:
            row = app.popUpButtons
            XCTAssertTrue(row[Keys.Filters.FilterFiles].value as? String == label)
            row.firstMatch.tap()
        }

        return self
    }

    func cleanup(_ testFilename: String) {
        let fileManager = FileManager.default
        let downloadsURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let exportFileURL = downloadsURL.appendingPathComponent(testFilename)
        try? fileManager.removeItem(at: exportFileURL)
    }
}
