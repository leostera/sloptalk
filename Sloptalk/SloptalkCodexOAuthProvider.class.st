"I talk to the ChatGPT-backed Codex responses endpoint using a locally managed OAuth session."
Class {
	#name : 'SloptalkCodexOAuthProvider',
	#superclass : 'SloptalkHTTPJSONProvider',
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
SloptalkCodexOAuthProvider >> assistantTextFromPayload: aDictionary [
	| outputText output |
	outputText := self valueAt: #output_text in: aDictionary ifAbsent: [ nil ].
	outputText ifNotNil: [ ^ self normalizeContent: outputText ].
	output := self valueAt: #output in: aDictionary ifAbsent: [ nil ].
	(output isCollection and: [ output isString not ]) ifTrue: [
		^ self assistantTextFromOutputItems: output ].
	^ self
		error: 'Codex response did not include assistant output text'
]

{ #category : 'api' }
SloptalkCodexOAuthProvider >> completeRequest: aSloptalkLLMRequest [
	self ensureValidSession.
	^ super completeRequest: aSloptalkLLMRequest
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
SloptalkCodexOAuthProvider >> callIdForMessage: aSloptalkMessage [
	^ aSloptalkMessage toolCallId
		ifNil: [ 'call_' , (aSloptalkMessage toolName ifNil: [ 'unknown' ]) ]
]

{ #category : 'private' }
SloptalkCodexOAuthProvider >> jsonStringFromArguments: anObject [
	anObject isString ifTrue: [ ^ anObject ].
	^ STONJSON toString: anObject
]

{ #category : 'private' }
SloptalkCodexOAuthProvider >> requestBodyForRequest: aSloptalkLLMRequest [
	| input |
	input := aSloptalkLLMRequest messages collect: [ :each | self responsesInputItemFor: each ].

	^ {
		#model -> model.
		#instructions -> aSloptalkLLMRequest systemPrompt.
		#input -> input asArray.
		#store -> false.
		#stream -> false
	} asDictionary
]

{ #category : 'private' }
SloptalkCodexOAuthProvider >> responsesInputItemFor: aSloptalkMessage [
	aSloptalkMessage isToolCallMessage ifTrue: [
		^ {
			#type -> 'function_call'.
			#call_id -> (self callIdForMessage: aSloptalkMessage).
			#name -> (aSloptalkMessage toolName ifNil: [ 'unknown' ]).
			#arguments -> (self jsonStringFromArguments: aSloptalkMessage toolArguments)
		} asDictionary ].

	aSloptalkMessage isToolResult ifTrue: [
		^ {
			#type -> 'function_call_output'.
			#call_id -> (self callIdForMessage: aSloptalkMessage).
			#output -> aSloptalkMessage text
		} asDictionary ].

	^ {
		#type -> 'message'.
		#role -> aSloptalkMessage role.
		#content -> {
			{
				#type -> (aSloptalkMessage role = 'assistant'
					ifTrue: [ 'output_text' ]
					ifFalse: [ 'input_text' ]).
				#text -> aSloptalkMessage text
			} asDictionary
		}
	} asDictionary
]

{ #category : 'accessing' }
SloptalkCodexOAuthProvider >> session [
	^ session
]

{ #category : 'accessing' }
SloptalkCodexOAuthProvider >> session: aSloptalkCodexSession [
	session := aSloptalkCodexSession
]
