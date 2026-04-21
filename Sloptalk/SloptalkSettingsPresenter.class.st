"I configure Sloptalk providers and authentication settings."
Class {
	#name : 'SloptalkSettingsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'app',
		'providerDropList',
		'providerSettingsPresenter',
		'localOllamaSettingsPresenter',
		'codexSettingsPresenter',
		'openAISettingsPresenter',
		'workspacePathInput',
		'timeoutInput',
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
	app ifNil: [ app := SloptalkApp current ].
	app ensureInitializedState.
	^ app
]

{ #category : 'accessing' }
SloptalkSettingsPresenter >> app: aSloptalkApp [
	app := aSloptalkApp.
	app ensureInitializedState
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

	self app
		applySettingsProviderKind: providerKind
		model: providerSettingsPresenter model
		baseUrl: providerSettingsPresenter baseUrl
		requestTimeoutSeconds: timeoutSeconds
		workspacePath: workspacePath.

	self refreshFromApp.
	self inform: 'Sloptalk settings updated.'
]

{ #category : 'private' }
SloptalkSettingsPresenter >> changeProviderSettingsPresenterFor: aSymbol [
	| newPresenter |
	newPresenter := self providerSettingsPresenterFor: aSymbol.
	providerSettingsPresenter == newPresenter ifTrue: [
		self refreshProviderInputsFor: aSymbol.
		^ self ].

	self layout replace: providerSettingsPresenter with: newPresenter.
	providerSettingsPresenter := newPresenter.
	self refreshProviderInputsFor: aSymbol
]

{ #category : 'initialization' }
SloptalkSettingsPresenter >> connectPresenters [
	providerDropList whenSelectedItemChangedDo: [ :aSymbol |
		aSymbol ifNotNil: [ self changeProviderSettingsPresenterFor: aSymbol ] ].
	saveButton action: [ self applySettings ].
	self subscribeToApp.
	self refreshFromApp
]

{ #category : 'layout' }
SloptalkSettingsPresenter >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		spacing: 6;
		add: (self labeledRowWith: 'Provider' presenter: providerDropList) expand: false;
		add: providerSettingsPresenter expand: false;
		add: (self labeledRowWith: 'Workspace' presenter: workspacePathInput) expand: false;
		add: (self labeledRowWith: 'Timeout (s)' presenter: timeoutInput) expand: false;
		add: saveButton expand: false;
		yourself
]

{ #category : 'announcements' }
SloptalkSettingsPresenter >> handleCodexAuthAnnouncement: anAnnouncement [
	UIManager default defer: [ self refreshFromApp ]
]

{ #category : 'initialization' }
SloptalkSettingsPresenter >> initializePresenters [
	app ifNil: [ app := SloptalkApp current ].

	providerDropList := self newDropList
		items: self app providerChoices;
		display: [ :each | self app providerDisplayNameFor: each ];
		yourself.

	localOllamaSettingsPresenter := self instantiate: SloptalkLocalOllamaSettingsPresenter.
	codexSettingsPresenter := self instantiate: SloptalkCodexSettingsPresenter.
	codexSettingsPresenter app: self app.
	openAISettingsPresenter := self instantiate: SloptalkOpenAISettingsPresenter.
	openAISettingsPresenter app: self app.
	providerSettingsPresenter := self providerSettingsPresenterFor: self app providerKind.

	workspacePathInput := self newTextInput.
	timeoutInput := self newTextInput autoAccept: true.

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
		initialExtent: self class defaultPreferredExtent;
		whenClosedDo: [ self unsubscribeFromApp ]
]

{ #category : 'layout' }
SloptalkSettingsPresenter >> labeledRowWith: aString presenter: aPresenter [
	^ SpBoxLayout newLeftToRight
		spacing: 5;
		add: (self newLabel label: aString; yourself) expand: false;
		add: aPresenter;
		yourself
]

{ #category : 'private' }
SloptalkSettingsPresenter >> providerSettingsPresenterFor: aSymbol [
	aSymbol = #codexOAuth ifTrue: [ ^ codexSettingsPresenter ].
	aSymbol = #openAI ifTrue: [ ^ openAISettingsPresenter ].
	^ localOllamaSettingsPresenter
]

{ #category : 'api' }
SloptalkSettingsPresenter >> refreshFromApp [
	| providerKind |
	providerKind := providerDropList
		ifNil: [ self app providerKind ]
		ifNotNil: [ providerDropList selectedItem ifNil: [ self app providerKind ] ].
	providerDropList selectItem: providerKind.
	self changeProviderSettingsPresenterFor: providerKind.
	workspacePathInput text: self app workspacePath asString.
	timeoutInput text: self app requestTimeoutSeconds asString
]

{ #category : 'api' }
SloptalkSettingsPresenter >> refreshProviderInputsFor: aSymbol [
	providerSettingsPresenter
		model: (self app modelForProviderKind: aSymbol);
		baseUrl: (self app baseUrlForProviderKind: aSymbol).
	(providerSettingsPresenter respondsTo: #refreshFromApp) ifTrue: [
		providerSettingsPresenter refreshFromApp ]
]

{ #category : 'announcements' }
SloptalkSettingsPresenter >> subscribeToApp [
	self app announcer
		when: SloptalkCodexAuthAnnouncement
		send: #handleCodexAuthAnnouncement:
		to: self
]

{ #category : 'announcements' }
SloptalkSettingsPresenter >> unsubscribeFromApp [
	self app announcer unsubscribe: self
]

{ #category : 'accessing' }
SloptalkSettingsPresenter >> windowTitle [
	^ 'Sloptalk Settings'
]
