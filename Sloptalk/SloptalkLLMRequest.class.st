"I carry one normalized request from Sloptalk to an LLM provider."
Class {
	#name : 'SloptalkLLMRequest',
	#superclass : 'Object',
	#instVars : [
		'systemPrompt',
		'messages'
	],
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'instance creation' }
SloptalkLLMRequest class >> systemPrompt: aString messages: aCollection [
	^ self new
		systemPrompt: aString;
		messages: aCollection;
		yourself
]

{ #category : 'initialization' }
SloptalkLLMRequest >> initialize [
	super initialize.
	systemPrompt := ''.
	messages := #()
]

{ #category : 'accessing' }
SloptalkLLMRequest >> messages [
	^ messages
]

{ #category : 'accessing' }
SloptalkLLMRequest >> messages: aCollection [
	messages := aCollection asArray
]

{ #category : 'accessing' }
SloptalkLLMRequest >> systemPrompt [
	^ systemPrompt
]

{ #category : 'accessing' }
SloptalkLLMRequest >> systemPrompt: aString [
	systemPrompt := aString ifNil: [ '' ]
]
