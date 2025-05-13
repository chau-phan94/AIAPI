# AIAPI

A Swift library for communicating with various AI models, providing a unified interface for OpenAI (GPT), Anthropic (Claude), and Google (Gemini) models.

## Features

- **Unified Interface**: Communicate with multiple AI providers through a consistent API
- **Model-Specific Strategies**: Optimized prompting techniques for each AI model provider
- **Advanced Prompting Techniques**: Support for various prompting strategies:
  - Clear and specific instructions
  - Logical prompt structure
  - Role definition
  - Output format control
  - Chain thinking for better reasoning
  - Few-shot learning with examples
  - Chain of prompts for complex tasks
  - Reflection and refinement approaches
- **Pre-built Templates**: Ready-to-use templates for common tasks:
  - Coding tasks
  - Data analysis
  - Creative writing
  - Research summaries
  - Product descriptions
- **Async/Await Support**: Modern Swift concurrency support for iOS 13+ and macOS 10.15+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/chau-phan94/AIAPI.git", from: "1.0.0")
]
```

## Usage

### Basic Usage

```swift
import AIAPI

// Initialize with your API key
let aiapi = AIAPI(apiKey: "your-api-key")

// Create a client for your preferred AI provider
let client = aiapi.createClient(provider: .openAI)

// Create a prompt
let prompt = Prompt(
    content: "Explain quantum computing in simple terms",
    strategy: .clearInstructions
)

// Set request options
let options = RequestOptions(
    maxTokens: 500,
    temperature: 0.7,
    model: "gpt-4"
)

// Send the prompt and handle the response
client.sendPrompt(prompt, options: options) { result in
    switch result {
    case .success(let response):
        print("Response: \(response.content)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### Using Templates

```swift
// Create a prompt using a template
let prompt = Prompt.fromTemplate(
    PromptTemplates.coding,
    variables: [
        "language": "Swift",
        "description": "Create a function that calculates the Fibonacci sequence",
        "requirements": "- Function should be efficient\n- Handle edge cases\n- Include documentation"
    ]
)
```

### Async/Await Support

```swift
// Available on iOS 13+ and macOS 10.15+
do {
    let response = try await client.sendPrompt(prompt, options: options)
    print("Response: \(response.content)")
} catch {
    print("Error: \(error)")
}
```

### Advanced Prompting Techniques

```swift
// Few-shot learning example
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
```

## Core Principles

### Clear and Specific Instructions

Provide detailed, unambiguous instructions to the AI model to get more accurate responses.

### Logical Prompt Structure

Organize prompts in a logical sequence to guide the AI's thinking process.

### Defining the AI's Role

Specify the role or perspective the AI should adopt when responding.

### Controlling Output Format

Define the exact format you want for the AI's response.

### Chain Thinking

Guide the AI to break down complex problems into steps for better reasoning.

## Model-Specific Strategies

The library automatically applies optimized prompting techniques based on the AI provider:

### OpenAI (GPT)

- Uses the chat completions API with system and user messages
- Optimized for GPT-3.5 and GPT-4 models

### Anthropic (Claude)

- Uses Claude's XML-based instruction format
- Optimized for Claude 3 models (Opus, Sonnet, Haiku)

### Google (Gemini)

- Uses Gemini's content generation API
- Optimized for Gemini Pro and Ultra models

## License

MIT

## Requirements

- Swift 6.0+
- iOS 13.0+ / macOS 10.15+ for async/await support
