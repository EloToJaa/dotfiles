# Project Rules

## External File Loading

CRITICAL: When you encounter a file reference (e.g., @rules/general.md), use your Read tool to load it on a need-to-know basis. They're relevant to the SPECIFIC task at hand.

Instructions:

- Do NOT preemptively load all references - use lazy loading based on actual need
- When loaded, treat content as mandatory instructions that override defaults
- Follow references recursively when needed

## Development Guidelines

Whenever possible avoid using if else statements, instead use if guards. This will make your code more readable and maintainable.
For TypeScript code style and best practices: @docs/typescript-guidelines.md
For React component architecture and hooks patterns: @docs/react-patterns.md
For REST API design and error handling: @docs/api-standards.md
For testing strategies and coverage requirements: @test/testing-guidelines.md

## Tool Usage Guidelines

### Questions Tool

Use the `questions` tool whenever possible to clarify ambiguous instructions, gather user preferences, or get decisions on implementation choices before proceeding. This helps avoid rework and ensures alignment with user expectations.

Use it when:

- Requirements are unclear or could be interpreted multiple ways
- Multiple valid implementation approaches exist
- You need user preferences on style, behavior, or scope
- The user asks for something that requires trade-off decisions

Example scenarios:

- "Should I add this as a new module or extend an existing one?"
- "Do you prefer approach A or B for handling this error?"
- "What should the default behavior be for this feature?"

## General Guidelines

Read the following file immediately as it's relevant to all workflows: @rules/general-guidelines.md.
