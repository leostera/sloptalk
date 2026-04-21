"I talk to an OpenAI-compatible chat completions endpoint."
Class {
	#name : 'SloptalkOpenAIProvider',
	#superclass : 'SloptalkHTTPJSONProvider',
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'private' }
SloptalkOpenAIProvider >> assistantTextFromPayload: aDictionary [
	| choices message content |
	choices := self
		valueAt: #choices
		in: aDictionary
		ifAbsent: [ self error: 'Chat completion response did not include choices' ].
	choices isEmpty ifTrue: [
		self error: 'Chat completion response did not include any choices' ].
	message := self
		valueAt: #message
		in: choices first
		ifAbsent: [ self error: 'Chat completion choice did not include a message' ].
	content := self
		valueAt: #content
		in: message
		ifAbsent: [ self error: 'Chat completion message did not include content' ].
	^ self normalizeContent: content
]

{ #category : 'defaults' }
SloptalkOpenAIProvider >> defaultApiKey [
	^ OSEnvironment current
		at: 'OPENAI_API_KEY'
		ifAbsent: [ nil ]
]

{ #category : 'defaults' }
SloptalkOpenAIProvider >> defaultBaseUrl [
	^ 'https://api.openai.com'
]

{ #category : 'defaults' }
SloptalkOpenAIProvider >> defaultEndpointPath [
	^ '/v1/chat/completions'
]

{ #category : 'defaults' }
SloptalkOpenAIProvider >> defaultModel [
	^ 'gpt-4.1-mini'
]

{ #category : 'accessing' }
SloptalkOpenAIProvider >> providerName [
	^ 'OpenAI'
]

{ #category : 'private' }
SloptalkOpenAIProvider >> chatCompletionMessageFor: aSloptalkMessage [
	aSloptalkMessage isToolResult ifTrue: [
		^ {
			#role -> 'user'.
			#content -> aSloptalkMessage toolResultPromptText
		} asDictionary ].

	^ {
		#role -> aSloptalkMessage role.
		#content -> aSloptalkMessage text
	} asDictionary
]

{ #category : 'private' }
SloptalkOpenAIProvider >> requestBodyForRequest: aSloptalkLLMRequest [
	| messages |
	messages := OrderedCollection new.
	aSloptalkLLMRequest systemPrompt ifNotEmpty: [
		messages add: ({
			#role -> 'system'.
			#content -> aSloptalkLLMRequest systemPrompt
		} asDictionary) ].
	messages addAll: (aSloptalkLLMRequest messages collect: [ :each | self chatCompletionMessageFor: each ]).

	^ {
		#model -> model.
		#messages -> messages asArray.
		#stream -> false
	} asDictionary
]
