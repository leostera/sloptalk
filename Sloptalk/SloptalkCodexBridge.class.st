"I talk to a local OpenAI-compatible chat completions endpoint."
Class {
	#name : 'SloptalkCodexBridge',
	#superclass : 'Object',
	#instVars : [
		'workspacePath',
		'baseUrl',
		'endpointPath',
		'model'
	],
	#category : 'Sloptalk-Bridge',
	#package : 'Sloptalk',
	#tag : 'Bridge'
}

{ #category : 'private' }
SloptalkCodexBridge >> assistantTextFromResponse: aDictionary [
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
SloptalkCodexBridge >> baseUrl [
	^ baseUrl
]

{ #category : 'accessing' }
SloptalkCodexBridge >> baseUrl: aString [
	baseUrl := aString
]

{ #category : 'private' }
SloptalkCodexBridge >> endpointUrl [
	^ baseUrl , endpointPath
]

{ #category : 'accessing' }
SloptalkCodexBridge >> model [
	^ model
]

{ #category : 'accessing' }
SloptalkCodexBridge >> model: aString [
	model := aString
]

{ #category : 'private' }
SloptalkCodexBridge >> normalizeContent: anObject [
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

{ #category : 'initialization' }
SloptalkCodexBridge >> initialize [
	super initialize.
	workspacePath := '.'.
	baseUrl := 'http://localhost:11434'.
	endpointPath := '/v1/chat/completions'.
	model := 'gemma-4-31B-it-Q8_0.gguf'
]

{ #category : 'api' }
SloptalkCodexBridge >> replyTo: aString in: aConversation [
	| client |
	client := ZnClient new.
	[
		client
			forJsonREST;
			post: self endpointUrl contents: (self requestBodyFor: aConversation).
		client isSuccess ifFalse: [
			self error: 'Chat completion request failed with status ' , client response statusLine asString ].
		^ self assistantTextFromResponse: client contents
	] ensure: [ client close ]
]

{ #category : 'private' }
SloptalkCodexBridge >> requestBodyFor: aConversation [
	^ {
		#model -> model.
		#messages -> (aConversation messages collect: [ :each | each asChatCompletionMessage ]).
		#stream -> false
	} asDictionary
]

{ #category : 'private' }
SloptalkCodexBridge >> valueAt: aKey in: aDictionary ifAbsent: aBlock [
	^ aDictionary
		at: aKey
		ifAbsent: [
			aDictionary
				at: aKey asString
				ifAbsent: aBlock ]
]

{ #category : 'accessing' }
SloptalkCodexBridge >> workspacePath [
	^ workspacePath
]

{ #category : 'accessing' }
SloptalkCodexBridge >> workspacePath: aString [
	workspacePath := aString
]
