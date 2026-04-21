"I show settings relevant to the local Ollama provider."
Class {
	#name : 'SloptalkLocalOllamaSettingsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'noteLabel',
		'modelInput',
		'baseUrlInput'
	],
	#category : 'Sloptalk-UI',
	#package : 'Sloptalk',
	#tag : 'UI'
}

{ #category : 'accessing' }
SloptalkLocalOllamaSettingsPresenter >> baseUrl [
	^ baseUrlInput text asString trimBoth
]

{ #category : 'accessing' }
SloptalkLocalOllamaSettingsPresenter >> baseUrl: aString [
	baseUrlInput text: aString
]

{ #category : 'layout' }
SloptalkLocalOllamaSettingsPresenter >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		spacing: 6;
		add: noteLabel expand: false;
		add: (self labeledRowWith: 'Model' presenter: modelInput) expand: false;
		add: (self labeledRowWith: 'Base URL' presenter: baseUrlInput) expand: false;
		yourself
]

{ #category : 'initialization' }
SloptalkLocalOllamaSettingsPresenter >> initializePresenters [
	noteLabel := self newLabel
		label: 'Use a local OpenAI-compatible Ollama endpoint.';
		yourself.
	modelInput := self newTextInput.
	baseUrlInput := self newTextInput
]

{ #category : 'layout' }
SloptalkLocalOllamaSettingsPresenter >> labeledRowWith: aString presenter: aPresenter [
	^ SpBoxLayout newLeftToRight
		spacing: 5;
		add: (self newLabel label: aString; yourself) expand: false;
		add: aPresenter;
		yourself
]

{ #category : 'accessing' }
SloptalkLocalOllamaSettingsPresenter >> model [
	^ modelInput text asString trimBoth
]

{ #category : 'accessing' }
SloptalkLocalOllamaSettingsPresenter >> model: aString [
	modelInput text: aString
]

{ #category : 'api' }
SloptalkLocalOllamaSettingsPresenter >> refreshFromApp [
]
