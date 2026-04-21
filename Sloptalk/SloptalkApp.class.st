"I hold the shared Sloptalk agent used by the image UI."
Class {
	#name : 'SloptalkApp',
	#superclass : 'Object',
	#instVars : [
		'agent'
	],
	#classInstVars : [
		'current'
	],
	#category : 'Sloptalk-App',
	#package : 'Sloptalk',
	#tag : 'App'
}

{ #category : 'accessing' }
SloptalkApp class >> agent [
	^ self current agent
]

{ #category : 'accessing' }
SloptalkApp class >> current [
	^ current ifNil: [ current := self new ]
]

{ #category : 'accessing' }
SloptalkApp class >> current: aSloptalkApp [
	current := aSloptalkApp
]

{ #category : 'api' }
SloptalkApp class >> open [
	^ SloptalkChatPresenter open
]

{ #category : 'accessing' }
SloptalkApp class >> resetCurrent [
	current := nil
]

{ #category : 'accessing' }
SloptalkApp >> agent [
	^ agent
]

{ #category : 'accessing' }
SloptalkApp >> agent: aSloptalkAgent [
	agent := aSloptalkAgent
]

{ #category : 'accessing' }
SloptalkApp >> announcer [
	^ agent announcer
]

{ #category : 'accessing' }
SloptalkApp >> apiKey [
	^ agent apiKey
]

{ #category : 'accessing' }
SloptalkApp >> apiKey: aString [
	agent apiKey: aString
]

{ #category : 'accessing' }
SloptalkApp >> baseUrl [
	^ agent baseUrl
]

{ #category : 'accessing' }
SloptalkApp >> baseUrl: aString [
	agent baseUrl: aString
]

{ #category : 'testing' }
SloptalkApp >> busy [
	^ agent busy
]

{ #category : 'initialization' }
SloptalkApp >> initialize [
	super initialize.
	agent := SloptalkAgent new
]

{ #category : 'accessing' }
SloptalkApp >> model [
	^ agent model
]

{ #category : 'accessing' }
SloptalkApp >> model: aString [
	agent model: aString
]

{ #category : 'accessing' }
SloptalkApp >> provider [
	^ agent provider
]

{ #category : 'accessing' }
SloptalkApp >> provider: aSloptalkLLMProvider [
	agent provider: aSloptalkLLMProvider
]

{ #category : 'accessing' }
SloptalkApp >> providerDescription [
	^ agent providerDescription
]

{ #category : 'accessing' }
SloptalkApp >> requestTimeoutSeconds [
	^ agent requestTimeoutSeconds
]

{ #category : 'accessing' }
SloptalkApp >> requestTimeoutSeconds: anInteger [
	agent requestTimeoutSeconds: anInteger
]

{ #category : 'api' }
SloptalkApp >> resetConversation [
	agent resetConversation
]

{ #category : 'api' }
SloptalkApp >> send: aString [
	^ agent send: aString
]

{ #category : 'api' }
SloptalkApp >> sendAndWait: aString [
	^ agent sendAndWait: aString
]

{ #category : 'printing' }
SloptalkApp >> transcriptString [
	^ agent transcriptString
]

{ #category : 'accessing' }
SloptalkApp >> workspacePath [
	^ agent workspacePath
]

{ #category : 'accessing' }
SloptalkApp >> workspacePath: aString [
	agent workspacePath: aString
]
