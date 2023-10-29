//
//  FavouriteView.swift
//  TMDBSample
//
//  Created by Yixiang Zhang on 2023-10-28.
//

import Foundation
import SwiftUI

struct FavoriteView: View {
    @State private var favoriteMovies: [MovieModel] = []
    
    var body: some View {
        
        MoviesListView(movies: favoriteMovies)
        .onAppear {
            self.favoriteMovies = DataManager.shared.getFavoriteMovies()
        }

    }
}
