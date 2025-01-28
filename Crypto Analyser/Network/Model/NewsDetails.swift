//
//  NewsDetails.swift
//  Crypto Analyser
//
//  Created by IE15 on 27/12/24.
//

import Foundation

struct NewsDetails: Codable {
    let newsUrl: String?
    let imageUrl: String?
    let title: String?
    let text: String?
    let sourceName: String?
    let date: String?
    let topics: [String]?
    let sentiment: String?
    let type: String?
    let tickers: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case newsUrl = "news_url"
        case imageUrl = "image_url"
        case title = "title"
        case text = "text"
        case sourceName = "source_name"
        case date = "date"
        case topics = "topics"
        case sentiment = "sentiment"
        case type = "type"
        case tickers = "tickers"
    }
}

// Define a struct to represent the root response
struct CryptoNewsResponse: Codable {
    let data: [NewsDetails]
}

func fetchCryptoNews(section: String = "general", items: Int = 10, page: Int = 1, apiKey: String = "yhck3vg1nq37g8djvm0qfhp7xlmwdztqd6i9qgzu", completion: @escaping (Result<[NewsDetails], Error>) -> Void) {
    var components = URLComponents(string: "https://cryptonews-api.com/api/v1/category")
    
    components?.queryItems = [
        URLQueryItem(name: "section", value: section),
        URLQueryItem(name: "items", value: "\(items)"),
        URLQueryItem(name: "page", value: "\(page)"),
        URLQueryItem(name: "token", value: apiKey)
    ]
    
    guard let url = components?.url else {
        completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }
    
    // Create the URLRequest
    let request = URLRequest(url: url)
    
    // Perform the URLSession data task
    URLSession.shared.dataTask(with: request) { data, response, error in
        // Handle errors
        if let error = error {
            print("Request failed with error: \(error)")
            completion(.failure(error))
            return
        }
        
        // Ensure we have valid data
        guard let data = data else {
            completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
            return
        }
        
        // Decode the response
        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(CryptoNewsResponse.self, from: data)
            // Pass the decoded news array to the completion handler
            completion(.success(decodedResponse.data))
        } catch {
            print("Decoding error: \(error)")
            completion(.failure(error))
        }
    }.resume() // Start the data task
}

