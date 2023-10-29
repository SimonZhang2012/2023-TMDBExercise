//
//  APISearchResponseModel.swift
//  TMDBSample
//
//  Created by Yixiang Zhang on 2023-10-27.
//

import Foundation

/// Represent the search result object returned from TMB API
struct APISearchResponseModel: Codable {
    let page: Int
    let results: [APIMovieModel]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
