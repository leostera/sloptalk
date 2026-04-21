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
	| messageItem |
	messageItem := (self outputItemsFromPayload: aDictionary)
		detect: [ :each | each isMessage ]
		ifNone: [ nil ].
	^ messageItem
		ifNil: [ '' ]
		ifNotNil: [ messageItem text ]
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
SloptalkOpenAIProvider >> chatCompletionMessageForInputItem: aSloptalkLLMInputItem [
	aSloptalkLLMInputItem isToolResult ifTrue: [
		^ {
			#role -> 'user'.
			#content -> aSloptalkLLMInputItem toolResultPromptText
		} asDictionary ].

	aSloptalkLLMInputItem isToolCall ifTrue: [
		^ {
			#role -> 'assistant'.
			#content -> aSloptalkLLMInputItem text
		} asDictionary ].

	^ {
		#role -> aSloptalkLLMInputItem role.
		#content -> aSloptalkLLMInputItem text
	} asDictionary
]

{ #category : 'private' }
SloptalkOpenAIProvider >> finishReasonFromPayload: aDictionary outputItems: aCollection [
	| finishReason |
	finishReason := self
		valueAt: #finish_reason
		in: (self firstChoiceFromPayload: aDictionary)
		ifAbsent: [ nil ].
	finishReason ifNotNil: [ ^ finishReason asString ].
	^ super finishReasonFromPayload: aDictionary outputItems: aCollection
]

{ #category : 'private' }
SloptalkOpenAIProvider >> firstChoiceFromPayload: aDictionary [
	| choices |
	choices := self
		valueAt: #choices
		in: aDictionary
		ifAbsent: [ self error: 'Chat completion response did not include choices' ].
	choices isEmpty ifTrue: [
		self error: 'Chat completion response did not include any choices' ].
	^ choices first
]

{ #category : 'private' }
SloptalkOpenAIProvider >> outputItemsFromPayload: aDictionary [
	| choice message content normalizedContent outputItems toolCalls |
	choice := self firstChoiceFromPayload: aDictionary.
	message := self
		valueAt: #message
		in: choice
		ifAbsent: [ self error: 'Chat completion choice did not include a message' ].
	outputItems := OrderedCollection new.

	content := self
		valueAt: #content
		in: message
		ifAbsent: [ nil ].
	content ifNotNil: [
		normalizedContent := self normalizeContent: content.
		normalizedContent ifNotEmpty: [
			outputItems add: (SloptalkLLMOutputItem assistantText: normalizedContent) ] ].

	toolCalls := self
		valueAt: #tool_calls
		in: message
		ifAbsent: [ #() ].
	toolCalls do: [ :each |
		| function arguments |
		function := self
			valueAt: #function
			in: each
			ifAbsent: [ Dictionary new ].
		arguments := self
			valueAt: #arguments
			in: function
			ifAbsent: [ '{}' ].
		outputItems add: (
			SloptalkLLMOutputItem
				toolCallId: (self valueAt: #id in: each ifAbsent: [ nil ])
				name: (self valueAt: #name in: function ifAbsent: [ 'unknown' ])
				arguments: (self parsedJSONObjectFromString: arguments)) ].

	^ outputItems asArray
]

{ #category : 'private' }
SloptalkOpenAIProvider >> requestBodyForRequest: aSloptalkLLMRequest [
	| messages |
	messages := aSloptalkLLMRequest inputItems collect: [ :each |
		self chatCompletionMessageForInputItem: each ].

	^ {
		#model -> model.
		#messages -> messages asArray.
		#stream -> false
	} asDictionary
]

{ #category : 'private' }
SloptalkOpenAIProvider >> usageFromPayload: aDictionary [
	| usage promptTokens completionTokens totalTokens |
	usage := self valueAt: #usage in: aDictionary ifAbsent: [ Dictionary new ].
	promptTokens := self valueAt: #prompt_tokens in: usage ifAbsent: [ 0 ].
	completionTokens := self valueAt: #completion_tokens in: usage ifAbsent: [ 0 ].
	totalTokens := self
		valueAt: #total_tokens
		in: usage
		ifAbsent: [ promptTokens + completionTokens ].
	^ SloptalkLLMUsage
		promptTokens: promptTokens
		completionTokens: completionTokens
		totalTokens: totalTokens
]
