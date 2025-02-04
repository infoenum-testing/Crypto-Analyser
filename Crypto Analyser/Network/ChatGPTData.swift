//
//  ChatGPTData.swift
//  Crypto Analyser
//
//  Created by IE15 on 07/01/25.
//

import Foundation
import UIKit
import Keys

@MainActor
class ChatGPTData: ObservableObject {
    @Published var data: MessageData?
    
    func analyseImageData(imageBase64: String, completion: @escaping (Result<MessageData, Error>) -> Void) {
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

func sendImageAsBase64(imageBase64: String, completion: @escaping (Result<MessageData, Error>) -> Void) {
    // API Endpoint
    guard let url = URL(string: StringConstants.chatGPTApiUrl) else { return }
    let apiKey = CryptoAnalyserKeys().chatGPtApiKey 
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
                        "text": """
                        Analyze the market trend based on the uploaded image and determine whether the signal  is bullish or bearish. Provide a detailed technical analysis in 2-3 lines that includes the name of the asset and incorporates 2-4 randomly selected technical indicators to support the prediction. Additionally, specify a confidence level for the forecast. If the image is not a crypto chart just say false.
                        The response should be formatted in JSON as follows:
                        {
                            "signal": "<bullish/bearish>",
                            "tech_analysis": "<detailed technical analysis>",
                            "confidence_level": "<percentage confidence>"
                        }
                        """
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
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("data" ,jsonObject)  
            }
            let response = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
            if let jsonData = response.choices?.first?.message?.content {
                let cleanedJsonString = jsonData
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if let jsonData = cleanedJsonString.data(using: .utf8) {
                        do {
                            let response = try JSONDecoder().decode(MessageData.self, from: jsonData)
                            print("Parsed Response: \(response)")
                            completion(.success(response))
                        } catch {
                            print("Error decoding JSON: \(error)")
                            completion(.failure(error))
                        }
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                }
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            }
           
        } catch {
            completion(.failure(error))
        }
    }.resume()
}
