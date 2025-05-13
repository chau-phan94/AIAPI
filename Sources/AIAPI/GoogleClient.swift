// GoogleClient - Client for Google (Gemini) models
import Foundation

/// Client for Google (Gemini) models
public class GoogleClient: AIClient {
    /// The API key used for authentication
    public let apiKey: String
    
    /// The base URL for the Google AI API
    private let baseURL = "https://generativelanguage.googleapis.com/v1"
    
    /// Creates a new Google client
    /// - Parameter apiKey: The API key to use for authentication
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// Sends a prompt to the Google model and returns the response
    /// - Parameters:
    ///   - prompt: The prompt to send
    ///   - options: Additional options for the request
    ///   - completion: Callback with the result
    public func sendPrompt(_ prompt: Prompt, options: RequestOptions, completion: @escaping (Result<AIResponse, Error>) -> Void) {
        // Get the model name
        let model = options.model ?? "gemini-pro"
        
        // Prepare the request
        let url = URL(string: "\(baseURL)/models/\(model):generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Apply Google-specific prompt strategy
        let formattedPrompt = applyPromptStrategy(prompt)
        
        // Prepare the request body
        var body: [String: Any] = [
            "contents": [
                ["parts": [["text": formattedPrompt]]]
            ]
        ]
        
        // Add optional parameters if provided
        if let temperature = options.temperature {
            body["generationConfig"] = ["temperature": temperature]
        }
        
        if let maxTokens = options.maxTokens {
            if var generationConfig = body["generationConfig"] as? [String: Any] {
                generationConfig["maxOutputTokens"] = maxTokens
                body["generationConfig"] = generationConfig
            } else {
                body["generationConfig"] = ["maxOutputTokens": maxTokens]
            }
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
                   let candidates = json["candidates"] as? [[String: Any]],
                   let firstCandidate = candidates.first,
                   let content = firstCandidate["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let firstPart = parts.first,
                   let text = firstPart["text"] as? String {
                    
                    // Extract metadata
                    var metadata: [String: Any] = [:]
                    if let usageMetadata = json["usageMetadata"] as? [String: Any] {
                        metadata["usageMetadata"] = usageMetadata
                    }
                    metadata["model"] = model
                    
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
    
    /// Sends a prompt to the Google model and returns the response (async version)
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
    /// - Returns: A formatted prompt string for the Google API
    private func applyPromptStrategy(_ prompt: Prompt) -> String {
        // Google-specific prompt formatting
        switch prompt.strategy {
        case .standard:
            return prompt.content
            
        case .clearInstructions:
            return """
            Instructions: I need you to follow these instructions exactly.
            
            \(prompt.content)
            """
            
        case .logicalStructure:
            return """
            Please respond to the following structured information with a similarly structured response:
            
            \(prompt.content)
            """
            
        case .roleDefinition:
            return """
            Role: Please adopt the role and perspective described below.
            
            \(prompt.content)
            """
            
        case .outputFormat:
            return """
            Output Format: Please format your response exactly as specified below.
            
            \(prompt.content)
            """
            
        case .chainThinking:
            return """
            Think step by step:
            
            \(prompt.content)
            """
            
        case .fewShot:
            return """
            Examples: I will provide examples to demonstrate the pattern I want you to follow.
            
            \(prompt.content)
            """
            
        case .chainOfPrompts:
            return """
            Context: This is part of a series of related prompts. Please maintain context from previous interactions.
            
            \(prompt.content)
            """
            
        case .reflectionRefinement:
            return """
            Instructions: After your initial response, please reflect on it and provide a refined version.
            
            \(prompt.content)
            """
            
        case .custom(let instruction):
            return """
            \(instruction)
            
            \(prompt.content)
            """
        }
    }
}
