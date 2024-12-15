//
//  BestSkiDayUITestsLaunchTests.swift
//  BestSkiDayUITests
//
//  Created by Sebastian on 06.12.24.
//

import XCTest

final class BestSkiDayUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify initial state
        XCTAssertTrue(app.navigationBars.firstMatch.exists)
        
        // Test loading state
        let loadingIndicator = app.activityIndicators["Loading forecast..."]
        XCTAssertTrue(loadingIndicator.exists)
        
        // Wait for content to load
        let predicate = NSPredicate(format: "exists == false")
        expectation(for: predicate, evaluatedWith: loadingIndicator, handler: nil)
        waitForExpectations(timeout: 5)

        // Take launch screenshot
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
