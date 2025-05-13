// AIAPIDemo - A demonstration of how to use the AIAPI library
import Foundation

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
            temperature: 0.2,  // Lower temperature for more deterministic code
            model: "gpt-4"     // Use GPT-4 for better code quality
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
            temperature: 0.0,  // Zero temperature for deterministic classification
            model: "claude-3-sonnet-20240229"  // Use a smaller, faster model for simple tasks
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
            temperature: 0.8,  // Higher temperature for more creative outputs
            model: "gemini-pro"
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
            maxTokens: 1000,
            temperature: 0.3,
            model: "gpt-4"
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
        
        // Standard options for all providers
        let openAIOptions = RequestOptions(model: "gpt-4")
        let anthropicOptions = RequestOptions(model: "claude-3-opus-20240229")
        let googleOptions = RequestOptions(model: "gemini-pro")
        
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
}
