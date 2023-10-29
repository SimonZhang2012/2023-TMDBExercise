//
//  DebugView.swift
//  TMDBSample
//
//  Created by Yixiang Zhang on 2023-10-28.
//

import SwiftUI

struct DebugView: View {
    @State private var imageCacheInfo: DataManager.CacheSummary = DataManager.CacheSummary(fileCount: 0, totalSize: 0)
    @State private var searchCacheInfo: DataManager.CacheSummary = DataManager.CacheSummary(fileCount: 0, totalSize: 0)
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            debugTitle
                .padding()
            
            VStack {
                cacheGroup(title: "Image Cache", cacheInfo: imageCacheInfo)
                Divider()
                cacheGroup(title: "Search Cache", cacheInfo: searchCacheInfo)
            }
            .padding()
            
            clearCacheButton
                .padding()
        }
        .onAppear {
            updateCacheInfo()
        }
    }
    
    // MARK: - Private Views
    
    private var debugTitle: some View {
        Text("Debug Information")
            .font(.largeTitle)
    }
    
    private func cacheGroup(title: String, cacheInfo: DataManager.CacheSummary) -> some View {
        Group {
            Text(title)
            Text("File count: \(cacheInfo.fileCount)")
            Text("Total size: \(cacheInfo.totalSize.bytesToReadableFormat())")
        }
    }
    
    private var clearCacheButton: some View {
        Button(action: {
            DataManager.shared.clearCache()
            updateCacheInfo()
        }) {
            Text("Clear Cache")
        }
    }
    
    // MARK: - Private Methods
    
    private func updateCacheInfo() {
        let cacheInfo = DataManager.shared.getCacheInfo()
        imageCacheInfo = cacheInfo.imageCache
        searchCacheInfo = cacheInfo.searchCache
    }
}

