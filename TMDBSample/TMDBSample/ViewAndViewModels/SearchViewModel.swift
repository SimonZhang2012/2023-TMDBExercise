//
//  SearchViewModel.swift
//  TMDBSample
//
//  Created by Yixiang Zhang on 2023-10-27.
//

import Foundation
import SwiftUI

class SearchViewModel: ObservableObject {
    
    // MARK: Published Properties
    
    @Published var query: String = ""
    
    // To remember current query, this is useful as user might navigate to next page
    // while already changed the binding value of query
    private var currentQuery: String = ""
    
    @Published var movies: [MovieModel] = []
    @Published var showError: Bool = false
    @Published var hasSearched: Bool = false
    @Published var isLoading: Bool = false
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
     
    // MARK: Public Methods
    
    func searchMoviesForFirstPage() {
        hasSearched = true
        currentPage = 1
        currentQuery = query
        fetchMovies(page: currentPage)
    }

    func navigateToNextPage() {
        if currentPage < totalPages {
            currentPage += 1
            fetchMovies(page: currentPage)
        }
    }
    
    func navigateToPreviousPage() {
        if currentPage > 1 {
            currentPage -= 1
            fetchMovies(page: currentPage)
        }
    }
    
    // MARK: Private Methods
    
    func fetchMovies(page: Int) {
        isLoading = true
        Task {
            do {
                let fetchedMovies = try await DataManager.shared.fetchMovies(query: currentQuery, page: page)
                // Dispatch UI updates to the main thread
                await MainActor.run {
                    self.movies = fetchedMovies.results.map {
                        MovieModel(tmdID: String($0.id),
                                   title: $0.title,
                                   releaseDate: $0.releaseDate,
                                   posterPath: $0.posterPath ?? "",
                                   overview: $0.overview)
                    }
                    self.totalPages = fetchedMovies.totalPages
                    self.isLoading = false
                }
            } catch {
                // Dispatch UI updates to the main thread
                await MainActor.run {
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }
}

