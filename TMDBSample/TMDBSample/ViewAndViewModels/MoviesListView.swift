//
//  MoviesListView.swift
//  TMDBSample
//
//  Created by Yixiang Zhang on 2023-10-28.
//

import SwiftUI

// MARK: - MoviesListView

/// Representing a list of movies.
struct MoviesListView: View {
    
    // MARK: - Properties

    var movies: [MovieModel]
    
    // MARK: - Body
    
    var body: some View {
        List(movies) { movie in
            NavigationLink(destination: MovieDetailsView(movie: movie)) {
                MovieRowView(movie: movie)
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Preview

struct MoviesListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockMovies = [
            MovieModel(tmdID: "1", title: "Movie 1", releaseDate: "2021-01-01", posterPath: nil, overview: "Overview 1"),
            MovieModel(tmdID: "2", title: "Movie 2", releaseDate: "2022-02-02", posterPath: nil, overview: "Overview 2")
        ]
        
        MoviesListView(movies: mockMovies)
    }
}
