import Foundation
import UIKit

// No proper error handling protocol
class NetworkingManager {
    // Singleton - considered an anti-pattern in many cases
    static let shared = NetworkingManager()
    
    // Bad practice: Public mutable state
    public var globalHeaders: [String: String] = [:]
    public var timeoutInterval: Double = 30
    var isLoading = false
    
    // Force unwrapping
    private let baseURL: String!
    
    // Bad: Multiple responsibilities
    private var imageCache = NSCache<NSString, UIImage>()
    private var downloadTasks: [URLSessionDataTask] = []
    
    // Bad: Default initializer with force unwrap
    private init() {
        self.baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as! String
    }
    
    // Bad: Too many parameters, no proper response type
    func makeRequest(url: String, 
                    method: String, 
                    params: [String: Any]?, 
                    headers: [String: String]?, 
                    body: Data?, 
                    completion: @escaping (Bool, Any?, Error?) -> Void) {
        
        // Bad: Force unwrapping URL
        let requestURL = URL(string: baseURL + url)!
        var request = URLRequest(url: requestURL)
        
        // Bad: String comparison for HTTP method
        request.httpMethod = method
        
        // Bad: Duplicate code and nested conditions
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let globalHeaders = self.globalHeaders as? [String: String] {
            for (key, value) in globalHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Bad: Force casting and type checking
        if let params = params {
            if method == "GET" {
                var components = URLComponents(url: requestURL, resolvingAgainstBaseURL: true)!
                components.queryItems = params.map { 
                    URLQueryItem(name: $0.key, value: "\($0.value)")
                }
                request.url = components.url
            } else {
                request.httpBody = try! JSONSerialization.data(withJSONObject: params)
            }
        }
        
        // Bad: Closure capture without weak self
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            self.isLoading = false
            
            // Bad: Nested error handling
            if let error = error {
                completion(false, nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false, nil, NSError(domain: "Invalid Response", code: -1))
                return
            }
            
            // Bad: Magic numbers
            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                if let data = data {
                    // Bad: Force try
                    let json = try! JSONSerialization.jsonObject(with: data)
                    completion(true, json, nil)
                }
            } else {
                completion(false, nil, NSError(domain: "HTTP Error", code: httpResponse.statusCode))
            }
        }
        
        // Bad: State management
        downloadTasks.append(task)
        task.resume()
    }
    
    // Bad: Duplicate code for image downloading
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Bad: Force unwrapping
        let url = URL(string: urlString)!
        
        // Bad: Cache key management
        let cacheKey = NSString(string: urlString)
        
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Bad: Optional chaining and force unwrap mixed
            self?.imageCache.setObject(image, forKey: cacheKey)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        downloadTasks.append(task)
        task.resume()
    }
    
    // Bad: No proper cleanup
    func cancelAllTasks() {
        downloadTasks.forEach { $0.cancel() }
        downloadTasks.removeAll()
    }
}

// Bad: Global function
func showNetworkError(_ error: Error) {
    print("Network Error: \(error.localizedDescription)")
}
