// AIModel - Enumeration of available AI models
import Foundation

/// Represents available AI models across different providers
public enum AIModel {
    /// OpenAI models
    public enum OpenAI: String, CaseIterable {
        case gpt4 = "gpt-4"
        case gpt4Turbo = "gpt-4-turbo"
        case gpt4TurboPreview = "gpt-4-turbo-preview"
        case gpt35Turbo = "gpt-3.5-turbo"
        case gpt35TurboInstruct = "gpt-3.5-turbo-instruct"
        
        /// Returns the model identifier string
        public var identifier: String {
            return self.rawValue
        }
    }
    
    /// Anthropic models
    public enum Anthropic: String, CaseIterable {
        case claude3Opus = "claude-3-opus-20240229"
        case claude3Sonnet = "claude-3-sonnet-20240229"
        case claude3Haiku = "claude-3-haiku-20240307"
        case claude2 = "claude-2.1"
        case claude1 = "claude-1"
        
        /// Returns the model identifier string
        public var identifier: String {
            return self.rawValue
        }
    }
    
    /// Google models
    public enum Google: String, CaseIterable {
        case geminiPro = "gemini-pro"
        case geminiProVision = "gemini-pro-vision"
        case geminiUltra = "gemini-ultra"
        
        /// Returns the model identifier string
        public var identifier: String {
            return self.rawValue
        }
    }
    
    /// Returns all available models for a specific provider
    /// - Parameter provider: The AI model provider
    /// - Returns: Array of model identifiers for the provider
    public static func availableModels(for provider: ModelProvider) -> [String] {
        switch provider {
        case .openAI:
            return OpenAI.allCases.map { $0.identifier }
        case .anthropic:
            return Anthropic.allCases.map { $0.identifier }
        case .google:
            return Google.allCases.map { $0.identifier }
        }
    }
    
    /// Validates if a model identifier is valid for a specific provider
    /// - Parameters:
    ///   - modelId: The model identifier to validate
    ///   - provider: The AI model provider
    /// - Returns: True if the model is valid for the provider
    public static func isValidModel(_ modelId: String, for provider: ModelProvider) -> Bool {
        return availableModels(for: provider).contains(modelId)
    }
}
