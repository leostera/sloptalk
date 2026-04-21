"I talk to a local OpenAI-compatible Ollama endpoint."
Class {
	#name : 'SloptalkLocalOllamaProvider',
	#superclass : 'SloptalkOpenAIProvider',
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'defaults' }
SloptalkLocalOllamaProvider >> defaultApiKey [
	^ nil
]

{ #category : 'defaults' }
SloptalkLocalOllamaProvider >> defaultBaseUrl [
	^ 'http://localhost:11434'
]

{ #category : 'defaults' }
SloptalkLocalOllamaProvider >> defaultModel [
	^ 'gemma-4-31B-it-Q8_0.gguf'
]

{ #category : 'accessing' }
SloptalkLocalOllamaProvider >> providerName [
	^ 'Local Ollama'
]
