//
//  MovieModule.swift
//  TMDBSample
//
//  Created by Yixiang Zhang on 2023-10-27.
//

import Foundation


/// Represent the main movie object through our App
struct MovieModel: Identifiable, Codable, Equatable {
    
    // MARK: - Properties
    
    let id: String // For future if we want to modify the movie data - we's like to have our own unique ID
    let tmdID: String
    let title: String
    let releaseDate: String
    let posterPath: String?
    let overview: String
    
    // MARK: - Initializer
    
    init(tmdID: String, title: String, releaseDate: String, posterPath: String?, overview: String) {
        self.id = tmdID   // Let's keep simple for now, considering having our own ID when we are going to modify the data
        self.tmdID = tmdID
        self.title = title
        self.releaseDate = releaseDate
        self.posterPath = posterPath
        self.overview = overview
    }
    
    // MARK: - Equatable Protocol Conformance
    
    static func == (lhs: MovieModel, rhs: MovieModel) -> Bool {
        return lhs.id == rhs.id 
    }
}

