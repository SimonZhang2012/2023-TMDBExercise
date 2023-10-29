//
//  SearchView.swift
//  TMDBSample
//
//  Created by Yixiang Zhang on 2023-10-27.
//

import Foundation
import SwiftUI

// MARK: - SearchView

/// Represents the main search screen of the application.
struct SearchView: View {
    
    // MARK: - Private Properties
    
    @StateObject private var viewModel = SearchViewModel()
    @State private var showDebugView: Bool = false
    @State private var selectedView: String = "Search"
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack {
                // View selection
                Picker("View Selection", selection: $selectedView) {
                    Text("Search").tag("Search")
                    Text("Favorites").tag("Favorites")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .accessibilityIdentifier("Picker") 
                
                // Search or Favorites view
                if selectedView == "Search" {
                    // Search functionality
                    SearchBar(query: $viewModel.query, onSearch: {
                        if viewModel.query.lowercased() == "debug" {
                            showDebugView = true
                        } else {
                            viewModel.searchMoviesForFirstPage()
                        }
                    })
                    if showDebugView {
                        // Debug view
                        Button(action: {}) {
                            EmptyView()
                        }
                        .navigationDestination(isPresented: .constant(true)) {
                            DebugView()
                        }
                        .hidden()
                    } else {
                        // Search results or initial instructions
                        if viewModel.hasSearched {
                            SearchResultsView(viewModel: viewModel)
                        } else {
                            InitialInstructionsView()
                        }
                    }
                } else {
                    FavoriteView()
                }
            }
            .onAppear {
                self.showDebugView = false
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .alert(isPresented: $viewModel.showError) {
                Alert(title: Text("Error"), message: Text("Failed to fetch movies. Please try again later."), dismissButton: .default(Text("OK")))
            }
        }
        .accessibilityIdentifier("SearchView") 
    }
}

// MARK: - Subviews
extension SearchView {
    
    // MARK: - SearchBar
    
    struct SearchBar: View {
        
        @Binding var query: String
        var onSearch: () -> Void
        @FocusState private var isFocused: Bool
        
        var body: some View {
            HStack {
                TextField("Search for movies...", text: $query, onCommit: onSearch)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray3), lineWidth: 1)
                    )
                    .focused($isFocused)
                    .accessibilityIdentifier("SearchField")
                Button(action: {
                    isFocused = false
                    onSearch()
                }) {
                    Text("Search")
                        .foregroundColor(.green)
                }
            }
            .padding()
        }
    }
    
    // MARK: - SearchResultsView
    
    struct SearchResultsView: View {
        @ObservedObject var viewModel: SearchViewModel
        
        var body: some View {
            if viewModel.isLoading {
                ProgressView("Loading...")
                Spacer()
            } else if viewModel.hasSearched && viewModel.movies.isEmpty {
                NoResultsView()
            } else {
                MoviesListView(movies: viewModel.movies)
                if viewModel.hasSearched && !viewModel.movies.isEmpty {
                    PaginationView(viewModel: viewModel)
                }
            }
        }
    }
    
    // MARK: - NoResultsView
    
    struct NoResultsView: View {
        var body: some View {
            Text("No results found")
                .font(.title3)
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    // MARK: - InitialInstructionsView
    
    struct InitialInstructionsView: View {
        var body: some View {
            VStack {
                Text("Please enter something in the search and press search to show results")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .listRowBackground(Color.clear)
                Spacer()
                Text("Beautiful TMD Movie Search System 🙂")
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .padding()
            }
        }
    }
    
    // Mark: - Paginating
    
    struct PaginationView: View {
        @ObservedObject var viewModel: SearchViewModel
        
        var body: some View {
            HStack {
                Button(action: viewModel.navigateToPreviousPage) {
                    Image(systemName: "chevron.left")
                }
                .disabled(viewModel.currentPage == 1)
                
                Text("Page \(viewModel.currentPage) of \(viewModel.totalPages)")
                
                Button(action: viewModel.navigateToNextPage) {
                    Image(systemName: "chevron.right")
                }
                .disabled(viewModel.currentPage == viewModel.totalPages)
            }
            .padding()
        }
    }
}

