//
//  BestSkiDayUITests.swift
//  BestSkiDayUITests
//
//  Created by Sebastian on 06.12.24.
//

import XCTest

final class BestSkiDayUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    func testLocationSearch() throws {
        // Test location search functionality
        let searchButton = app.buttons["Choose Location"]
        XCTAssertTrue(searchButton.exists)
        searchButton.tap()
        
        let searchField = app.textFields["Search locations..."]
        XCTAssertTrue(searchField.exists)
        searchField.tap()
        searchField.typeText("Zermatt")
        
        // Wait for search results
        let predicate = NSPredicate(format: "exists == true")
        let searchResult = app.buttons["Zermatt"]
        expectation(for: predicate, evaluatedWith: searchResult, handler: nil)
        waitForExpectations(timeout: 5)
        
        searchResult.tap()
    }
    
    func testFavoriteLocation() throws {
        // Test adding/removing favorite location
        let favoriteButton = app.buttons["star"]
        XCTAssertTrue(favoriteButton.exists)
        favoriteButton.tap()
        
        // Verify star is filled
        XCTAssertTrue(app.buttons["star.fill"].exists)
        
        // Remove from favorites
        app.buttons["star.fill"].tap()
        
        // Verify star is empty again
        XCTAssertTrue(app.buttons["star"].exists)
    }
    
    func testForecastDisplay() throws {
        // Test forecast display elements
        let forecastList = app.scrollViews.firstMatch
        XCTAssertTrue(forecastList.exists)
        
        // Check for weather metrics
        XCTAssertTrue(app.images["snow"].exists)
        XCTAssertTrue(app.images["mountain.2"].exists)
        XCTAssertTrue(app.images["thermometer.low"].exists)
        XCTAssertTrue(app.images["thermometer.high"].exists)
        XCTAssertTrue(app.images["sun.max"].exists)
    }
    
    func testAccessibility() throws {
        // Test accessibility labels
        let scoreLabel = app.staticTexts.matching(identifier: "Score: 94 percent").firstMatch
        XCTAssertTrue(scoreLabel.exists)
        
        let snowfallLabel = app.staticTexts.matching(identifier: "Snowfall: 10 centimeters").firstMatch
        XCTAssertTrue(snowfallLabel.exists)
        
        let snowHeightLabel = app.staticTexts.matching(identifier: "Snow height: 50 centimeters").firstMatch
        XCTAssertTrue(snowHeightLabel.exists)
    }
}
