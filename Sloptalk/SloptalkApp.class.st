"I hold the shared Sloptalk agent used by the image UI."
Class {
	#name : 'SloptalkApp',
	#superclass : 'Object',
	#instVars : [
		'agent',
		'openAIApiKey',
		'providerSettings',
		'codexSession',
		'codexAuthState',
		'codexAuthProcess'
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
	current ifNil: [ current := self new ].
	current ensureInitializedState.
	^ current
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
	self ensureInitializedState.
	^ agent
]

{ #category : 'debugging' }
SloptalkApp >> debugTranscriptPlaygroundContents [
	self ensureInitializedState.
	^ String streamContents: [ :stream |
		stream
			nextPutAll: '"Sloptalk transcript debugging"';
			nextPut: Character lf;
			nextPutAll: 'app := SloptalkApp current.';
			nextPut: Character lf;
			nextPutAll: 'agent := app agent.';
			nextPut: Character lf;
			nextPutAll: 'conversation := agent conversation.';
			nextPut: Character lf;
			nextPutAll: 'transcript := app transcriptString.';
			nextPut: Character lf;
			nextPutAll: 'messages := app transcriptMessages.';
			nextPut: Character lf;
			nextPutAll: 'lastRequest := app lastLLMRequest.';
			nextPut: Character lf;
			nextPutAll: 'lastResponse := app lastLLMResponse.';
			nextPut: Character lf;
			nextPut: Character lf;
			nextPutAll: '"Evaluate one of these:"';
			nextPut: Character lf;
			nextPutAll: 'transcript';
			nextPut: Character lf;
			nextPutAll: 'messages';
			nextPut: Character lf;
			nextPutAll: 'messages collect: [ :each | { each role. each text. each details } ]';
			nextPut: Character lf;
			nextPutAll: 'messages last ifNotNil: [ :each | each details ]';
			nextPut: Character lf;
			nextPutAll: 'lastRequest';
			nextPut: Character lf;
			nextPutAll: 'lastRequest inputItems';
			nextPut: Character lf;
			nextPutAll: 'lastResponse';
			nextPut: Character lf;
			nextPutAll: 'lastResponse outputItems';
			nextPut: Character lf;
			nextPutAll: 'lastResponse usage';
			nextPut: Character lf;
			nextPutAll: 'lastResponse payload' ]
]

{ #category : 'accessing' }
SloptalkApp >> agent: aSloptalkAgent [
	agent := aSloptalkAgent
]

{ #category : 'accessing' }
SloptalkApp >> announcer [
	self ensureInitializedState.
	^ agent announcer
]

{ #category : 'accessing' }
SloptalkApp >> apiKey [
	| currentApiKey |
	self ensureInitializedState.
	currentApiKey := agent apiKey.
	currentApiKey ifNotNil: [ ^ currentApiKey ].
	^ openAIApiKey
]

{ #category : 'accessing' }
SloptalkApp >> apiKey: aString [
	self ensureInitializedState.
	openAIApiKey := aString.
	(self providerKind = #openAI and: [ aString isNotNil ]) ifTrue: [
		agent apiKey: aString ]
]

{ #category : 'accessing' }
SloptalkApp >> apiKeyStatusText [
	| apiKey |
	self ensureInitializedState.
	apiKey := self apiKey.
	(apiKey isNil or: [ apiKey trimBoth isEmpty ]) ifTrue: [
		^ 'API key: missing' ].
	^ 'API key: stored (' , apiKey size asString , ' chars)'
]

{ #category : 'private' }
SloptalkApp >> codexDeviceCodePromptTextFor: aDictionary [
	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'Enter this device code at OpenAI:';
			nextPut: Character lf;
			nextPut: Character lf;
			nextPutAll: (aDictionary at: #userCode);
			nextPut: Character lf;
			nextPut: Character lf;
			nextPutAll: 'Verification URL:';
			nextPut: Character lf;
			nextPutAll: (aDictionary at: #verificationUrl) ]
]

{ #category : 'private' }
SloptalkApp >> announceCodexAuthChanged [
	self announcer announce: (SloptalkCodexAuthAnnouncement
		app: self
		state: codexAuthState copy)
]

{ #category : 'api' }
SloptalkApp >> applySettingsProviderKind: aSymbol model: aModelString baseUrl: aBaseUrlString requestTimeoutSeconds: anInteger workspacePath: aWorkspacePathString [
	self ensureInitializedState.
	self
		updateSettingsForProviderKind: aSymbol
		model: aModelString
		baseUrl: aBaseUrlString.

	aSymbol = #codexOAuth
		ifTrue: [
			agent useCodexOAuthProvider.
			self applyCodexSessionToAgentIfNeeded ]
		ifFalse: [
			aSymbol = #openAI
				ifTrue: [
					agent useOpenAIProvider.
					agent apiKey: openAIApiKey ]
				ifFalse: [ agent useLocalOllamaProvider ] ].

	agent model: (self modelForProviderKind: aSymbol).
	agent baseUrl: (self baseUrlForProviderKind: aSymbol).
	agent requestTimeoutSeconds: anInteger.
	aWorkspacePathString ifNotEmpty: [
		agent workspacePath: aWorkspacePathString ]
]

{ #category : 'private' }
SloptalkApp >> applyCodexSessionToAgentIfNeeded [
	self providerKind = #codexOAuth ifFalse: [ ^ self ].
	(agent provider respondsTo: #session:) ifTrue: [
		agent provider session: codexSession ]
]

{ #category : 'accessing' }
SloptalkApp >> baseUrl [
	self ensureInitializedState.
	^ agent baseUrl
]

{ #category : 'accessing' }
SloptalkApp >> baseUrl: aString [
	self ensureInitializedState.
	agent baseUrl: aString
]

{ #category : 'accessing' }
SloptalkApp >> baseUrlForProviderKind: aSymbol [
	self ensureInitializedState.
	^ (providerSettings
		at: aSymbol
		ifAbsent: [ self error: 'Unknown provider kind: ' , aSymbol asString ])
			at: #baseUrl
]

{ #category : 'testing' }
SloptalkApp >> busy [
	self ensureInitializedState.
	^ agent busy
]

{ #category : 'api' }
SloptalkApp >> cancelCodexDeviceLogin [
	self ensureInitializedState.
	codexAuthProcess ifNotNil: [
		codexAuthProcess terminate.
		codexAuthProcess := nil ].
	codexSession
		ifNil: [
			self
				setCodexAuthStateStatus: #notConnected
				errorText: nil
				deviceAuthId: nil
				userCode: nil
				verificationUrl: nil ]
		ifNotNil: [
			self
				setCodexAuthStateStatus: #connected
				errorText: nil
				deviceAuthId: nil
				userCode: nil
				verificationUrl: nil ].
	self announceCodexAuthChanged
]

{ #category : 'accessing' }
SloptalkApp >> clearApiKey [
	self ensureInitializedState.
	openAIApiKey := nil.
	self providerKind = #openAI ifTrue: [
		agent apiKey: nil ]
]

{ #category : 'testing' }
SloptalkApp >> codexAuthCanStart [
	self ensureInitializedState.
	^ (self codexAuthStatus ~= #requestingCode)
		and: [ self codexAuthWaitingForApproval not ]
]

{ #category : 'accessing' }
SloptalkApp >> codexAuthErrorText [
	self ensureInitializedState.
	^ codexAuthState at: #errorText ifAbsent: [ nil ]
]

{ #category : 'accessing' }
SloptalkApp >> codexAuthStatus [
	self ensureInitializedState.
	^ codexAuthState at: #status ifAbsent: [ #notConnected ]
]

{ #category : 'accessing' }
SloptalkApp >> codexAuthStatusText [
	| expiresAt |
	self ensureInitializedState.
	self codexConnected ifTrue: [
		expiresAt := codexSession expiresAt.
		^ expiresAt
			ifNil: [ 'Codex connected.' ]
			ifNotNil: [ 'Codex connected until ' , expiresAt printString ] ].
	self codexAuthStatus = #requestingCode ifTrue: [
		^ 'Requesting a device code from OpenAI...' ].
	self codexAuthStatus = #waitingForApproval ifTrue: [
		^ 'Waiting for authorization. Enter the device code in your browser.' ].
	self codexAuthStatus = #error ifTrue: [
		^ self codexAuthErrorText ifNil: [ 'Codex login failed.' ] ].
	^ 'Codex not connected.'
]

{ #category : 'testing' }
SloptalkApp >> codexAuthWaitingForApproval [
	self ensureInitializedState.
	^ self codexAuthStatus = #waitingForApproval
]

{ #category : 'testing' }
SloptalkApp >> codexConnected [
	self ensureInitializedState.
	^ codexSession isNotNil and: [ codexSession isConnected ]
]

{ #category : 'accessing' }
SloptalkApp >> codexLoginStatusText [
	self ensureInitializedState.
	^ self codexAuthStatusText
]

{ #category : 'accessing' }
SloptalkApp >> codexSession [
	self ensureInitializedState.
	^ codexSession
]

{ #category : 'accessing' }
SloptalkApp >> codexSession: aSloptalkCodexSession [
	self ensureInitializedState.
	codexSession := aSloptalkCodexSession.
	self applyCodexSessionToAgentIfNeeded.
	codexSession
		ifNil: [
			self
				setCodexAuthStateStatus: #notConnected
				errorText: nil
				deviceAuthId: nil
				userCode: nil
				verificationUrl: nil ]
		ifNotNil: [
			self
				setCodexAuthStateStatus: #connected
				errorText: nil
				deviceAuthId: nil
				userCode: nil
				verificationUrl: nil ].
	self announceCodexAuthChanged
]

{ #category : 'accessing' }
SloptalkApp >> codexUserCode [
	self ensureInitializedState.
	^ codexAuthState at: #userCode ifAbsent: [ nil ]
]

{ #category : 'accessing' }
SloptalkApp >> codexVerificationUrl [
	self ensureInitializedState.
	^ codexAuthState at: #verificationUrl ifAbsent: [ nil ]
]

{ #category : 'api' }
SloptalkApp >> disconnectCodexSession [
	self cancelCodexDeviceLogin.
	codexSession := nil.
	self applyCodexSessionToAgentIfNeeded.
	self
		setCodexAuthStateStatus: #notConnected
		errorText: nil
		deviceAuthId: nil
		userCode: nil
		verificationUrl: nil.
	self announceCodexAuthChanged
]

{ #category : 'initialization' }
SloptalkApp >> ensureInitializedState [
	agent ifNil: [
		agent := SloptalkAgent new ].
	providerSettings ifNil: [
		providerSettings := Dictionary new.
		self initializeProviderSettings.
		openAIApiKey ifNil: [
			openAIApiKey := OSEnvironment current
				at: 'OPENAI_API_KEY'
				ifAbsent: [ nil ] ] ].
	codexAuthState ifNil: [
		codexAuthState := Dictionary new.
		self
			setCodexAuthStateStatus: ((codexSession isNotNil and: [ codexSession isConnected ])
				ifTrue: [ #connected ]
				ifFalse: [ #notConnected ])
			errorText: nil
			deviceAuthId: nil
			userCode: nil
			verificationUrl: nil ].
	(agent provider isKindOf: SloptalkCodexOAuthProvider) ifTrue: [
		agent provider session: codexSession ].
	^ self
]

{ #category : 'initialization' }
SloptalkApp >> initialize [
	super initialize.
	agent := SloptalkAgent new.
	openAIApiKey := OSEnvironment current
		at: 'OPENAI_API_KEY'
		ifAbsent: [ nil ].
	providerSettings := Dictionary new.
	codexAuthState := Dictionary new.
	codexAuthProcess := nil.
	self initializeProviderSettings.
	self
		setCodexAuthStateStatus: #notConnected
		errorText: nil
		deviceAuthId: nil
		userCode: nil
		verificationUrl: nil
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
		at: #codexOAuth
		put: ({
			#baseUrl -> 'https://chatgpt.com/backend-api/codex'.
			#model -> 'gpt-5.3-codex'
		} asDictionary).
	providerSettings
		at: #openAI
		put: ({
			#baseUrl -> 'https://api.openai.com'.
			#model -> 'gpt-4.1-mini'
		} asDictionary)
]

{ #category : 'accessing' }
SloptalkApp >> model [
	self ensureInitializedState.
	^ agent model
]

{ #category : 'debugging' }
SloptalkApp >> lastLLMRequest [
	self ensureInitializedState.
	^ agent lastLLMRequest
]

{ #category : 'debugging' }
SloptalkApp >> lastLLMResponse [
	self ensureInitializedState.
	^ agent lastLLMResponse
]

{ #category : 'accessing' }
SloptalkApp >> model: aString [
	self ensureInitializedState.
	agent model: aString
]

{ #category : 'accessing' }
SloptalkApp >> modelForProviderKind: aSymbol [
	self ensureInitializedState.
	^ (providerSettings
		at: aSymbol
		ifAbsent: [ self error: 'Unknown provider kind: ' , aSymbol asString ])
			at: #model
]

{ #category : 'api' }
SloptalkApp >> openCodexAuthenticationDocs [
	self ensureInitializedState.
	^ SloptalkCodexAuth openAuthenticationDocs
]

{ #category : 'debugging' }
SloptalkApp >> openTranscriptPlayground [
	self ensureInitializedState.
	UIManager default defer: [
		(Smalltalk tools toolNamed: #workspace)
			openContents: self debugTranscriptPlaygroundContents ]
]

{ #category : 'accessing' }
SloptalkApp >> provider [
	self ensureInitializedState.
	^ agent provider
]

{ #category : 'accessing' }
SloptalkApp >> provider: aSloptalkLLMProvider [
	self ensureInitializedState.
	agent provider: aSloptalkLLMProvider
]

{ #category : 'accessing' }
SloptalkApp >> providerChoices [
	self ensureInitializedState.
	^ #(#localOllama #codexOAuth #openAI)
]

{ #category : 'accessing' }
SloptalkApp >> providerDescription [
	self ensureInitializedState.
	^ agent providerDescription
]

{ #category : 'accessing' }
SloptalkApp >> providerDisplayNameFor: aSymbol [
	self ensureInitializedState.
	aSymbol = #localOllama ifTrue: [ ^ 'Local Ollama' ].
	aSymbol = #codexOAuth ifTrue: [ ^ 'Codex ChatGPT' ].
	aSymbol = #openAI ifTrue: [ ^ 'OpenAI API' ].
	^ aSymbol asString
]

{ #category : 'accessing' }
SloptalkApp >> providerKind [
	self ensureInitializedState.
	(agent provider isKindOf: SloptalkLocalOllamaProvider) ifTrue: [ ^ #localOllama ].
	(agent provider isKindOf: SloptalkCodexOAuthProvider) ifTrue: [ ^ #codexOAuth ].
	(agent provider isKindOf: SloptalkOpenAIProvider) ifTrue: [ ^ #openAI ].
	^ #openAI
]

{ #category : 'accessing' }
SloptalkApp >> requestTimeoutSeconds [
	self ensureInitializedState.
	^ agent requestTimeoutSeconds
]

{ #category : 'accessing' }
SloptalkApp >> requestTimeoutSeconds: anInteger [
	self ensureInitializedState.
	agent requestTimeoutSeconds: anInteger
]

{ #category : 'api' }
SloptalkApp >> resetConversation [
	self ensureInitializedState.
	agent resetConversation
]

{ #category : 'api' }
SloptalkApp >> send: aString [
	self ensureInitializedState.
	^ agent send: aString
]

{ #category : 'api' }
SloptalkApp >> sendAndWait: aString [
	self ensureInitializedState.
	^ agent sendAndWait: aString
]

{ #category : 'private' }
SloptalkApp >> setCodexAuthStateStatus: aStatusSymbol errorText: anErrorText deviceAuthId: aDeviceAuthId userCode: aUserCode verificationUrl: aVerificationUrl [
	codexAuthState := {
		#status -> aStatusSymbol.
		#errorText -> anErrorText.
		#deviceAuthId -> aDeviceAuthId.
		#userCode -> aUserCode.
		#verificationUrl -> aVerificationUrl
	} asDictionary
]

{ #category : 'api' }
SloptalkApp >> startCodexDeviceLogin [
	| process |
	self ensureInitializedState.
	(codexAuthProcess notNil and: [ codexAuthProcess isTerminated not ]) ifTrue: [ ^ self ].
	self
		setCodexAuthStateStatus: #requestingCode
		errorText: nil
		deviceAuthId: nil
		userCode: nil
		verificationUrl: nil.
	self announceCodexAuthChanged.

	process := [
		| deviceCode interval maxAttempts pollResult tokenResponse session |
		[
			[
				deviceCode := SloptalkCodexAuth requestDeviceCode.
				interval := deviceCode at: #interval ifAbsent: [ 5 ].
				self
					setCodexAuthStateStatus: #waitingForApproval
					errorText: nil
					deviceAuthId: (deviceCode at: #deviceAuthId)
					userCode: (deviceCode at: #userCode)
					verificationUrl: (deviceCode at: #verificationUrl).
				self announceCodexAuthChanged.
				UIManager default defer: [
					WebBrowser openOn: (deviceCode at: #verificationUrl).
					UIManager default inform: (self codexDeviceCodePromptTextFor: deviceCode) ].

				maxAttempts := ((15 * 60) / interval) ceiling.
				1 to: maxAttempts do: [ :attempt |
					pollResult := SloptalkCodexAuth
						pollDeviceAuthorizationForId: (deviceCode at: #deviceAuthId)
						userCode: (deviceCode at: #userCode).
					(pollResult at: #status) = #authorized ifTrue: [
						tokenResponse := SloptalkCodexAuth
							exchangeDeviceAuthorizationCode: (pollResult at: #authorizationCode)
							codeVerifier: (pollResult at: #codeVerifier).
						session := SloptalkCodexSession
							accessToken: (tokenResponse at: #accessToken)
							refreshToken: (tokenResponse at: #refreshToken)
							idToken: (tokenResponse at: #idToken)
							expiresAt: (DateAndTime now + (Duration seconds: (tokenResponse at: #expiresIn)))
							accountId: (SloptalkCodexAuth extractAccountIdFromTokens: tokenResponse).
						codexSession := session.
						self applyCodexSessionToAgentIfNeeded.
						self
							setCodexAuthStateStatus: #connected
							errorText: nil
							deviceAuthId: nil
							userCode: nil
							verificationUrl: nil.
						self announceCodexAuthChanged.
						^ self ].
					(pollResult at: #status) = #declined ifTrue: [
						self
							setCodexAuthStateStatus: #error
							errorText: (pollResult at: #errorText)
							deviceAuthId: nil
							userCode: nil
							verificationUrl: nil.
						self announceCodexAuthChanged.
						^ self ].
					(pollResult at: #status) = #error ifTrue: [
						self
							setCodexAuthStateStatus: #error
							errorText: (pollResult at: #errorText)
							deviceAuthId: nil
							userCode: nil
							verificationUrl: nil.
						self announceCodexAuthChanged.
						^ self ].
					attempt = maxAttempts ifFalse: [
						(Delay forSeconds: interval) wait ] ].

				self
					setCodexAuthStateStatus: #error
					errorText: 'Authorization timed out. Please try again.'
					deviceAuthId: nil
					userCode: nil
					verificationUrl: nil.
				self announceCodexAuthChanged
			] on: Error do: [ :error |
				self
					setCodexAuthStateStatus: #error
					errorText: error messageText
					deviceAuthId: nil
					userCode: nil
					verificationUrl: nil.
				self announceCodexAuthChanged ]
		] ensure: [ codexAuthProcess := nil ]
	] forkAt: Processor userBackgroundPriority named: 'Sloptalk Codex login'.

	codexAuthProcess := process
]

{ #category : 'printing' }
SloptalkApp >> transcriptString [
	self ensureInitializedState.
	^ agent transcriptString
]

{ #category : 'debugging' }
SloptalkApp >> transcriptMessages [
	self ensureInitializedState.
	^ agent conversation messages
]

{ #category : 'accessing' }
SloptalkApp >> updateSettingsForProviderKind: aSymbol model: aModelString baseUrl: aBaseUrlString [
	| settings |
	self ensureInitializedState.
	settings := providerSettings
		at: aSymbol
		ifAbsent: [ self error: 'Unknown provider kind: ' , aSymbol asString ].
	settings
		at: #model put: aModelString;
		at: #baseUrl put: aBaseUrlString
]

{ #category : 'accessing' }
SloptalkApp >> workspacePath [
	self ensureInitializedState.
	^ agent workspacePath
]

{ #category : 'accessing' }
SloptalkApp >> workspacePath: aString [
	self ensureInitializedState.
	agent workspacePath: aString
]
