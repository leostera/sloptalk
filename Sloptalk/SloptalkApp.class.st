"I hold the shared Sloptalk agent used by the image UI."
Class {
	#name : 'SloptalkApp',
	#superclass : 'Object',
	#instVars : [
		'agent',
		'openAIApiKey',
		'providerSettings'
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

{ #category : 'api' }
SloptalkApp class >> openSettings [
	^ SloptalkSettingsPresenter open
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
	| currentApiKey |
	currentApiKey := agent apiKey.
	currentApiKey ifNotNil: [ ^ currentApiKey ].
	^ openAIApiKey
]

{ #category : 'accessing' }
SloptalkApp >> apiKey: aString [
	openAIApiKey := aString.
	(self providerKind = #openAI and: [ aString isNotNil ]) ifTrue: [
		agent apiKey: aString ]
]

{ #category : 'api' }
SloptalkApp >> applySettingsProviderKind: aSymbol model: aModelString baseUrl: aBaseUrlString requestTimeoutSeconds: anInteger workspacePath: aWorkspacePathString [
	self
		updateSettingsForProviderKind: aSymbol
		model: aModelString
		baseUrl: aBaseUrlString.

	aSymbol = #openAI
		ifTrue: [
			agent useOpenAIProvider.
			agent apiKey: openAIApiKey ]
		ifFalse: [ agent useLocalOllamaProvider ].

	agent model: (self modelForProviderKind: aSymbol).
	agent baseUrl: (self baseUrlForProviderKind: aSymbol).
	agent requestTimeoutSeconds: anInteger.
	aWorkspacePathString ifNotEmpty: [
		agent workspacePath: aWorkspacePathString ]
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

{ #category : 'accessing' }
SloptalkApp >> clearApiKey [
	openAIApiKey := nil.
	self providerKind = #openAI ifTrue: [
		agent apiKey: nil ]
]

{ #category : 'accessing' }
SloptalkApp >> codexLoginStatusText [
	^ SloptalkCodexAuth loginStatusText
]

{ #category : 'initialization' }
SloptalkApp >> initialize [
	super initialize.
	agent := SloptalkAgent new.
	openAIApiKey := OSEnvironment current
		at: 'OPENAI_API_KEY'
		ifAbsent: [ nil ].
	providerSettings := Dictionary new.
	self initializeProviderSettings
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
SloptalkApp >> providerChoices [
	^ #(#localOllama #openAI)
]

{ #category : 'accessing' }
SloptalkApp >> providerDisplayNameFor: aSymbol [
	aSymbol = #localOllama ifTrue: [ ^ 'Local Ollama' ].
	aSymbol = #openAI ifTrue: [ ^ 'OpenAI API' ].
	^ aSymbol asString
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
SloptalkApp >> providerKind [
	(agent provider isKindOf: SloptalkLocalOllamaProvider) ifTrue: [ ^ #localOllama ].
	(agent provider isKindOf: SloptalkOpenAIProvider) ifTrue: [ ^ #openAI ].
	^ #openAI
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
SloptalkApp >> startCodexDeviceLogin [
	^ SloptalkCodexAuth openDeviceLogin
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

{ #category : 'accessing' }
SloptalkApp >> apiKeyStatusText [
	| apiKey |
	apiKey := self apiKey.
	(apiKey isNil or: [ apiKey trimBoth isEmpty ]) ifTrue: [
		^ 'API key: missing' ].
	^ 'API key: stored (' , apiKey size asString , ' chars)'
]

{ #category : 'accessing' }
SloptalkApp >> baseUrlForProviderKind: aSymbol [
	^ (providerSettings
		at: aSymbol
		ifAbsent: [ self error: 'Unknown provider kind: ' , aSymbol asString ])
			at: #baseUrl
]

{ #category : 'initialization' }
SloptalkApp >> initializeProviderSettings [
	providerSettings
		at: #localOllama
		put: ({
			#baseUrl -> 'http://localhost:11434'.
			#model -> 'gemma-4-31B-it-Q8_0.gguf'
		} asDictionary).
	providerSettings
		at: #openAI
		put: ({
			#baseUrl -> 'https://api.openai.com'.
			#model -> 'gpt-4.1-mini'
		} asDictionary)
]

{ #category : 'accessing' }
SloptalkApp >> modelForProviderKind: aSymbol [
	^ (providerSettings
		at: aSymbol
		ifAbsent: [ self error: 'Unknown provider kind: ' , aSymbol asString ])
			at: #model
]

{ #category : 'api' }
SloptalkApp >> openCodexAuthenticationDocs [
	^ SloptalkCodexAuth openAuthenticationDocs
]

{ #category : 'accessing' }
SloptalkApp >> updateSettingsForProviderKind: aSymbol model: aModelString baseUrl: aBaseUrlString [
	| settings |
	settings := providerSettings
		at: aSymbol
		ifAbsent: [ self error: 'Unknown provider kind: ' , aSymbol asString ].
	settings
		at: #model put: aModelString;
		at: #baseUrl put: aBaseUrlString
]
