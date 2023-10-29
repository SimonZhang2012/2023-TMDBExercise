//
//  TMDAPIManagerTests.swift
//  TMDBSampleTests
//
//  Created by Yixiang Zhang on 2023-10-29.
//
import XCTest
@testable import TMDBSample

final class MockURLSession: URLSessionProtocol {
    
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let mockError = mockError {
            throw mockError
        }
        guard let mockData = mockData, let mockResponse = mockResponse else {
            throw NSError(domain: "MockURLSession", code: 1, userInfo: nil)
        }
        return (mockData, mockResponse)
    }
}

final class TMDAPIManagerTests: XCTestCase {
    
    var mockSession: MockURLSession?
    var apiManager: TMDAPIManager?
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        apiManager = TMDAPIManager(session: mockSession!)
    }

    func testConstructURL() {
        // Given
        let query = "Inception"
        let page = 1
        
        // When
        let url = apiManager?.movieSearchURL(with: query, page: page)
        
        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://api.themoviedb.org/3/search/movie?query=Inception&include_adult=false&language=en-US&page=1")
    }

    func testImageURL() {
        // Given
        let path = "/someImage.jpg"
        
        // When
        let url = apiManager?.imageURL(for: path)
        
        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://image.tmdb.org/t/p/w500/someImage.jpg")
    }
    
    func testFetchDataSuccess() async {
            // Given
            let expectedTitle = "Inception"
            let mockData = """
            {
                "page": 1,
                "results": [
                    {
                        "adult": false,
                        "backdrop_path": "/s3TBrRGB1iav7gFOCNx3H31MoES.jpg",
                        "genre_ids": [28, 878],
                        "id": 27205,
                        "original_language": "en",
                        "original_title": "Inception",
                        "overview": "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a CEO.",
                        "popularity": 24.823,
                        "poster_path": "/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg",
                        "release_date": "2010-07-16",
                        "title": "Inception",
                        "video": false,
                        "vote_average": 8.3,
                        "vote_count": 27092
                    }
                ],
                "total_pages": 1,
                "total_results": 1
            }
            """.data(using: .utf8)
            let mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                                statusCode: 200,
                                                httpVersion: nil,
                                                headerFields: nil)
            mockSession?.mockData = mockData
            mockSession?.mockResponse = mockResponse
            
            // When
            do {
                let url = URL(string: "https://example.com")!
                let result: APISearchResponseModel = try await apiManager!.fetch(url, as: APISearchResponseModel.self)
                let movie = result.results.first
                
                // Then
                XCTAssertEqual(movie?.title, expectedTitle)
            } catch {
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
    func testFetchDataError() async {
        // Given
        let mockError = NSError(domain: "MockURLSession", code: 404, userInfo: nil)
        mockSession?.mockError = mockError
        
        // When
        do {
            let url = URL(string: "https://example.com")!
            let _ = try await apiManager!.fetch(url, as: APISearchResponseModel.self)
            
            // Then
            XCTFail("Expected error but got success")
        } catch {
            XCTAssertEqual((error as NSError).code, 404)
        }
    }

}
