//
//  ChatGPTResponse.swift
//  Crypto Analyser
//
//  Created by IE15 on 10/01/25.
//

import Foundation

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
