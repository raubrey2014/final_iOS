//
//  milestone1UITests.swift
//  milestone1UITests
//
//  Created by Ryan Aubrey on 4/3/16.
//  Copyright © 2016 Ryan Aubrey. All rights reserved.
//

import XCTest

class milestone1UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testExample() {
        
        let app = XCUIApplication()
        let yourEventsButton = app.navigationBars["Event Details"].buttons["Your Events"]
        yourEventsButton.tap()
        app.tables.staticTexts["Maore brew ions"].tap()
        app.buttons["Attend via CloudReach"].tap()
        yourEventsButton.tap()
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
