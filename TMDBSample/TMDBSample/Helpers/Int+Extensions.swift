//
//  Int+Extensions.swift
//  TMDBSample
//
//  Created by Yixiang Zhang on 2023-10-28.
//

import Foundation

extension Int64 {
    func bytesToReadableFormat() -> String {
        let byteCount = self
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB, .useMB, .useGB]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: byteCount)
    }
}

