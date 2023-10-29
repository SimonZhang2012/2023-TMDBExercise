//
//  URLSessionProtocol.swift
//  TMDBSample
//
//  Created by Yixiang Zhang on 2023-10-29.
//

import Foundation

// For depedency injection in unit tests

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
