"I configure Sloptalk providers and authentication settings."
Class {
	#name : 'SloptalkSettingsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'app',
		'noteLabel',
		'providerDropList',
		'modelInput',
		'baseUrlInput',
		'workspacePathInput',
		'timeoutInput',
		'apiKeyStatusLabel',
		'codexStatusLabel',
		'setApiKeyButton',
		'clearApiKeyButton',
		'codexDeviceLoginButton',
		'refreshCodexStatusButton',
		'codexDocsButton',
		'saveButton'
	],
	#category : 'Sloptalk-UI',
	#package : 'Sloptalk',
	#tag : 'UI'
}

{ #category : 'accessing' }
SloptalkSettingsPresenter class >> defaultPreferredExtent [
	^ 720 @ 560
]

{ #category : 'accessing' }
SloptalkSettingsPresenter class >> descriptionText [
	^ 'Configure Sloptalk providers and authentication.'
]

{ #category : 'class initialization' }
SloptalkSettingsPresenter class >> initialize [
	self registerToolsOn: Smalltalk tools
]

{ #category : 'api' }
SloptalkSettingsPresenter class >> open [
	^ self openForApp: SloptalkApp current
]

{ #category : 'api' }
SloptalkSettingsPresenter class >> openForApp: aSloptalkApp [
	^ (self newApplication: StPharoApplication current)
		app: aSloptalkApp;
		open;
		yourself
]

{ #category : 'tools registry' }
SloptalkSettingsPresenter class >> registerToolsOn: registry [
	registry register: self as: #sloptalkSettings
]

{ #category : 'accessing' }
SloptalkSettingsPresenter >> app [
	^ app ifNil: [ app := SloptalkApp current ]
]

{ #category : 'accessing' }
SloptalkSettingsPresenter >> app: aSloptalkApp [
	app := aSloptalkApp
]

{ #category : 'actions' }
SloptalkSettingsPresenter >> applySettings [
	| providerKind timeoutText timeoutSeconds workspacePath |
	providerKind := providerDropList selectedItem ifNil: [ #localOllama ].
	timeoutText := timeoutInput text asString trimBoth.
	timeoutSeconds := timeoutText
		ifEmpty: [ self app requestTimeoutSeconds ]
		ifNotEmpty: [
			[ timeoutText asInteger ]
				on: Error
				do: [ :error |
					self inform: 'Timeout must be an integer number of seconds.'.
					^ self ] ].
	workspacePath := workspacePathInput text asString trimBoth.

	self storeInputsForProviderKind: providerKind.
	self app
		applySettingsProviderKind: providerKind
		model: modelInput text asString trimBoth
		baseUrl: baseUrlInput text asString trimBoth
		requestTimeoutSeconds: timeoutSeconds
		workspacePath: workspacePath.

	self refreshFromApp.
	self inform: 'Sloptalk settings updated.'
]

{ #category : 'initialization' }
SloptalkSettingsPresenter >> connectPresenters [
	providerDropList whenSelectedItemChangedDo: [ :aSymbol |
		aSymbol ifNotNil: [ self refreshProviderInputsFor: aSymbol ] ].
	setApiKeyButton action: [ self promptForApiKey ].
	clearApiKeyButton action: [ self clearApiKey ].
	codexDeviceLoginButton action: [ self startCodexDeviceLogin ].
	refreshCodexStatusButton action: [ self updateCodexStatus ].
	codexDocsButton action: [ self app openCodexAuthenticationDocs ].
	saveButton action: [ self applySettings ].
	self refreshFromApp
]

{ #category : 'layout' }
SloptalkSettingsPresenter >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		spacing: 6;
		add: noteLabel expand: false;
		add: (self labeledRowWith: 'Provider' presenter: providerDropList) expand: false;
		add: (self labeledRowWith: 'Model' presenter: modelInput) expand: false;
		add: (self labeledRowWith: 'Base URL' presenter: baseUrlInput) expand: false;
		add: (self labeledRowWith: 'Workspace' presenter: workspacePathInput) expand: false;
		add: (self labeledRowWith: 'Timeout (s)' presenter: timeoutInput) expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 5;
				add: apiKeyStatusLabel;
				add: setApiKeyButton expand: false;
				add: clearApiKeyButton expand: false;
				yourself)
			expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 5;
				add: codexStatusLabel;
				add: codexDeviceLoginButton expand: false;
				add: refreshCodexStatusButton expand: false;
				add: codexDocsButton expand: false;
				yourself)
			expand: false;
		add: saveButton expand: false;
		yourself
]

{ #category : 'actions' }
SloptalkSettingsPresenter >> clearApiKey [
	self app clearApiKey.
	self updateApiKeyStatus
]

{ #category : 'initialization' }
SloptalkSettingsPresenter >> initializePresenters [
	app ifNil: [ app := SloptalkApp current ].

	noteLabel := self newLabel
		label:
			'OpenAI API calls use API keys. Codex ChatGPT login is separate and is shown here for a future Codex-backed provider.';
		yourself.

	providerDropList := self newDropList
		items: self app providerChoices;
		display: [ :each | self app providerDisplayNameFor: each ];
		yourself.

	modelInput := self newTextInput.
	baseUrlInput := self newTextInput.
	workspacePathInput := self newTextInput.
	timeoutInput := self newTextInput autoAccept: true.

	apiKeyStatusLabel := self newLabel.
	codexStatusLabel := self newLabel.

	setApiKeyButton := self newButton
		label: 'Set API Key';
		yourself.

	clearApiKeyButton := self newButton
		label: 'Clear API Key';
		yourself.

	codexDeviceLoginButton := self newButton
		label: 'Codex Login';
		yourself.

	refreshCodexStatusButton := self newButton
		label: 'Refresh Codex';
		yourself.

	codexDocsButton := self newButton
		label: 'Codex Docs';
		yourself.

	saveButton := self newButton
		label: 'Apply Settings';
		yourself.

	self refreshFromApp
]

{ #category : 'initialization' }
SloptalkSettingsPresenter >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self windowTitle;
		initialExtent: self class defaultPreferredExtent
]

{ #category : 'layout' }
SloptalkSettingsPresenter >> labeledRowWith: aString presenter: aPresenter [
	^ SpBoxLayout newLeftToRight
		spacing: 5;
		add: (self newLabel label: aString; yourself) expand: false;
		add: aPresenter;
		yourself
]

{ #category : 'actions' }
SloptalkSettingsPresenter >> promptForApiKey [
	| apiKey |
	apiKey := UIManager default
		requestPassword: 'Enter the OpenAI API key for Sloptalk'.
	apiKey ifNil: [ ^ self ].
	self app apiKey: apiKey trimBoth.
	self updateApiKeyStatus
]

{ #category : 'api' }
SloptalkSettingsPresenter >> refreshCodexStatus [
	self updateCodexStatus
]

{ #category : 'api' }
SloptalkSettingsPresenter >> refreshFromApp [
	| providerKind |
	providerKind := self app providerKind.
	providerDropList selectItem: providerKind.
	self refreshProviderInputsFor: providerKind.
	workspacePathInput text: self app workspacePath asString.
	timeoutInput text: self app requestTimeoutSeconds asString.
	self updateApiKeyStatus.
	self updateCodexStatus
]

{ #category : 'api' }
SloptalkSettingsPresenter >> refreshProviderInputsFor: aSymbol [
	modelInput text: (self app modelForProviderKind: aSymbol).
	baseUrlInput text: (self app baseUrlForProviderKind: aSymbol)
]

{ #category : 'actions' }
SloptalkSettingsPresenter >> startCodexDeviceLogin [
	self app startCodexDeviceLogin.
	self updateCodexStatus
]

{ #category : 'private' }
SloptalkSettingsPresenter >> storeInputsForProviderKind: aSymbol [
	self app
		updateSettingsForProviderKind: aSymbol
		model: modelInput text asString trimBoth
		baseUrl: baseUrlInput text asString trimBoth
]

{ #category : 'updating' }
SloptalkSettingsPresenter >> updateApiKeyStatus [
	apiKeyStatusLabel label: self app apiKeyStatusText
]

{ #category : 'updating' }
SloptalkSettingsPresenter >> updateCodexStatus [
	codexStatusLabel label: 'Codex: ' , self app codexLoginStatusText
]

{ #category : 'accessing' }
SloptalkSettingsPresenter >> windowTitle [
	^ 'Sloptalk Settings'
]
