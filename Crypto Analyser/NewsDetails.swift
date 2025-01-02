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

func decodeNewsJson() -> [NewsDetails]? {
    guard let fileUrl = Bundle.main.url(forResource: "NewsJson", withExtension: "json") else {
        print("JSON file not found")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: fileUrl)
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON Content:\n\(jsonString)")
        }
        let decoder = JSONDecoder()
        let newsArray = try decoder.decode([NewsDetails].self, from: data)
        return newsArray
    } catch {
        print("Error: \(error.localizedDescription)")
        return nil
    }
}
