//
//  TMDBSampleUITests.swift
//  TMDBSampleUITests
//
//  Created by Yixiang Zhang on 2023-10-27.
//

import XCTest

final class TMDBSampleUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {

        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDownWithError() throws {
         app = nil
    }

    func testSearchForMovie() throws {
        // Ensure the app is in the correct initial state
        
        XCTAssertTrue(app.isDisplayingSearchView, "The SearchView is not being displayed")
        XCTAssertTrue(app.segmentedControls["Picker"].exists, "The Picker is not being displayed")
        
        let searchBar = app.textFields["SearchField"]
        XCTAssertTrue(searchBar.exists, "searchBar is not being displayed")
        
        searchBar.tap()  // Tap the search bar to focus it
        searchBar.typeText("Transformer\n")  // Type a query and hit return
        
        // Wait for the search to complete
        let expectation = self.expectation(description: "Wait for search to complete")
        DispatchQueue.global().asyncAfter(deadline: .now() + 5.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 6.0)
        print(app.debugDescription)
        // Verify the search results
        
        let transformerResult = app.collectionViews.buttons["Transformer, 2018-04-27"]
        XCTAssertTrue(transformerResult.exists, "The movie Transformer was not found")

        // Verify result number
        
        // Verify pages, etc
    }
    
    // TODO: Implment UI tests for all use cases.
}

extension XCUIApplication {
    // Helper property to verify the correct view is being displayed
    var isDisplayingSearchView: Bool {
        return otherElements["SearchView"].exists
    }
}
