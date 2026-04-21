"I talk to the ChatGPT-backed Codex responses endpoint using a locally managed OAuth session."
Class {
	#name : 'SloptalkCodexOAuthProvider',
	#superclass : 'SloptalkOpenAIProvider',
	#instVars : [
		'session'
	],
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'private' }
SloptalkCodexOAuthProvider >> assistantTextFromOutputItems: outputItems [
	| fragments |
	fragments := OrderedCollection new.
	outputItems do: [ :each |
		| content |
		content := self valueAt: #content in: each ifAbsent: [ #() ].
		(content isCollection and: [ content isString not ]) ifTrue: [
			content do: [ :part |
				| text |
				text := self valueAt: #text in: part ifAbsent: [
					self valueAt: #content in: part ifAbsent: [ nil ] ].
				text ifNotNil: [ fragments add: text asString ] ] ] ].
	^ String streamContents: [ :stream |
		fragments do: [ :each | stream nextPutAll: each ] ]
]

{ #category : 'private' }
SloptalkCodexOAuthProvider >> assistantTextFromResponse: aDictionary [
	| outputText output |
	outputText := self valueAt: #output_text in: aDictionary ifAbsent: [ nil ].
	outputText ifNotNil: [ ^ self normalizeContent: outputText ].
	output := self valueAt: #output in: aDictionary ifAbsent: [ nil ].
	(output isCollection and: [ output isString not ]) ifTrue: [
		^ self assistantTextFromOutputItems: output ].
	^ super assistantTextFromResponse: aDictionary
]

{ #category : 'api' }
SloptalkCodexOAuthProvider >> completeConversation: aConversation systemPrompt: aString [
	self ensureValidSession.
	^ super completeConversation: aConversation systemPrompt: aString
]

{ #category : 'defaults' }
SloptalkCodexOAuthProvider >> defaultApiKey [
	^ nil
]

{ #category : 'defaults' }
SloptalkCodexOAuthProvider >> defaultBaseUrl [
	^ 'https://chatgpt.com/backend-api/codex'
]

{ #category : 'defaults' }
SloptalkCodexOAuthProvider >> defaultEndpointPath [
	^ '/responses'
]

{ #category : 'defaults' }
SloptalkCodexOAuthProvider >> defaultModel [
	^ 'gpt-5.3-codex'
]

{ #category : 'accessing' }
SloptalkCodexOAuthProvider >> displayString [
	^ self providerName
		, ' ('
		, model
		, ') '
		, (self isAuthenticated
			ifTrue: [ 'connected' ]
			ifFalse: [ 'not connected' ])
]

{ #category : 'private' }
SloptalkCodexOAuthProvider >> ensureValidSession [
	session ifNil: [ self error: 'Codex is not connected. Use Settings to sign in with ChatGPT.' ].
	session expired ifTrue: [ SloptalkCodexAuth refreshSession: session ].
	session isConnected ifFalse: [
		self error: 'Codex is not connected. Use Settings to sign in with ChatGPT.' ]
]

{ #category : 'testing' }
SloptalkCodexOAuthProvider >> isAuthenticated [
	^ session isNotNil and: [ session isConnected ]
]

{ #category : 'private' }
SloptalkCodexOAuthProvider >> prepareClient: aZnClient [
	aZnClient
		beOneShot;
		timeout: requestTimeoutSeconds;
		forJsonREST;
		setBearerAuthentication: session accessToken.
	session accountId ifNotNil: [
		aZnClient headerAt: 'chatgpt-account-id' put: session accountId ]
]

{ #category : 'accessing' }
SloptalkCodexOAuthProvider >> providerName [
	^ 'Codex ChatGPT'
]

{ #category : 'private' }
SloptalkCodexOAuthProvider >> requestBodyFor: aConversation systemPrompt: aString [
	| input body |
	input := aConversation messages collect: [ :each | each asResponsesInputMessage ].
	body := {
		#model -> model.
		#input -> input asArray.
		#store -> false
	} asDictionary.
	aString ifNotEmpty: [
		body at: #instructions put: aString ].
	^ body
]

{ #category : 'accessing' }
SloptalkCodexOAuthProvider >> session [
	^ session
]

{ #category : 'accessing' }
SloptalkCodexOAuthProvider >> session: aSloptalkCodexSession [
	session := aSloptalkCodexSession
]
