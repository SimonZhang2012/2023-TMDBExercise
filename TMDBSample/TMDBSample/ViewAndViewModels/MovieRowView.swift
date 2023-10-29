//
//  MovieRowView.swift
//  TMDBSample
//
//  Created by Yixiang Zhang on 2023-10-28.
//

import SwiftUI

struct MovieRowView: View {
    let movie: MovieModel
    
    @State private var loadedImage: Image?
    
    var body: some View {
        HStack {
            // Display loaded image if available
            if let image = loadedImage {
                image
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(5)
            } else {
                // Load image if poster path is available
                if let posterPath = movie.posterPath, !posterPath.isEmpty {
                    ProgressView()
                        .frame(width: 50, height: 50)
                        .onAppear {
                            DataManager.shared.fetchImage(for: posterPath) { image in
                                self.loadedImage = image
                            }
                        }
                } else {
                    // Placeholder for no image
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .frame(width: 50, height: 50)
                }
            }
            // Movie title and release date
            VStack(alignment: .leading) {
                Text(movie.title)
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .lineLimit(nil)
                Text(movie.releaseDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(minHeight: 50) // Minimum row height
    }
}

#Preview {
    MovieRowView(movie: MovieModel(tmdID: "", title: "", releaseDate: "", posterPath: nil, overview: "nothing"))
}
