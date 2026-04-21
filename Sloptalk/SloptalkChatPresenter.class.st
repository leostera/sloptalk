"I provide a small chat UI over the shared Sloptalk agent."
Class {
	#name : 'SloptalkChatPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'app',
		'providerLabel',
		'transcriptPresenter',
		'inputPresenter',
		'statusLabel',
		'newChatButton',
		'settingsButton',
		'sendButton'
	],
	#category : 'Sloptalk-UI',
	#package : 'Sloptalk',
	#tag : 'UI'
}

{ #category : 'accessing' }
SloptalkChatPresenter class >> defaultPreferredExtent [
	^ 900 @ 700
]

{ #category : 'accessing' }
SloptalkChatPresenter class >> descriptionText [
	^ 'Chat with the shared Sloptalk agent running inside the image.'
]

{ #category : 'class initialization' }
SloptalkChatPresenter class >> initialize [
	self registerToolsOn: Smalltalk tools
]

{ #category : 'world menu' }
SloptalkChatPresenter class >> menuCommandOn: aBuilder [
	<worldMenu>

	(aBuilder item: 'Sloptalk Chat')
		parent: #Tools;
		action: [ self open ];
		order: 45;
		help: self descriptionText
]

{ #category : 'api' }
SloptalkChatPresenter class >> open [
	^ (self newApplication: StPharoApplication current)
		open;
		yourself
]

{ #category : 'tools registry' }
SloptalkChatPresenter class >> registerToolsOn: registry [
	registry register: self as: #sloptalkChat
]

{ #category : 'accessing' }
SloptalkChatPresenter >> agent [
	^ self app agent
]

{ #category : 'accessing' }
SloptalkChatPresenter >> app [
	^ app ifNil: [ app := SloptalkApp current ]
]

{ #category : 'accessing' }
SloptalkChatPresenter >> app: aSloptalkApp [
	app := aSloptalkApp
]

{ #category : 'initialization' }
SloptalkChatPresenter >> connectPresenters [
	sendButton action: [ self sendCurrentPrompt ].
	newChatButton action: [ self resetConversation ].
	settingsButton action: [ self openSettings ].
	inputPresenter whenTextChangedDo: [ :text | self updateSendButton ].
	self subscribeToAgent.
	self refreshPresenter
]

{ #category : 'layout' }
SloptalkChatPresenter >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		spacing: 5;
		add: providerLabel expand: false;
		add: transcriptPresenter;
		add: inputPresenter height: 120;
		add: (SpBoxLayout newLeftToRight
				spacing: 5;
				add: statusLabel;
				add: newChatButton expand: false;
				add: settingsButton expand: false;
				add: sendButton expand: false;
				yourself)
			expand: false;
		yourself
]

{ #category : 'announcements' }
SloptalkChatPresenter >> handleTurnAnnouncement: anAnnouncement [
	UIManager default defer: [ self refreshPresenter ]
]

{ #category : 'initialization' }
SloptalkChatPresenter >> initializePresenters [
	app ifNil: [ app := SloptalkApp current ].

	providerLabel := self newLabel.

	transcriptPresenter := self newCode
		withoutSyntaxHighlight;
		yourself.

	inputPresenter := self newText
		addStyle: 'lines4';
		beWrapWord;
		placeholder: 'Send a message to Sloptalk...';
		yourself.

	statusLabel := self newLabel.

	newChatButton := self newButton
		label: 'New Chat';
		yourself.

	settingsButton := self newButton
		label: 'Settings';
		yourself.

	sendButton := self newButton
		label: 'Send';
		yourself.

	self refreshPresenter
]

{ #category : 'initialization' }
SloptalkChatPresenter >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self windowTitle;
		initialExtent: self class defaultPreferredExtent;
		whenClosedDo: [ self unsubscribeFromAgent ]
]

{ #category : 'api' }
SloptalkChatPresenter >> refreshPresenter [
	self updateProviderLabel.
	self updateTranscript.
	self updateStatusLabel.
	self updateSendButton
]

{ #category : 'api' }
SloptalkChatPresenter >> resetConversation [
	[
		self app resetConversation.
		self refreshPresenter
	] on: Error do: [ :error |
		self inform: error messageText ]
]

{ #category : 'actions' }
SloptalkChatPresenter >> openSettings [
	SloptalkSettingsPresenter openForApp: self app
]

{ #category : 'actions' }
SloptalkChatPresenter >> sendCurrentPrompt [
	| text |
	text := inputPresenter text asString trimBoth.
	text ifEmpty: [ ^ self ].
	inputPresenter text: ''.
	self app send: text.
	self refreshPresenter
]

{ #category : 'printing' }
SloptalkChatPresenter >> statusText [
	| agent |
	agent := self agent.
	^ String streamContents: [ :stream |
		stream
			nextPutAll: (agent busy
				ifTrue: [ 'Busy' ]
				ifFalse: [ 'Idle' ]);
			nextPutAll: ' | Queue: ';
			nextPutAll: agent pendingTurns size asString ]
]

{ #category : 'announcements' }
SloptalkChatPresenter >> subscribeToAgent [
	self agent
		when: SloptalkTurnAnnouncement
		send: #handleTurnAnnouncement:
		to: self
]

{ #category : 'printing' }
SloptalkChatPresenter >> transcriptText [
	| transcript |
	transcript := self app transcriptString.
	^ transcript isEmpty
		ifTrue: [ 'Start a conversation with Sloptalk.' ]
		ifFalse: [ transcript ]
]

{ #category : 'announcements' }
SloptalkChatPresenter >> unsubscribeFromAgent [
	self agent unsubscribe: self
]

{ #category : 'updating' }
SloptalkChatPresenter >> updateProviderLabel [
	providerLabel label: 'Provider: ' , self app providerDescription
]

{ #category : 'updating' }
SloptalkChatPresenter >> updateSendButton [
	sendButton enabled: inputPresenter text asString trimBoth isNotEmpty
]

{ #category : 'updating' }
SloptalkChatPresenter >> updateStatusLabel [
	statusLabel label: self statusText
]

{ #category : 'updating' }
SloptalkChatPresenter >> updateTranscript [
	transcriptPresenter text: self transcriptText
]

{ #category : 'accessing' }
SloptalkChatPresenter >> windowTitle [
	^ 'Sloptalk'
]
