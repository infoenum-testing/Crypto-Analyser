//
//  ChatGPTData.swift
//  Crypto Analyser
//
//  Created by IE15 on 07/01/25.
//

import Foundation
import UIKit

struct ChatGPTResponse: Codable {
    let object: String?
    let id: String?
    let model: String?
    let systemFingerprint: String?
    let created: Int?
    let choices: [Choice]?
    let usage: Usage?
    
    enum CodingKeys: String, CodingKey {
        case object, id, model
        case systemFingerprint = "system_fingerprint"
        case created, choices, usage
    }
}

// Choice Model
struct Choice: Codable {
    let finishReason: String?
    let message: Message?
    let logprobs: String?
    let index: Int?
    
    enum CodingKeys: String, CodingKey {
        case finishReason = "finish_reason"
        case message, logprobs, index
    }
}

// Message Model
struct Message: Codable {
    let content: String?
    let role: String?
    let refusal: String?
}

// Usage Model
struct Usage: Codable {
    let completionTokensDetails: CompletionTokensDetails?
    let totalTokens: Int?
    let promptTokens: Int?
    let completionTokens: Int?
    let promptTokensDetails: PromptTokensDetails?
    
    enum CodingKeys: String, CodingKey {
        case completionTokensDetails = "completion_tokens_details"
        case totalTokens = "total_tokens"
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case promptTokensDetails = "prompt_tokens_details"
    }
}

// Completion Tokens Details Model
struct CompletionTokensDetails: Codable {
    let reasoningTokens: Int?
    let rejectedPredictionTokens: Int?
    let acceptedPredictionTokens: Int?
    let audioTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case reasoningTokens = "reasoning_tokens"
        case rejectedPredictionTokens = "rejected_prediction_tokens"
        case acceptedPredictionTokens = "accepted_prediction_tokens"
        case audioTokens = "audio_tokens"
    }
}

// Prompt Tokens Details Model
struct PromptTokensDetails: Codable {
    let audioTokens: Int?
    let cachedTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case audioTokens = "audio_tokens"
        case cachedTokens = "cached_tokens"
    }
}

@MainActor
class ChatGPTData: ObservableObject {
    @Published var data: ChatGPTResponse?
    
    func analyseImageData(imageBase64: String, completion: @escaping (Result<ChatGPTResponse, Error>) -> Void) {
        let imageStr =  "data:image/jpeg;base64," + imageBase64
        sendImageAsBase64(imageBase64: imageStr, completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self.data = success
                    completion(.success(success))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        })
    }
}

func sendImageAsBase64(imageBase64: String, completion: @escaping (Result<ChatGPTResponse, Error>) -> Void) {
    // API Endpoint
    guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }
    let apiKey = ""
    // Prepare the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Construct the payload
    let payload: [String: Any] = [
        "model": "gpt-4o-mini",
        "messages": [
            [
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": "Analyse the crypto chart and give a buy/sell signal in 2-3 lines? If the image is not a crypto chart just say false"
                    ],
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": imageBase64
                        ]
                    ]
                ]
            ]
        ],
        "max_tokens": 300
    ]
    
    // Convert payload to JSON
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
        request.httpBody = jsonData
    } catch {
        completion(.failure(error))
        return
    }
    
    // Send the request
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
            return
        }
        
        // Handle the response
        do {
            let response = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
            completion(.success(response))
        } catch {
            completion(.failure(error))
        }
    }.resume()
}
