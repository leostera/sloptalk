"I show settings relevant to the OpenAI API provider."
Class {
	#name : 'SloptalkOpenAISettingsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'app',
		'noteLabel',
		'modelInput',
		'baseUrlInput',
		'apiKeyStatusLabel',
		'setApiKeyButton',
		'clearApiKeyButton'
	],
	#category : 'Sloptalk-UI',
	#package : 'Sloptalk',
	#tag : 'UI'
}

{ #category : 'accessing' }
SloptalkOpenAISettingsPresenter >> app [
	app ifNil: [ app := SloptalkApp current ].
	app ensureInitializedState.
	^ app
]

{ #category : 'accessing' }
SloptalkOpenAISettingsPresenter >> app: aSloptalkApp [
	app := aSloptalkApp.
	app ensureInitializedState
]

{ #category : 'accessing' }
SloptalkOpenAISettingsPresenter >> baseUrl [
	^ baseUrlInput text asString trimBoth
]

{ #category : 'accessing' }
SloptalkOpenAISettingsPresenter >> baseUrl: aString [
	baseUrlInput text: aString.
	self updateApiKeyStatus
]

{ #category : 'actions' }
SloptalkOpenAISettingsPresenter >> clearApiKey [
	self app clearApiKey.
	self updateApiKeyStatus
]

{ #category : 'initialization' }
SloptalkOpenAISettingsPresenter >> connectPresenters [
	setApiKeyButton action: [ self promptForApiKey ].
	clearApiKeyButton action: [ self clearApiKey ].
	self updateApiKeyStatus
]

{ #category : 'layout' }
SloptalkOpenAISettingsPresenter >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		spacing: 6;
		add: noteLabel expand: false;
		add: (self labeledRowWith: 'Model' presenter: modelInput) expand: false;
		add: (self labeledRowWith: 'Base URL' presenter: baseUrlInput) expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 5;
				add: apiKeyStatusLabel;
				add: setApiKeyButton expand: false;
				add: clearApiKeyButton expand: false;
				yourself)
			expand: false;
		yourself
]

{ #category : 'initialization' }
SloptalkOpenAISettingsPresenter >> initializePresenters [
	noteLabel := self newLabel
		label: 'Use the OpenAI API directly. This provider requires an API key.';
		yourself.
	modelInput := self newTextInput.
	baseUrlInput := self newTextInput.
	apiKeyStatusLabel := self newLabel.
	setApiKeyButton := self newButton
		label: 'Set API Key';
		yourself.
	clearApiKeyButton := self newButton
		label: 'Clear API Key';
		yourself
]

{ #category : 'layout' }
SloptalkOpenAISettingsPresenter >> labeledRowWith: aString presenter: aPresenter [
	^ SpBoxLayout newLeftToRight
		spacing: 5;
		add: (self newLabel label: aString; yourself) expand: false;
		add: aPresenter;
		yourself
]

{ #category : 'accessing' }
SloptalkOpenAISettingsPresenter >> model [
	^ modelInput text asString trimBoth
]

{ #category : 'accessing' }
SloptalkOpenAISettingsPresenter >> model: aString [
	modelInput text: aString.
	self updateApiKeyStatus
]

{ #category : 'actions' }
SloptalkOpenAISettingsPresenter >> promptForApiKey [
	| apiKey |
	apiKey := UIManager default
		requestPassword: 'Enter the OpenAI API key for Sloptalk'.
	apiKey ifNil: [ ^ self ].
	self app apiKey: apiKey trimBoth.
	self updateApiKeyStatus
]

{ #category : 'api' }
SloptalkOpenAISettingsPresenter >> refreshFromApp [
	self updateApiKeyStatus
]

{ #category : 'updating' }
SloptalkOpenAISettingsPresenter >> updateApiKeyStatus [
	apiKeyStatusLabel label: self app apiKeyStatusText
]
