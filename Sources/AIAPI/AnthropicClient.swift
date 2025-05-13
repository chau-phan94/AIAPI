// AnthropicClient - Client for Anthropic (Claude) models
import Foundation

/// Client for Anthropic (Claude) models
public class AnthropicClient: AIClient {
    /// The API key used for authentication
    public let apiKey: String
    
    /// The base URL for the Anthropic API
    private let baseURL = "https://api.anthropic.com/v1"
    
    /// Creates a new Anthropic client
    /// - Parameter apiKey: The API key to use for authentication
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// Sends a prompt to the Anthropic model and returns the response
    /// - Parameters:
    ///   - prompt: The prompt to send
    ///   - options: Additional options for the request
    ///   - completion: Callback with the result
    public func sendPrompt(_ prompt: Prompt, options: RequestOptions, completion: @escaping (Result<AIResponse, Error>) -> Void) {
        // Prepare the request
        let url = URL(string: "\(baseURL)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "X-Api-Key")
        request.addValue("anthropic-swift/1.0.0", forHTTPHeaderField: "X-Client-User-Agent")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Apply Anthropic-specific prompt strategy
        let formattedPrompt = applyPromptStrategy(prompt)
        
        // Prepare the request body
        var body: [String: Any] = [
            "messages": [
                ["role": "user", "content": formattedPrompt]
            ],
            "model": options.model ?? "claude-3-opus-20240229"
        ]
        
        // Add optional parameters if provided
        if let maxTokens = options.maxTokens {
            body["max_tokens"] = maxTokens
        }
        
        if let temperature = options.temperature {
            body["temperature"] = temperature
        }
        
        // Add any additional parameters
        for (key, value) in options.additionalParameters {
            body[key] = value
        }
        
        // Serialize the request body
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(AIClientError.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(AIClientError.invalidResponse))
                return
            }
            
            do {
                // Parse the response
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let content = json["content"] as? [[String: Any]],
                   let firstContent = content.first,
                   let text = firstContent["text"] as? String {
                    
                    // Extract metadata
                    var metadata: [String: Any] = [:]
                    if let usage = json["usage"] as? [String: Any] {
                        metadata["usage"] = usage
                    }
                    if let model = json["model"] as? String {
                        metadata["model"] = model
                    }
                    
                    let response = AIResponse(content: text, metadata: metadata)
                    completion(.success(response))
                } else {
                    // Check for error
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let error = json["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        completion(.failure(AIClientError.apiError(message)))
                    } else {
                        completion(.failure(AIClientError.invalidResponse))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    /// Sends a prompt to the Anthropic model and returns the response (async version)
    /// - Parameters:
    ///   - prompt: The prompt to send
    ///   - options: Additional options for the request
    /// - Returns: The AI response
    @available(macOS 10.15, iOS 13.0, *)
    public func sendPrompt(_ prompt: Prompt, options: RequestOptions) async throws -> AIResponse {
        return try await withCheckedThrowingContinuation { continuation in
            sendPrompt(prompt, options: options) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Applies the prompt strategy to the prompt content
    /// - Parameter prompt: The prompt to apply the strategy to
    /// - Returns: A formatted prompt string for the Anthropic API
    private func applyPromptStrategy(_ prompt: Prompt) -> String {
        // Anthropic-specific prompt formatting
        switch prompt.strategy {
        case .standard:
            return prompt.content
            
        case .clearInstructions:
            return """
            I need you to follow these instructions exactly:
            
            \(prompt.content)
            """
            
        case .logicalStructure:
            return """
            Please respond to the following structured information with a similarly structured response:
            
            \(prompt.content)
            """
            
        case .roleDefinition:
            return """
            <instructions>
            Please adopt the role and perspective described below.
            </instructions>
            
            \(prompt.content)
            """
            
        case .outputFormat:
            return """
            <instructions>
            Please format your response exactly as specified below.
            </instructions>
            
            \(prompt.content)
            """
            
        case .chainThinking:
            return """
            <instructions>
            Think through this step by step, showing your reasoning clearly.
            </instructions>
            
            \(prompt.content)
            """
            
        case .fewShot:
            return """
            <instructions>
            I will provide examples to demonstrate the pattern I want you to follow.
            </instructions>
            
            \(prompt.content)
            """
            
        case .chainOfPrompts:
            return """
            <instructions>
            This is part of a series of related prompts. Please maintain context from previous interactions.
            </instructions>
            
            \(prompt.content)
            """
            
        case .reflectionRefinement:
            return """
            <instructions>
            After your initial response, please reflect on it and provide a refined version.
            </instructions>
            
            \(prompt.content)
            """
            
        case .custom(let instruction):
            return """
            <instructions>
            \(instruction)
            </instructions>
            
            \(prompt.content)
            """
        }
    }
}
