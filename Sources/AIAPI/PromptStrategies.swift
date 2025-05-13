// PromptStrategies - Strategies and templates for AI prompts
import Foundation

/// Strategy for structuring prompts
public enum PromptStrategy {
    /// Standard prompting without special structure
    case standard
    
    /// Clear and specific instructions
    case clearInstructions
    
    /// Logical prompt structure with sections
    case logicalStructure
    
    /// Define the AI's role explicitly
    case roleDefinition
    
    /// Control output format
    case outputFormat
    
    /// Chain thinking for better reasoning
    case chainThinking
    
    /// Few-shot learning with examples
    case fewShot
    
    /// Chain of prompts for complex tasks
    case chainOfPrompts
    
    /// Reflection and refinement approaches
    case reflectionRefinement
    
    /// Custom strategy with specific instructions
    case custom(String)
}

/// Template for a prompt
public struct PromptTemplate {
    /// The name of the template
    public let name: String
    
    /// The content of the template
    public let content: String
    
    /// The strategy to use for the template
    public let strategy: PromptStrategy
    
    /// Creates a new prompt template
    /// - Parameters:
    ///   - name: The name of the template
    ///   - content: The content of the template
    ///   - strategy: The strategy to use for the template
    public init(name: String, content: String, strategy: PromptStrategy) {
        self.name = name
        self.content = content
        self.strategy = strategy
    }
}

/// Collection of predefined prompt templates
public struct PromptTemplates {
    /// Templates for coding tasks
    public static let coding = PromptTemplate(
        name: "Coding Task",
        content: """
        I need help with a coding task in {language}.
        
        Task description: {description}
        
        Requirements:
        {requirements}
        
        Please provide a solution with:
        1. Clear, well-commented code
        2. Explanation of your approach
        3. Any potential edge cases or optimizations
        """,
        strategy: .clearInstructions
    )
    
    /// Templates for data analysis
    public static let dataAnalysis = PromptTemplate(
        name: "Data Analysis",
        content: """
        I need to analyze the following data:
        
        {data}
        
        Analysis goals:
        {goals}
        
        Please provide:
        1. Key insights from the data
        2. Statistical analysis where appropriate
        3. Visualizations you would recommend
        4. Actionable recommendations based on findings
        """,
        strategy: .logicalStructure
    )
    
    /// Templates for creative writing
    public static let creativeWriting = PromptTemplate(
        name: "Creative Writing",
        content: """
        You are a creative writer specializing in {genre}.
        
        Topic: {topic}
        Style: {style}
        Length: {length}
        
        Additional requirements:
        {requirements}
        
        Please write a compelling piece that captures the essence of the topic while adhering to the specified style.
        """,
        strategy: .roleDefinition
    )
    
    /// Templates for research summaries
    public static let researchSummary = PromptTemplate(
        name: "Research Summary",
        content: """
        Please provide a comprehensive summary of research on {topic}.
        
        Focus areas:
        {focusAreas}
        
        The summary should include:
        1. Key findings and consensus in the field
        2. Major debates or unresolved questions
        3. Recent developments (within the last {timeframe})
        4. Practical implications or applications
        5. Directions for future research
        
        Format the response as follows:
        - Executive Summary (2-3 sentences)
        - Background
        - Key Findings
        - Debates
        - Recent Developments
        - Implications
        - Future Directions
        - References (if applicable)
        """,
        strategy: .outputFormat
    )
    
    /// Templates for product descriptions
    public static let productDescription = PromptTemplate(
        name: "Product Description",
        content: """
        Create a compelling product description for {productName}.
        
        Product details:
        - Category: {category}
        - Key features: {features}
        - Target audience: {audience}
        - Price point: {price}
        - Unique selling proposition: {usp}
        
        The description should be {tone} in tone and approximately {length} words.
        
        Include:
        1. Attention-grabbing headline
        2. Engaging opening paragraph
        3. Feature-benefit connections
        4. Social proof elements
        5. Clear call to action
        """,
        strategy: .clearInstructions
    )
}
