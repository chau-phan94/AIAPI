// AIAPIDemo - A demonstration of how to use the AIAPI library
import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// A demonstration of how to use the AIAPI library in a real-world application
public struct AIAPIDemo {
    /// The AIAPI instance
    private let aiapi: AIAPI
    
    /// Creates a new AIAPIDemo instance
    /// - Parameter apiKey: The API key to use for authentication
    public init(apiKey: String) {
        self.aiapi = AIAPI(apiKey: apiKey)
    }
    
    /// Demonstrates how to use the AIAPI library to generate code
    /// - Parameters:
    ///   - language: The programming language to generate code for
    ///   - description: A description of what the code should do
    ///   - completion: Callback with the generated code
    public func generateCode(language: String, description: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Create a client for OpenAI
        let client = aiapi.createClient(provider: .openAI)
        
        // Use the coding template
        let prompt = Prompt.fromTemplate(
            PromptTemplates.coding,
            variables: [
                "language": language,
                "description": description,
                "requirements": "- Clean, readable code\n- Well-commented\n- Efficient implementation"
            ]
        )
        
        // Set options optimized for code generation
        let options = RequestOptions(
            model: AIModel.OpenAI.gpt4Turbo,
            temperature: 0.2,  // Lower temperature for more deterministic code
            additionalParameters: ["response_format": ["type": "text"]]
        )
        
        // Send the prompt
        client.sendPrompt(prompt, options: options) { result in
            switch result {
            case .success(let response):
                completion(.success(response.content))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Demonstrates how to use the AIAPI library to analyze text sentiment
    /// - Parameters:
    ///   - text: The text to analyze
    ///   - completion: Callback with the sentiment analysis
    public func analyzeSentiment(text: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Create a client for Claude (Anthropic)
        let client = aiapi.createClient(provider: .anthropic)
        
        // Create a few-shot prompt for sentiment analysis
        let prompt = Prompt(
            content: """
            I want you to classify the sentiment of the following text as positive, negative, or neutral.
            
            Examples:
            Text: "I love this product, it's amazing!"
            Sentiment: positive
            
            Text: "This is the worst experience I've ever had."
            Sentiment: negative
            
            Text: "The package arrived on time."
            Sentiment: neutral
            
            Now classify this text:
            "\(text)"
            """,
            strategy: .fewShot
        )
        
        // Set options optimized for classification
        let options = RequestOptions(
            model: AIModel.Anthropic.claude3Sonnet,
            temperature: 0.0  // Zero temperature for deterministic classification
        )
        
        // Send the prompt
        client.sendPrompt(prompt, options: options) { result in
            switch result {
            case .success(let response):
                completion(.success(response.content))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Demonstrates how to use the AIAPI library to generate a creative story
    /// - Parameters:
    ///   - topic: The topic of the story
    ///   - genre: The genre of the story
    ///   - length: The desired length of the story
    ///   - completion: Callback with the generated story
    public func generateStory(topic: String, genre: String, length: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Create a client for Gemini (Google)
        let client = aiapi.createClient(provider: .google)
        
        // Use the creative writing template
        let prompt = Prompt.fromTemplate(
            PromptTemplates.creativeWriting,
            variables: [
                "genre": genre,
                "topic": topic,
                "style": "engaging and descriptive",
                "length": length,
                "requirements": "Include dialogue and vivid descriptions"
            ]
        )
        
        // Set options optimized for creative writing
        let options = RequestOptions(
            model: AIModel.Google.geminiPro,
            temperature: 0.8  // Higher temperature for more creative outputs
        )
        
        // Send the prompt
        client.sendPrompt(prompt, options: options) { result in
            switch result {
            case .success(let response):
                completion(.success(response.content))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Demonstrates how to use the AIAPI library with async/await
    /// - Parameters:
    ///   - query: The research query
    /// - Returns: The research summary
    @available(macOS 10.15, iOS 13.0, *)
    public func researchTopic(query: String) async throws -> String {
        // Create a client for OpenAI
        let client = aiapi.createClient(provider: .openAI)
        
        // Use the research summary template
        let prompt = Prompt.fromTemplate(
            PromptTemplates.researchSummary,
            variables: [
                "topic": query,
                "focusAreas": "Recent developments, practical applications, and future directions",
                "timeframe": "5 years"
            ]
        )
        
        // Set options optimized for research
        let options = RequestOptions(
            model: AIModel.OpenAI.gpt4Turbo,
            maxTokens: 1000,
            temperature: 0.3
        )
        
        // Send the prompt and await the response
        let response = try await client.sendPrompt(prompt, options: options)
        return response.content
    }
    
    /// Demonstrates how to compare responses from different AI models
    /// - Parameters:
    ///   - question: The question to ask
    ///   - completion: Callback with the comparison results
    public func compareModels(question: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
        // Create clients for each provider
        let openAIClient = aiapi.createClient(provider: .openAI)
        let anthropicClient = aiapi.createClient(provider: .anthropic)
        let googleClient = aiapi.createClient(provider: .google)
        
        // Create a standard prompt
        let prompt = Prompt(content: question)
        
        /// Standard options for all providers
        let openAIOptions = RequestOptions(model: AIModel.OpenAI.gpt4Turbo.identifier)
        let anthropicOptions = RequestOptions(model: AIModel.Anthropic.claude3Opus.identifier)
        let googleOptions = RequestOptions(model: AIModel.Google.geminiPro.identifier)
        
        // Track responses
        var responses: [String: String] = [:]
        var errors: [Error] = []
        let group = DispatchGroup()
        
        // OpenAI request
        group.enter()
        openAIClient.sendPrompt(prompt, options: openAIOptions) { result in
            switch result {
            case .success(let response):
                responses["OpenAI"] = response.content
            case .failure(let error):
                errors.append(error)
            }
            group.leave()
        }
        
        // Anthropic request
        group.enter()
        anthropicClient.sendPrompt(prompt, options: anthropicOptions) { result in
            switch result {
            case .success(let response):
                responses["Anthropic"] = response.content
            case .failure(let error):
                errors.append(error)
            }
            group.leave()
        }
        
        // Google request
        group.enter()
        googleClient.sendPrompt(prompt, options: googleOptions) { result in
            switch result {
            case .success(let response):
                responses["Google"] = response.content
            case .failure(let error):
                errors.append(error)
            }
            group.leave()
        }
        
        // Wait for all requests to complete
        group.notify(queue: .main) {
            if !errors.isEmpty {
                completion(.failure(errors.first!))
            } else {
                completion(.success(responses))
            }
        }
    }
    
    /// Demonstrates how to generate an image using DALL-E through OpenAI
    /// - Parameters:
    ///   - prompt: The description of the image to generate
    ///   - size: The size of the image (e.g., "1024x1024")
    ///   - completion: Callback with the result containing image URL or error
    public func generateImage(prompt: String, size: String = "1024x1024", completion: @escaping (Result<String, Error>) -> Void) {
        // Create a client for OpenAI
        let client = aiapi.createClient(provider: .openAI)
        
        // Create a prompt for image generation
        let imagePrompt = Prompt(
            content: prompt,
            strategy: .clearInstructions
        )
        
        // Set options for image generation
        let options = RequestOptions(
            additionalParameters: [
                "endpoint": "images/generations",
                "size": size,
                "n": 1,
                "response_format": "url"
            ]
        )
        
        // Send the prompt
        client.sendPrompt(imagePrompt, options: options) { result in
            switch result {
            case .success(let response):
                if let imageUrl = response.metadata["image_url"] as? String {
                    completion(.success(imageUrl))
                } else {
                    completion(.failure(AIClientError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Demonstrates how to use streaming responses with OpenAI
    /// - Parameters:
    ///   - prompt: The prompt to send
    ///   - chunkHandler: Handler for each chunk of the response
    ///   - completion: Callback when the stream is complete
    @available(macOS 10.15, iOS 13.0, *)
    public func streamResponse(prompt: String, chunkHandler: @escaping (String) -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
        // Create a client for OpenAI
        let client = aiapi.createClient(provider: .openAI)
        
        // Create a simple prompt
        let streamPrompt = Prompt(content: prompt)
        
        // Set options for streaming
        let options = RequestOptions(
            model: AIModel.OpenAI.gpt4Turbo,
            additionalParameters: [
                "stream": true,
                "onChunk": { (chunk: String) in
                    chunkHandler(chunk)
                }
            ]
        )
        
        // Send the prompt with streaming
        client.sendPrompt(streamPrompt, options: options) { result in
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Demonstrates how to use function calling with OpenAI
    /// - Parameters:
    ///   - query: The user query that might trigger a function call
    ///   - completion: Callback with the result
    public func demonstrateFunctionCalling(query: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Create a client for OpenAI
        let client = aiapi.createClient(provider: .openAI)
        
        // Define available functions
        let functions = [
            [
                "name": "get_weather",
                "description": "Get the current weather in a given location",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "location": [
                            "type": "string",
                            "description": "The city and state, e.g. San Francisco, CA"
                        ],
                        "unit": [
                            "type": "string",
                            "enum": ["celsius", "fahrenheit"]
                        ]
                    ],
                    "required": ["location"]
                ]
            ]
        ]
        
        // Create a prompt
        let functionPrompt = Prompt(content: query)
        
        // Set options with function calling
        let options = RequestOptions(
            model: AIModel.OpenAI.gpt4Turbo,
            additionalParameters: [
                "functions": functions,
                "function_call": "auto"
            ]
        )
        
        // Send the prompt
        client.sendPrompt(functionPrompt, options: options) { result in
            switch result {
            case .success(let response):
                // Check if a function was called
                if let functionCall = response.metadata["function_call"] as? [String: Any],
                   let functionName = functionCall["name"] as? String,
                   let arguments = functionCall["arguments"] as? String {
                    
                    // In a real implementation, you would call the actual function here
                    // For this demo, we'll just return information about the function call
                    let result = "Function called: \(functionName) with arguments: \(arguments)"
                    completion(.success(result))
                } else {
                    // No function was called, just return the response
                    completion(.success(response.content))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
