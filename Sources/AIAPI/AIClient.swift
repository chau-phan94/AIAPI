// AIClient - Protocol for AI model clients
import Foundation

/// Protocol that all AI clients must conform to
public protocol AIClient {
    /// The API key used for authentication
    var apiKey: String { get }
    
    /// Sends a prompt to the AI model and returns the response
    /// - Parameters:
    ///   - prompt: The prompt to send
    ///   - options: Additional options for the request
    ///   - completion: Callback with the result
    func sendPrompt(_ prompt: Prompt, options: RequestOptions, completion: @escaping (Result<AIResponse, Error>) -> Void)
    
    /// Sends a prompt to the AI model and returns the response (async version)
    /// - Parameters:
    ///   - prompt: The prompt to send
    ///   - options: Additional options for the request
    /// - Returns: The AI response
    @available(macOS 10.15, iOS 13.0, *)
    func sendPrompt(_ prompt: Prompt, options: RequestOptions) async throws -> AIResponse
}

/// Represents a prompt to send to an AI model
public struct Prompt {
    /// The content of the prompt
    public let content: String
    
    /// The strategy to use for the prompt
    public let strategy: PromptStrategy
    
    /// Creates a new prompt
    /// - Parameters:
    ///   - content: The content of the prompt
    ///   - strategy: The strategy to use for the prompt
    public init(content: String, strategy: PromptStrategy = .standard) {
        self.content = content
        self.strategy = strategy
    }
    
    /// Creates a prompt from a template
    /// - Parameters:
    ///   - template: The template to use
    ///   - variables: The variables to substitute in the template
    /// - Returns: A new prompt
    public static func fromTemplate(_ template: PromptTemplate, variables: [String: String]) -> Prompt {
        var content = template.content
        
        for (key, value) in variables {
            content = content.replacingOccurrences(of: "{\(key)}", with: value)
        }
        
        return Prompt(content: content, strategy: template.strategy)
    }
}

/// Represents a response from an AI model
public struct AIResponse {
    /// The content of the response
    public let content: String
    
    /// Additional metadata about the response
    public let metadata: [String: Any]
    
    /// Creates a new AI response
    /// - Parameters:
    ///   - content: The content of the response
    ///   - metadata: Additional metadata about the response
    public init(content: String, metadata: [String: Any] = [:]) {
        self.content = content
        self.metadata = metadata
    }
}

/// Options for an AI request
public struct RequestOptions {
    /// The maximum number of tokens to generate
    public let maxTokens: Int?
    
    /// The temperature to use for generation
    public let temperature: Double?
    
    /// The model to use (string identifier)
    public let model: String?
    
    /// Additional parameters specific to the provider
    public let additionalParameters: [String: Any]
    
    /// Creates new request options
    /// - Parameters:
    ///   - maxTokens: The maximum number of tokens to generate
    ///   - temperature: The temperature to use for generation
    ///   - model: The model to use (string identifier)
    ///   - additionalParameters: Additional parameters specific to the provider
    public init(maxTokens: Int? = nil, temperature: Double? = nil, model: String? = nil, additionalParameters: [String: Any] = [:]) {
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.model = model
        self.additionalParameters = additionalParameters
    }
    
    /// Creates new request options with an OpenAI model
    /// - Parameters:
    ///   - model: The OpenAI model to use
    ///   - maxTokens: The maximum number of tokens to generate
    ///   - temperature: The temperature to use for generation
    ///   - additionalParameters: Additional parameters specific to the provider
    public init(model: AIModel.OpenAI, maxTokens: Int? = nil, temperature: Double? = nil, additionalParameters: [String: Any] = [:]) {
        self.init(maxTokens: maxTokens, temperature: temperature, model: model.identifier, additionalParameters: additionalParameters)
    }
    
    /// Creates new request options with an Anthropic model
    /// - Parameters:
    ///   - model: The Anthropic model to use
    ///   - maxTokens: The maximum number of tokens to generate
    ///   - temperature: The temperature to use for generation
    ///   - additionalParameters: Additional parameters specific to the provider
    public init(model: AIModel.Anthropic, maxTokens: Int? = nil, temperature: Double? = nil, additionalParameters: [String: Any] = [:]) {
        self.init(maxTokens: maxTokens, temperature: temperature, model: model.identifier, additionalParameters: additionalParameters)
    }
    
    /// Creates new request options with a Google model
    /// - Parameters:
    ///   - model: The Google model to use
    ///   - maxTokens: The maximum number of tokens to generate
    ///   - temperature: The temperature to use for generation
    ///   - additionalParameters: Additional parameters specific to the provider
    public init(model: AIModel.Google, maxTokens: Int? = nil, temperature: Double? = nil, additionalParameters: [String: Any] = [:]) {
        self.init(maxTokens: maxTokens, temperature: temperature, model: model.identifier, additionalParameters: additionalParameters)
    }
}

/// Error types for AI clients
public enum AIClientError: Error {
    case invalidResponse
    case networkError(Error)
    case apiError(String)
    case invalidAPIKey
}
