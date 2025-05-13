// OpenAIClient - Client for OpenAI (GPT) models
import Foundation

/// Client for OpenAI (GPT) models
public class OpenAIClient: AIClient {
    /// The API key used for authentication
    public let apiKey: String
    
    /// The base URL for the OpenAI API
    private let baseURL = "https://api.openai.com/v1"
    
    /// Creates a new OpenAI client
    /// - Parameter apiKey: The API key to use for authentication
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// Sends a prompt to the OpenAI model and returns the response
    /// - Parameters:
    ///   - prompt: The prompt to send
    ///   - options: Additional options for the request
    ///   - completion: Callback with the result
    public func sendPrompt(_ prompt: Prompt, options: RequestOptions, completion: @escaping (Result<AIResponse, Error>) -> Void) {
        // Prepare the request
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Apply OpenAI-specific prompt strategy
        let messages = applyPromptStrategy(prompt)
        
        // Prepare the request body
        var body: [String: Any] = [
            "messages": messages,
            "model": options.model ?? "gpt-4"
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
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    // Extract metadata
                    var metadata: [String: Any] = [:]
                    if let usage = json["usage"] as? [String: Any] {
                        metadata["usage"] = usage
                    }
                    if let model = json["model"] as? String {
                        metadata["model"] = model
                    }
                    
                    let response = AIResponse(content: content, metadata: metadata)
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
    
    /// Sends a prompt to the OpenAI model and returns the response (async version)
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
    /// - Returns: An array of message dictionaries for the OpenAI API
    private func applyPromptStrategy(_ prompt: Prompt) -> [[String: String]] {
        var messages: [[String: String]] = []
        
        // System message based on strategy
        switch prompt.strategy {
        case .standard:
            messages.append(["role": "user", "content": prompt.content])
            
        case .clearInstructions:
            messages.append(["role": "system", "content": "I will provide clear and specific instructions. Please follow them exactly."])
            messages.append(["role": "user", "content": prompt.content])
            
        case .logicalStructure:
            messages.append(["role": "system", "content": "I will provide information in a logical structure. Please respond in a similarly structured format."])
            messages.append(["role": "user", "content": prompt.content])
            
        case .roleDefinition:
            messages.append(["role": "system", "content": "Please adopt the role and perspective described in my prompt."])
            messages.append(["role": "user", "content": prompt.content])
            
        case .outputFormat:
            messages.append(["role": "system", "content": "Please format your response exactly as specified in my prompt."])
            messages.append(["role": "user", "content": prompt.content])
            
        case .chainThinking:
            messages.append(["role": "system", "content": "Please think through this step by step, showing your reasoning clearly."])
            messages.append(["role": "user", "content": prompt.content])
            
        case .fewShot:
            messages.append(["role": "system", "content": "I will provide examples to demonstrate the pattern I want you to follow."])
            messages.append(["role": "user", "content": prompt.content])
            
        case .chainOfPrompts:
            messages.append(["role": "system", "content": "This is part of a series of related prompts. Please maintain context from previous interactions."])
            messages.append(["role": "user", "content": prompt.content])
            
        case .reflectionRefinement:
            messages.append(["role": "system", "content": "After your initial response, please reflect on it and provide a refined version."])
            messages.append(["role": "user", "content": prompt.content])
            
        case .custom(let instruction):
            messages.append(["role": "system", "content": instruction])
            messages.append(["role": "user", "content": prompt.content])
        }
        
        return messages
    }
}
