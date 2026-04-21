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
	^ self completeStreamingRequest: aSloptalkLLMRequest
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

{ #category : 'private' }
SloptalkCodexOAuthProvider >> completeStreamingRequest: aSloptalkLLMRequest [
	| client stream responseBody payload |
	client := ZnClient new.
	[
		[
			self prepareStreamingClient: client.
			stream := client
				post: self endpointUrl
				contents: (self requestBodyForRequest: aSloptalkLLMRequest)
		] on: ConnectionTimedOut do: [ :error |
			self
				error:
					'Chat completion request timed out after '
						, requestTimeoutSeconds asString
						, ' seconds' ].

		responseBody := self utf8StringFromStream: stream.
		client isSuccess ifFalse: [
			self
				error:
					'Chat completion request failed with status '
						, client response statusLine asString
						, (responseBody
							ifEmpty: [ '' ]
							ifNotEmpty: [ ': ' , responseBody ]) ].

		payload := self responsePayloadFromEventStream: responseBody.
		^ self responseFromPayload: payload
	] ensure: [ client close ]
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

{ #category : 'private' }
SloptalkCodexOAuthProvider >> prepareStreamingClient: aZnClient [
	| writer |
	writer := ZnUtils defaultJSONWriter.
	aZnClient
		streaming: true;
		timeout: requestTimeoutSeconds;
		accept: ZnMimeType any;
		contentWriter: [ :data | ZnEntity json: (writer toString: data) ];
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
		#stream -> true
	} asDictionary
]

{ #category : 'private' }
SloptalkCodexOAuthProvider >> responsePayloadFromEventStream: aString [
	| completedEvent failedEvent payload |
	failedEvent := self
		serverSentEventNamed: 'response.failed'
		in: aString.
	failedEvent ifNotNil: [
		self error: 'Codex stream failed: ' , failedEvent ].

	completedEvent := self
		serverSentEventNamed: 'response.completed'
		in: aString.
	completedEvent ifNil: [
		self error: 'Codex stream did not include response.completed' ].

	payload := STONJSON fromString: completedEvent.
	^ self valueAt: #response in: payload ifAbsent: [ payload ]
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
SloptalkCodexOAuthProvider >> serverSentEventNamed: anEventName in: aString [
	| stream line currentEvent currentData |
	stream := ReadStream on: (self normalizedEventStreamString: aString).
	currentEvent := nil.
	currentData := OrderedCollection new.

	[ stream atEnd ] whileFalse: [
		line := stream upTo: Character lf.
		line isEmpty
			ifTrue: [
				(currentEvent = anEventName and: [ currentData isNotEmpty ]) ifTrue: [
					^ String streamContents: [ :out |
						currentData
							doWithIndex: [ :each :index |
								index > 1 ifTrue: [ out nextPut: Character lf ].
								out nextPutAll: each ] ] ].
				currentEvent := nil.
				currentData := OrderedCollection new ]
			ifFalse: [
				(line beginsWith: 'event:') ifTrue: [
					currentEvent := self
						serverSentEventLineValueFrom: line
						prefixSize: 6 ].
				(line beginsWith: 'data:') ifTrue: [
					currentData add: (self
						serverSentEventLineValueFrom: line
						prefixSize: 5) ] ] ].

	(currentEvent = anEventName and: [ currentData isNotEmpty ]) ifTrue: [
		^ String streamContents: [ :out |
			currentData
				doWithIndex: [ :each :index |
					index > 1 ifTrue: [ out nextPut: Character lf ].
					out nextPutAll: each ] ] ].

	^ nil
]

{ #category : 'private' }
SloptalkCodexOAuthProvider >> normalizedEventStreamString: aString [
	^ ((aString copyReplaceAll: String crlf with: String lf)
		copyReplaceAll: String cr asString
		with: String lf)
]

{ #category : 'private' }
SloptalkCodexOAuthProvider >> serverSentEventLineValueFrom: aString prefixSize: anInteger [
	aString size <= anInteger ifTrue: [ ^ '' ].
	^ (aString copyFrom: anInteger + 1 to: aString size) trimBoth
]

{ #category : 'accessing' }
SloptalkCodexOAuthProvider >> session [
	^ session
]

{ #category : 'accessing' }
SloptalkCodexOAuthProvider >> session: aSloptalkCodexSession [
	session := aSloptalkCodexSession
]

{ #category : 'private' }
SloptalkCodexOAuthProvider >> utf8StringFromStream: aStream [
	| contents |
	contents := aStream upToEnd.
	contents isString ifTrue: [ ^ contents ].
	^ [ contents utf8Decoded ]
		on: Error
		do: [ :error | contents asString ]
]
