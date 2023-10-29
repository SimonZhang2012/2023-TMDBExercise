//
//  MovieDetailsView.swift
//  TMDBSample
//
//  Created by Yixiang Zhang on 2023-10-28.
//

import SwiftUI

// MARK: - MovieDetailsView

struct MovieDetailsView: View {
    let movie: MovieModel
    @State private var loadedImage: Image?
    @State private var isFavorite: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack {
                favoriteButton
                movieTitle
                releaseDate
                moviePoster(path: movie.posterPath)
                    .padding()
                movieOverview
                    .padding([.leading, .trailing])
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarTitle("Movie Details", displayMode: .inline)
        .onAppear(perform: checkFavoriteStatus)
    }
    
    // MARK: - Private Views
    
    private var favoriteButton: some View {
        Button(action: toggleFavorite) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(isFavorite ? .yellow : .gray)
        }
        .padding()
    }
    
    private var movieTitle: some View {
        Text(movie.title)
            .font(.system(size: dynamicTitleFontSize(title: movie.title)))
            .lineLimit(1)
            .foregroundColor(.black)
            .padding()
    }
    
    private var releaseDate: some View {
        Text(movie.releaseDate)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.blue)
            .padding([.leading, .trailing])
    }
    
    private var movieOverview: some View {
        Text(movie.overview)
    }
    
    // MARK: - Private Methods
    
    private func checkFavoriteStatus() {
        isFavorite = DataManager.shared.isMovieInFavorites(movie)
    }
    
    private func toggleFavorite() {
        if isFavorite {
            DataManager.shared.removeMovieFromFavorites(movie)
        } else {
            DataManager.shared.addMovieToFavorites(movie)
        }
        isFavorite.toggle()
    }
    
    @ViewBuilder
    private func moviePoster(path: String?) -> some View {
        if let image = loadedImage {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 400)
                .cornerRadius(5)
        } else {
            if let path = path, !path.isEmpty {
                ProgressView() // Placeholder till image loads
                    .frame(width: 50, height: 50)
                    .onAppear {
                        DataManager.shared.fetchImage(for: path) { image in
                            self.loadedImage = image
                        }
                    }
            } else {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .frame(width: 200, height: 200)
            }
        }
    }
    
    private func dynamicTitleFontSize(title: String) -> CGFloat {
        return title.count > 30 ? 20 : 28 // Adjust the font size based on the title length
    }
}

// MARK: - Preview

struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(movie: MovieModel(tmdID: "123",
                                           title: "Guardians of the Galaxy",
                                           releaseDate: "2014-08-01",
                                           posterPath: nil,
                                           overview: "A group of intergalactic criminals must pull together to stop a fanatical warrior with plans to purge the universe."))
    }
}
