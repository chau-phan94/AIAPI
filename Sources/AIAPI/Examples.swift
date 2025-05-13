// Examples - Usage examples for the AIAPI library
import Foundation

/// Examples of how to use the AIAPI library
public struct Examples {
    /// Example of using the OpenAI client
    public static func openAIExample(apiKey: String) {
        // Create an instance of AIAPI
        let aiapi = AIAPI(apiKey: apiKey)
        
        // Create an OpenAI client
        let client = aiapi.createClient(provider: .openAI)
        
        // Create a prompt
        let prompt = Prompt(
            content: "Explain the concept of prompt engineering in simple terms.",
            strategy: .clearInstructions
        )
        
        // Create request options
        let options = RequestOptions(
            maxTokens: 500,
            temperature: 0.7,
            model: "gpt-4"
        )
        
        // Send the prompt
        client.sendPrompt(prompt, options: options) { result in
            switch result {
            case .success(let response):
                print("Response: \(response.content)")
                print("Metadata: \(response.metadata)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    /// Example of using the Anthropic client
    public static func anthropicExample(apiKey: String) {
        // Create an instance of AIAPI
        let aiapi = AIAPI(apiKey: apiKey)
        
        // Create an Anthropic client
        let client = aiapi.createClient(provider: .anthropic)
        
        // Create a prompt using a template
        let prompt = Prompt.fromTemplate(
            PromptTemplates.coding,
            variables: [
                "language": "Swift",
                "description": "Create a function that calculates the Fibonacci sequence",
                "requirements": "- Function should be efficient\n- Handle edge cases\n- Include documentation"
            ]
        )
        
        // Create request options
        let options = RequestOptions(
            maxTokens: 1000,
            temperature: 0.5,
            model: "claude-3-opus-20240229"
        )
        
        // Send the prompt
        client.sendPrompt(prompt, options: options) { result in
            switch result {
            case .success(let response):
                print("Response: \(response.content)")
                print("Metadata: \(response.metadata)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    /// Example of using the Google client with async/await
    @available(macOS 10.15, iOS 13.0, *)
    public static func googleExampleAsync(apiKey: String) async {
        // Create an instance of AIAPI
        let aiapi = AIAPI(apiKey: apiKey)
        
        // Create a Google client
        let client = aiapi.createClient(provider: .google)
        
        // Create a prompt with chain thinking strategy
        let prompt = Prompt(
            content: "What are the implications of quantum computing for cryptography?",
            strategy: .chainThinking
        )
        
        // Create request options
        let options = RequestOptions(
            maxTokens: 800,
            temperature: 0.2,
            model: "gemini-pro"
        )
        
        do {
            // Send the prompt
            let response = try await client.sendPrompt(prompt, options: options)
            print("Response: \(response.content)")
            print("Metadata: \(response.metadata)")
        } catch {
            print("Error: \(error)")
        }
    }
    
    /// Example of using advanced prompting techniques
    public static func advancedPromptingExample(apiKey: String) {
        // Create an instance of AIAPI
        let aiapi = AIAPI(apiKey: apiKey)
        
        // Create an OpenAI client
        let client = aiapi.createClient(provider: .openAI)
        
        // Create a few-shot prompt
        let fewShotPrompt = Prompt(
            content: """
            I want you to classify the sentiment of text as positive, negative, or neutral.
            
            Examples:
            Text: "I love this product, it's amazing!"
            Sentiment: positive
            
            Text: "This is the worst experience I've ever had."
            Sentiment: negative
            
            Text: "The package arrived on time."
            Sentiment: neutral
            
            Now classify this text:
            "The food was okay, but the service was terrible."
            """,
            strategy: .fewShot
        )
        
        // Create request options
        let options = RequestOptions(
            temperature: 0.0,  // Low temperature for deterministic responses
            model: "gpt-4"
        )
        
        // Send the prompt
        client.sendPrompt(fewShotPrompt, options: options) { result in
            switch result {
            case .success(let response):
                print("Response: \(response.content)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    /// Example of using custom prompt strategies
    public static func customStrategyExample(apiKey: String) {
        // Create an instance of AIAPI
        let aiapi = AIAPI(apiKey: apiKey)
        
        // Create an Anthropic client
        let client = aiapi.createClient(provider: .anthropic)
        
        // Create a prompt with custom strategy
        let customPrompt = Prompt(
            content: "Design a database schema for a social media application.",
            strategy: .custom("""
            You are a senior database architect with 20 years of experience.
            Provide a detailed, professional response with diagrams and explanations.
            Consider scalability, performance, and security in your design.
            """)
        )
        
        // Create request options
        let options = RequestOptions(
            maxTokens: 2000,
            model: "claude-3-opus-20240229"
        )
        
        // Send the prompt
        client.sendPrompt(customPrompt, options: options) { result in
            switch result {
            case .success(let response):
                print("Response: \(response.content)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    /// Example of using multiple models for comparison
    @available(macOS 10.15, iOS 13.0, *)
    public static func modelComparisonExample(apiKey: String) async {
        // Create an instance of AIAPI
        let aiapi = AIAPI(apiKey: apiKey)
        
        // Create clients for each provider
        let openAIClient = aiapi.createClient(provider: .openAI)
        let anthropicClient = aiapi.createClient(provider: .anthropic)
        let googleClient = aiapi.createClient(provider: .google)
        
        // Create a prompt
        let prompt = Prompt(
            content: "Explain the concept of recursion in programming.",
            strategy: .clearInstructions
        )
        
        // Create request options for each provider using the enum model list
        let openAIOptions = RequestOptions(model: AIModel.OpenAI.gpt4)
        let anthropicOptions = RequestOptions(model: AIModel.Anthropic.claude3Opus)
        let googleOptions = RequestOptions(model: AIModel.Google.geminiPro)
        
        do {
            // Send the prompt to each provider
            async let openAIResponse = openAIClient.sendPrompt(prompt, options: openAIOptions)
            async let anthropicResponse = anthropicClient.sendPrompt(prompt, options: anthropicOptions)
            async let googleResponse = googleClient.sendPrompt(prompt, options: googleOptions)
            
            // Wait for all responses
            let (openAI, anthropic, google) = try await (openAIResponse, anthropicResponse, googleResponse)
            
            // Print the responses
            print("OpenAI Response: \(openAI.content)")
            print("Anthropic Response: \(anthropic.content)")
            print("Google Response: \(google.content)")
        } catch {
            print("Error: \(error)")
        }
    }
}
