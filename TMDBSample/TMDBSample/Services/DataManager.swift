//
//  DataManager.swift
//  TMDBSample
//
//  Created by Yixiang Zhang on 2023-10-27.
//

import Foundation
import UIKit   // TODO: This could be removed now, just need to update the image cache part, use Image to replace UIImage
import SwiftUI

class DataManager {
    static let shared = DataManager()
    private let timeoutInterval: TimeInterval = 2  // adjust timeout interval as needed
    private let fileManager = FileManager.default
    private let imageDirectory: URL
    private let searchCacheDirectory: URL
    private let favoritesFileURL: URL
    private var favoriteMovies: [MovieModel] = []
    
    struct CacheSummary {
        var fileCount: Int
        var totalSize: Int64
    }

    
    private init() {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        imageDirectory = paths[0].appendingPathComponent("images")
        try? fileManager.createDirectory(at: imageDirectory, withIntermediateDirectories: true, attributes: nil)
        
        searchCacheDirectory = paths[0].appendingPathComponent("searchCache")
        try? fileManager.createDirectory(at: searchCacheDirectory, withIntermediateDirectories: true, attributes: nil)
        
        favoritesFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("favorites.json")
        loadFavoriteMovies()
    }
    
    // MARK: - get images with cache
    
    func fetchImage(for path: String, completion: @escaping (Image?) -> Void) {
        if let cachedImage = getCachedImage(for: path) {
            Task {
                await MainActor.run { completion(cachedImage) }
            }
            return
        }
        
        guard let url = TMDAPIManager.shared.imageURL(for: path) else {
            Task {
                await MainActor.run { completion(nil) }
            }
            return
        }
        
        fetchImageFromURL(url, for: path, completion: completion)
    }
    
    private func getCachedImage(for path: String) -> Image? {
        let filePath = imageDirectory.appendingPathComponent(path)
        guard let data = try? Data(contentsOf: filePath),
              let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
    
    private func fetchImageFromURL(_ url: URL, for path: String, completion: @escaping (Image?) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)
        var task: URLSessionDataTask?
        
        let timeoutWorkItem = DispatchWorkItem {
            task?.cancel()
            semaphore.signal()
            Task {
                await MainActor.run { completion(self.placeholderImage()) }  // Timeout, return placeholder image
            }
        }
        
        task = URLSession.shared.dataTask(with: url) { data, _, error in
            defer {
                timeoutWorkItem.cancel()  // Cancel the timeout work item since the task completed
                semaphore.signal()
            }
            
            guard let data = data, error == nil, let uiImage = UIImage(data: data) else {
                Task {
                    await MainActor.run { completion(nil) }
                }
                return
            }
            
            self.saveImageToCache(data, for: path)
            
            Task {
                await MainActor.run { completion(Image(uiImage: uiImage)) }
            }
        }
        
        task?.resume()
        
        // Timeout handling
        DispatchQueue.global().asyncAfter(deadline: .now() + timeoutInterval, execute: timeoutWorkItem)
    }
    
    private func saveImageToCache(_ data: Data, for path: String) {
        let filePath = imageDirectory.appendingPathComponent(path)
        try? data.write(to: filePath, options: .atomicWrite)
    }
    
    func placeholderImage() -> Image {
        return Image(systemName: "photo")
    }
    
    // MARK: - search movies with cache

    func fetchMovies(query: String, page: Int = 1) async throws -> APISearchResponseModel {
        if let cachedResult = getCachedSearchResult(for: query, page: page) {
            return cachedResult
        }
        
        guard let url = TMDAPIManager.shared.movieSearchURL(with: query, page: page) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let fetchedMovies = try await TMDAPIManager.shared.fetch(url, as: APISearchResponseModel.self)
        saveSearchResult(fetchedMovies, for: query, page: page)
        return fetchedMovies
    }

    private func cacheKey(for query: String, page: Int) -> String {
        return query + "##" + String(page)
    }
    
    private func saveSearchResult(_ result: APISearchResponseModel, for query: String, page: Int) {
        let key = cacheKey(for: query, page: page)
        let filePath = searchCacheDirectory.appendingPathComponent(key)
        if let data = try? JSONEncoder().encode(result) {
            try? data.write(to: filePath, options: .atomicWrite)
        }
    }
    
    private func getCachedSearchResult(for query: String, page: Int) -> APISearchResponseModel? {
        let key = cacheKey(for: query, page: page)
        let filePath = searchCacheDirectory.appendingPathComponent(key)
        guard let data = try? Data(contentsOf: filePath) else { return nil }
        return try? JSONDecoder().decode(APISearchResponseModel.self, from: data)
    }
    
    // MARK: - Cache Management
    
    private func processDirectory(_ directory: URL) -> CacheSummary {
        var fileCount = 0
        var totalSize: Int64 = 0
        
        let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.fileSizeKey], options: [])
        while let fileURL = enumerator?.nextObject() as? URL {
            fileCount += 1
            if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(fileSize)
            }
        }
        return CacheSummary(fileCount: fileCount, totalSize: totalSize)
    }
    
    func getCacheInfo() -> (imageCache: CacheSummary, searchCache: CacheSummary) {
        let imageCacheSummary = processDirectory(imageDirectory)
        let searchCacheSummary = processDirectory(searchCacheDirectory)
        
        return (imageCache: imageCacheSummary, searchCache: searchCacheSummary)
    }
    
    func clearCache() {
        try? fileManager.removeItem(at: imageDirectory)
        try? fileManager.createDirectory(at: imageDirectory, withIntermediateDirectories: true, attributes: nil)
        
        try? fileManager.removeItem(at: searchCacheDirectory)
        try? fileManager.createDirectory(at: searchCacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    // MARK - Favourite Management
    func addMovieToFavorites(_ movie: MovieModel) {
        guard !favoriteMovies.contains(movie) else {
            return
        }
        favoriteMovies.append(movie)
        saveFavoriteMovies()
    }
    
    func removeMovieFromFavorites(_ movie: MovieModel) {
        favoriteMovies.removeAll { $0 == movie }
        saveFavoriteMovies()
    }
    
    func getFavoriteMovies() -> [MovieModel] {
        return favoriteMovies
    }
    
    private func loadFavoriteMovies() {
        guard let data = try? Data(contentsOf: favoritesFileURL),
              let decodedMovies = try? JSONDecoder().decode([MovieModel].self, from: data) else { return }
        favoriteMovies = decodedMovies
    }
    
    private func saveFavoriteMovies() {
        guard let data = try? JSONEncoder().encode(favoriteMovies) else { return }
        try? data.write(to: favoritesFileURL, options: .atomicWrite)
    }
    
    func isMovieInFavorites(_ movie: MovieModel) -> Bool {
        return favoriteMovies.contains(movie)
    }
}

