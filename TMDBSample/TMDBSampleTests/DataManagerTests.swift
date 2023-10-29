//
//  DataManagerTests.swift
//  TMDBSampleTests
//
//  Created by Yixiang Zhang on 2023-10-29.
//

import XCTest
@testable import TMDBSample

class DataManagerTests: XCTestCase {
    
    var dataManager: DataManager!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager.shared
    }
    
    override func tearDown() {
        dataManager = nil
        super.tearDown()
    }
    
    // MARK: - Cache Management Tests
    
    func testClearCache() {
        // Given: some cache
        let cacheInfoBefore = dataManager.getCacheInfo()
        XCTAssert(cacheInfoBefore.imageCache.fileCount >= 0 && cacheInfoBefore.searchCache.fileCount >= 0)
        
        // When: Clearing the cache
        dataManager.clearCache()
        
        // Then: Both image and search caches should be empty
        let cacheInfoAfter = dataManager.getCacheInfo()
        XCTAssertEqual(cacheInfoAfter.imageCache.fileCount, 0)
        XCTAssertEqual(cacheInfoAfter.searchCache.fileCount, 0)
    }
    
    // MARK: - Favorite Management Tests
    
    func testAddAndRemoveMovieToFavorites() {
        // Given: A movie
        let movie = MovieModel(tmdID: "1", title: "Test Movie", releaseDate: "2023-01-02", posterPath: nil, overview: "This is a test movie")
        
        // When: Adding the movie to favorites
        dataManager.addMovieToFavorites(movie)
        
        // Then: The movie should be in favorites
        XCTAssertTrue(dataManager.isMovieInFavorites(movie))
        
        // When: Removing the movie from favorites
        dataManager.removeMovieFromFavorites(movie)
        
        // Then: The movie should not be in favorites
        XCTAssertFalse(dataManager.isMovieInFavorites(movie))
    }
    
    // MARK: - Image Fetching Tests
    
    func testPlaceholderImage() {
        // Given: DataManager
        // When: Getting a placeholder image
        let placeholderImage = dataManager.placeholderImage()
        
        // Then: The image should not be nil
        XCTAssertNotNil(placeholderImage)
    }
    
    // TODO: More test can be added via dependency injection, similiar to TMDAPIManagerTests
    
}
