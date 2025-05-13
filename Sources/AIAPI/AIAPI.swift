// AIAPI - A Swift interface for communicating with AI models
// Supports OpenAI (GPT), Anthropic (Claude), and Google (Gemini) models

import Foundation

/// Main entry point for the AIAPI library
public struct AIAPI {
    /// The API key used for authentication
    private let apiKey: String
    
    /// Creates a new AIAPI instance
    /// - Parameter apiKey: The API key to use for authentication
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// Creates a client for a specific AI model provider
    /// - Parameter provider: The AI model provider to use
    /// - Returns: A client for the specified provider
    public func createClient(provider: ModelProvider) -> AIClient {
        switch provider {
        case .openAI:
            return OpenAIClient(apiKey: apiKey)
        case .anthropic:
            return AnthropicClient(apiKey: apiKey)
        case .google:
            return GoogleClient(apiKey: apiKey)
        }
    }
}

/// Represents an AI model provider
public enum ModelProvider {
    case openAI
    case anthropic
    case google
}
