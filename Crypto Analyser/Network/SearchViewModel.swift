//
//  SearchViewModel.swift
//  Crypto Analyser
//
//  Created by IE15 on 28/01/25.
//

import Foundation
import UIKit
import Keys

@MainActor
class SearchViewModel: ObservableObject {
    func fetchReferenceCurrencies(search: String, completion: @escaping (Result<CryptoResponse, Error>) -> Void) {
        let baseURL = "https://api.coinranking.com/v2/coins"
        let query = "?search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        let urlString = baseURL + query
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(CryptoResponse.self, from: data)
                print(decodedResponse)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchCryptoData(completion: @escaping (Result<CryptoResponse, Error>) -> Void) {
        guard let url = URL(string: "https://api.coinranking.com/v2/coins") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(CryptoResponse.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
