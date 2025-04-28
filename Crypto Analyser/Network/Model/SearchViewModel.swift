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
    @Published var coins: CryptoResponse?
    private var timer: Timer?
    @Published var isLoading:Bool = false
    func startFetching() {
        stopFetching()
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Task {
                    await self.fetchCryptoData { _ in }
                }
            }
        }
    }
    
    func stopFetching() {
        timer?.invalidate()
        timer = nil
    }
    
    private func fetchCrypto(from url: URL, completion: @escaping (Result<CryptoResponse, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
                
                if let errorResponse = errorResponse, errorResponse.status == "fail", errorResponse.code == "RATE_LIMIT_EXCEEDED" {
                    let fallback = CryptoResponse(
                        status: "success",
                        data: CryptoData(
                            stats: Stats(total: 0, totalCoins: 0, totalMarkets: 0, totalExchanges: 0, totalMarketCap: "0", total24hVolume: "0"),
                            coins: []
                        )
                    )
                    
                    Task {
                        await MainActor.run { self.coins = fallback
                            self.isLoading = true
                        }
                    }
                    completion(.success(fallback))
                    return
                }
                
                let decoded = try JSONDecoder().decode(CryptoResponse.self, from: data)
                Task {
                    await MainActor.run { self.coins = decoded
                        self.isLoading = false
                    }
                }
                completion(.success(decoded))
                
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
    }
    
    func fetchReferenceCurrencies(search: String, completion: @escaping (Result<CryptoResponse, Error>) -> Void) {
        let baseURL = "https://api.coinranking.com/v2/coins"
        let query = "?search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: baseURL + query) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        fetchCrypto(from: url, completion: completion)
    }
    
    func fetchCryptoData(completion: @escaping (Result<CryptoResponse, Error>) -> Void) {
        guard let url = URL(string: "https://api.coinranking.com/v2/coins") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        fetchCrypto(from: url, completion: completion)
    }
    
}
