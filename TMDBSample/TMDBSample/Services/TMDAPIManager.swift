//
//  TMDAPIManager.swift
//  TMDBSample
//
//  Created by Yixiang Zhang on 2023-10-27.
//

import Foundation

// MARK: - TMDAPIManager

/// Manages the network interactions with The Movie Database API.
final class TMDAPIManager {
    
    // MARK: - Singleton Instance
    
    static let shared = TMDAPIManager()
    
    // MARK: - Constants
    
    private let baseURL = "https://api.themoviedb.org/3/search/movie"
    private let imageBaseURL = "https://image.tmdb.org/t/p/"
    private let imageSize = "w500" // simplified here, an ideal way is to fetch different size for different view
    
    // MARK: - Properties
    
    private let session: URLSessionProtocol
    
    // MARK: - Initializer
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Enums
    
    enum APIError: Error, Equatable {
        case invalidResponse
        case statusCode(Int)
        case noData
    }
    
    // MARK: - URL Construction
    
    func movieSearchURL(with query: String, page: Int = 1) -> URL? {
        let urlString = "\(baseURL)?query=\(query)&include_adult=false&language=en-US&page=\(page)"
        return URL(string: urlString)
    }
    
    func imageURL(for path: String) -> URL? {
        return URL(string: "\(imageBaseURL)\(imageSize)\(path)")
    }
    
    // MARK: - Network Requests
    
    /// Fetches data from a specified URL.
    ///
    /// - Parameters:
    ///   - url: The URL to fetch data from.
    ///   - type: The `Decodable` type to decode the data into.
    ///   - retryCount: The number of retry attempts for the request. Default is 3.
    ///
    /// - Returns: A `Decodable` object or throws an error.
    func fetch<T: Decodable>(_ url: URL, as type: T.Type, retryCount: Int = 3) async throws -> T {
        for attempt in 0..<retryCount {
            do {
                let decodedData = try await performRequest(url, as: T.self)
                return decodedData
            } catch {
                if attempt == retryCount - 1 { throw error } // Rethrow error on the last attempt
            }
        }
        throw APIError.noData // Placeholder error, consider replacing with a more appropriate error
    }
    
    private func performRequest<T: Decodable>(_ url: URL, as type: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxZGVmZDBkNGUyYzFhZDYzMzYzNTc2MWQ4OTQ5NDk0MCIsInN1YiI6IjU4YTZkMDE2OTI1MTQxNzQ1YjAwNmJkZiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Id3tQ5QI-v-GvhHMlQkCCTK_fBCwg8NZ8DI51huqTbE", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              !data.isEmpty else {
                  throw APIError.invalidResponse
              }
        
        return try JSONDecoder().decode(T.self, from: data)
    }

}

