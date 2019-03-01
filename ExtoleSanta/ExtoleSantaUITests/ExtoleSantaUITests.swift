//Copyright © 2019 Extole. All rights reserved.

import XCTest

class ExtoleSantaUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let app = XCUIApplication()
        let extoleSantaNavigationBar = app.navigationBars["Extole Santa"]
        extoleSantaNavigationBar.buttons["Reset"].tap()
        app.sheets["Reset confirmation"].buttons["Yes"].tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Add items from Extole Santa list"]/*[[".cells.staticTexts[\"Add items from Extole Santa list\"]",".staticTexts[\"Add items from Extole Santa list\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        extoleSantaNavigationBar.buttons["Add"].tap()
        app.sheets["Pick your wish"].buttons["iPhone"].tap()
        

        let iphoneWish = app.tables.staticTexts["iPhone"]
        iphoneWish.tap()
        
        let playstationWish = app.tables.staticTexts["Playstation"]
        XCTAssertFalse(playstationWish.exists)
    }

}
