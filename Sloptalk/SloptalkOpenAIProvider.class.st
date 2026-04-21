"I talk to an OpenAI-compatible chat completions endpoint."
Class {
	#name : 'SloptalkOpenAIProvider',
	#superclass : 'SloptalkLLMProvider',
	#instVars : [
		'baseUrl',
		'endpointPath',
		'apiKey'
	],
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'accessing' }
SloptalkOpenAIProvider >> apiKey [
	^ apiKey
]

{ #category : 'accessing' }
SloptalkOpenAIProvider >> apiKey: aString [
	apiKey := aString
]

{ #category : 'private' }
SloptalkOpenAIProvider >> assistantTextFromResponse: aDictionary [
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

{ #category : 'accessing' }
SloptalkOpenAIProvider >> baseUrl [
	^ baseUrl
]

{ #category : 'accessing' }
SloptalkOpenAIProvider >> baseUrl: aString [
	baseUrl := aString
]

{ #category : 'api' }
SloptalkOpenAIProvider >> completeConversation: aConversation systemPrompt: aString [
	| client responseBody |
	client := ZnClient new.
	[
		[
			self prepareClient: client.
			client
				post: self endpointUrl
				contents: (self requestBodyFor: aConversation systemPrompt: aString)
		] on: ConnectionTimedOut do: [ :error |
			self
				error:
					'Chat completion request timed out after '
						, requestTimeoutSeconds asString
						, ' seconds' ].
		client isSuccess ifFalse: [
			responseBody := [ client response entity contents ]
				on: Error
				do: [ :error | '' ].
			self
				error:
					'Chat completion request failed with status '
						, client response statusLine asString
						, (responseBody
							ifEmpty: [ '' ]
							ifNotEmpty: [ ': ' , responseBody ]) ].
		^ self assistantTextFromResponse: client contents
	] ensure: [ client close ]
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
SloptalkOpenAIProvider >> displayString [
	^ self providerName , ' (' , model , ') @ ' , baseUrl
]

{ #category : 'private' }
SloptalkOpenAIProvider >> endpointUrl [
	^ baseUrl , endpointPath
]

{ #category : 'accessing' }
SloptalkOpenAIProvider >> endpointPath [
	^ endpointPath
]

{ #category : 'accessing' }
SloptalkOpenAIProvider >> endpointPath: aString [
	endpointPath := aString
]

{ #category : 'initialization' }
SloptalkOpenAIProvider >> initialize [
	super initialize.
	baseUrl := self defaultBaseUrl.
	endpointPath := self defaultEndpointPath.
	apiKey := self defaultApiKey
]

{ #category : 'private' }
SloptalkOpenAIProvider >> normalizeContent: anObject [
	anObject isString ifTrue: [ ^ anObject ].
	(anObject isCollection and: [ anObject isString not ]) ifTrue: [
		^ String streamContents: [ :stream |
			anObject do: [ :part |
				| text |
				text := part isDictionary
					ifTrue: [ self valueAt: #text in: part ifAbsent: [ '' ] ]
					ifFalse: [ part asString ].
				stream nextPutAll: text ] ] ].
	^ anObject asString
]

{ #category : 'private' }
SloptalkOpenAIProvider >> prepareClient: aZnClient [
	aZnClient
		beOneShot;
		timeout: requestTimeoutSeconds;
		forJsonREST.
	apiKey ifNotNil: [
		aZnClient setBearerAuthentication: apiKey ]
]

{ #category : 'accessing' }
SloptalkOpenAIProvider >> providerName [
	^ 'OpenAI'
]

{ #category : 'private' }
SloptalkOpenAIProvider >> requestBodyFor: aConversation systemPrompt: aString [
	| messages |
	messages := OrderedCollection new.
	aString ifNotEmpty: [
		messages add: ({
			#role -> 'system'.
			#content -> aString
		} asDictionary) ].
	messages addAll: (aConversation messages collect: [ :each | each asChatCompletionMessage ]).

	^ {
		#model -> model.
		#messages -> messages asArray.
		#stream -> false
	} asDictionary
]

{ #category : 'private' }
SloptalkOpenAIProvider >> valueAt: aKey in: aDictionary ifAbsent: aBlock [
	^ aDictionary
		at: aKey
		ifAbsent: [
			aDictionary
				at: aKey asString
				ifAbsent: aBlock ]
]
