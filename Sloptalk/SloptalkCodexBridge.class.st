"I talk to a local OpenAI-compatible chat completions endpoint."
Class {
	#name : 'SloptalkCodexBridge',
	#superclass : 'Object',
	#instVars : [
		'provider'
	],
	#category : 'Sloptalk-Bridge',
	#package : 'Sloptalk',
	#tag : 'Bridge'
}

{ #category : 'accessing' }
SloptalkCodexBridge >> apiKey [
	^ (provider respondsTo: #apiKey)
		ifTrue: [ provider apiKey ]
		ifFalse: [ nil ]
]

{ #category : 'accessing' }
SloptalkCodexBridge >> apiKey: aString [
	(provider respondsTo: #apiKey:)
		ifFalse: [ self error: 'The current provider does not support apiKey:' ].
	provider apiKey: aString
]

{ #category : 'accessing' }
SloptalkCodexBridge >> baseUrl [
	^ (provider respondsTo: #baseUrl)
		ifTrue: [ provider baseUrl ]
		ifFalse: [ nil ]
]

{ #category : 'accessing' }
SloptalkCodexBridge >> baseUrl: aString [
	(provider respondsTo: #baseUrl:)
		ifFalse: [ self error: 'The current provider does not support baseUrl:' ].
	provider baseUrl: aString
]

{ #category : 'accessing' }
SloptalkCodexBridge >> model [
	^ provider model
]

{ #category : 'accessing' }
SloptalkCodexBridge >> model: aString [
	provider model: aString
]

{ #category : 'initialization' }
SloptalkCodexBridge >> initialize [
	super initialize.
	provider := SloptalkLocalOllamaProvider new
]

{ #category : 'api' }
SloptalkCodexBridge >> replyTo: aString in: aConversation [
	^ self completeConversation: aConversation systemPrompt: ''
]

{ #category : 'api' }
SloptalkCodexBridge >> completeConversation: aConversation systemPrompt: aString [
	^ provider
		completeConversation: aConversation
		systemPrompt: aString
]

{ #category : 'accessing' }
SloptalkCodexBridge >> provider [
	^ provider
]

{ #category : 'accessing' }
SloptalkCodexBridge >> provider: aSloptalkLLMProvider [
	provider := aSloptalkLLMProvider
]

{ #category : 'accessing' }
SloptalkCodexBridge >> requestTimeoutSeconds [
	^ provider requestTimeoutSeconds
]

{ #category : 'accessing' }
SloptalkCodexBridge >> requestTimeoutSeconds: anInteger [
	provider requestTimeoutSeconds: anInteger
]
