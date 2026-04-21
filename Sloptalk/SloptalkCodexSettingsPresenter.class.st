"I show settings relevant to the ChatGPT-backed Codex provider."
Class {
	#name : 'SloptalkCodexSettingsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'app',
		'noteLabel',
		'modelInput',
		'baseUrlInput',
		'statusLabel',
		'codeLabel',
		'connectButton',
		'openButton',
		'cancelButton',
		'disconnectButton'
	],
	#category : 'Sloptalk-UI',
	#package : 'Sloptalk',
	#tag : 'UI'
}

{ #category : 'accessing' }
SloptalkCodexSettingsPresenter >> app [
	app ifNil: [ app := SloptalkApp current ].
	app ensureInitializedState.
	^ app
]

{ #category : 'accessing' }
SloptalkCodexSettingsPresenter >> app: aSloptalkApp [
	app := aSloptalkApp.
	app ensureInitializedState
]

{ #category : 'actions' }
SloptalkCodexSettingsPresenter >> cancelLogin [
	self app cancelCodexDeviceLogin.
	self refreshFromApp
]

{ #category : 'accessing' }
SloptalkCodexSettingsPresenter >> baseUrl [
	^ baseUrlInput text asString trimBoth
]

{ #category : 'accessing' }
SloptalkCodexSettingsPresenter >> baseUrl: aString [
	baseUrlInput text: aString
]

{ #category : 'initialization' }
SloptalkCodexSettingsPresenter >> connectPresenters [
	connectButton action: [ self startLogin ].
	openButton action: [ self openVerificationUrl ].
	cancelButton action: [ self cancelLogin ].
	disconnectButton action: [ self disconnect ].
	self refreshFromApp
]

{ #category : 'layout' }
SloptalkCodexSettingsPresenter >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		spacing: 6;
		add: noteLabel expand: false;
		add: (self labeledRowWith: 'Model' presenter: modelInput) expand: false;
		add: (self labeledRowWith: 'Base URL' presenter: baseUrlInput) expand: false;
		add: statusLabel expand: false;
		add: codeLabel expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 5;
				add: connectButton expand: false;
				add: openButton expand: false;
				add: cancelButton expand: false;
				add: disconnectButton expand: false;
				yourself)
			expand: false;
		yourself
]

{ #category : 'actions' }
SloptalkCodexSettingsPresenter >> disconnect [
	self app disconnectCodexSession.
	self refreshFromApp
]

{ #category : 'initialization' }
SloptalkCodexSettingsPresenter >> initializePresenters [
	noteLabel := self newLabel
		label: 'Use your ChatGPT subscription to authenticate Sloptalk against the Codex backend.';
		yourself.
	modelInput := self newTextInput.
	baseUrlInput := self newTextInput.
	statusLabel := self newLabel.
	codeLabel := self newLabel.
	connectButton := self newButton
		label: 'Login with Codex';
		yourself.
	openButton := self newButton
		label: 'Open OpenAI';
		yourself.
	cancelButton := self newButton
		label: 'Cancel';
		yourself.
	disconnectButton := self newButton
		label: 'Disconnect';
		yourself
]

{ #category : 'layout' }
SloptalkCodexSettingsPresenter >> labeledRowWith: aString presenter: aPresenter [
	^ SpBoxLayout newLeftToRight
		spacing: 5;
		add: (self newLabel label: aString; yourself) expand: false;
		add: aPresenter;
		yourself
]

{ #category : 'accessing' }
SloptalkCodexSettingsPresenter >> model [
	^ modelInput text asString trimBoth
]

{ #category : 'accessing' }
SloptalkCodexSettingsPresenter >> model: aString [
	modelInput text: aString
]

{ #category : 'actions' }
SloptalkCodexSettingsPresenter >> openVerificationUrl [
	self app codexVerificationUrl ifNotNil: [ :url | WebBrowser openOn: url ]
]

{ #category : 'api' }
SloptalkCodexSettingsPresenter >> refreshFromApp [
	| status userCode canOpen isWaiting isConnected |
	status := self app codexAuthStatusText.
	userCode := self app codexUserCode.
	isWaiting := self app codexAuthWaitingForApproval.
	isConnected := self app codexConnected.
	canOpen := self app codexVerificationUrl isNotNil.

	statusLabel label: status.
	codeLabel label: (userCode
		ifNil: [ '' ]
		ifNotNil: [ 'Enter this code at OpenAI: ' , userCode ]).

	connectButton enabled: self app codexAuthCanStart.
	openButton enabled: canOpen.
	cancelButton enabled: isWaiting.
	disconnectButton enabled: isConnected
]

{ #category : 'actions' }
SloptalkCodexSettingsPresenter >> startLogin [
	self app startCodexDeviceLogin.
	self refreshFromApp
]
