"I carry one normalized request from Sloptalk to an LLM provider."
Class {
	#name : 'SloptalkLLMRequest',
	#superclass : 'Object',
	#instVars : [
		'inputItems'
	],
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'instance creation' }
SloptalkLLMRequest class >> inputItems: aCollection [
	^ self new
		inputItems: aCollection;
		yourself
]

{ #category : 'instance creation' }
SloptalkLLMRequest class >> systemPrompt: aString messages: aCollection [
	| items normalizedPrompt |
	items := OrderedCollection new.
	normalizedPrompt := (aString ifNil: [ '' ]) trimBoth.
	normalizedPrompt ifNotEmpty: [
		items add: (SloptalkLLMInputItem systemText: normalizedPrompt) ].
	items addAll: aCollection.
	^ self new
		inputItems: items;
		yourself
]

{ #category : 'initialization' }
SloptalkLLMRequest >> initialize [
	super initialize.
	inputItems := #()
]

{ #category : 'accessing' }
SloptalkLLMRequest >> inputItems [
	^ inputItems
]

{ #category : 'accessing' }
SloptalkLLMRequest >> inputItems: aCollection [
	inputItems := aCollection asArray
]

{ #category : 'accessing' }
SloptalkLLMRequest >> messages [
	^ self inputItems
]

{ #category : 'accessing' }
SloptalkLLMRequest >> messages: aCollection [
	self inputItems: aCollection
]

{ #category : 'accessing' }
SloptalkLLMRequest >> nonSystemInputItems [
	^ inputItems reject: [ :each | each isSystemMessage ]
]

{ #category : 'accessing' }
SloptalkLLMRequest >> systemPrompt [
	| systemItems |
	systemItems := inputItems select: [ :each | each isSystemMessage ].
	^ String streamContents: [ :stream |
		systemItems
			doWithIndex: [ :each :index |
				index > 1 ifTrue: [
					stream
						nextPut: Character lf;
						nextPut: Character lf ].
				stream nextPutAll: each text ] ]
]

{ #category : 'accessing' }
SloptalkLLMRequest >> systemPrompt: aString [
	| items normalizedPrompt |
	items := OrderedCollection withAll: self nonSystemInputItems.
	normalizedPrompt := (aString ifNil: [ '' ]) trimBoth.
	normalizedPrompt ifNotEmpty: [
		items addFirst: (SloptalkLLMInputItem systemText: normalizedPrompt) ].
	inputItems := items asArray
]
