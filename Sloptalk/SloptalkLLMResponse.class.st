"I carry one normalized response from an LLM provider back into Sloptalk."
Class {
	#name : 'SloptalkLLMResponse',
	#superclass : 'Object',
	#instVars : [
		'text',
		'payload',
		'metadata'
	],
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'instance creation' }
SloptalkLLMResponse class >> text: aString [
	^ self text: aString payload: nil metadata: Dictionary new
]

{ #category : 'instance creation' }
SloptalkLLMResponse class >> text: aString payload: anObject metadata: aDictionary [
	^ self new
		text: aString;
		payload: anObject;
		metadata: aDictionary;
		yourself
]

{ #category : 'initialization' }
SloptalkLLMResponse >> initialize [
	super initialize.
	text := ''.
	payload := nil.
	metadata := Dictionary new
]

{ #category : 'accessing' }
SloptalkLLMResponse >> metadata [
	^ metadata
]

{ #category : 'accessing' }
SloptalkLLMResponse >> metadata: aDictionary [
	metadata := aDictionary ifNil: [ Dictionary new ]
]

{ #category : 'accessing' }
SloptalkLLMResponse >> metadataAt: aKey ifAbsent: aBlock [
	^ metadata
		at: aKey
		ifAbsent: [
			metadata
				at: aKey asString
				ifAbsent: aBlock ]
]

{ #category : 'accessing' }
SloptalkLLMResponse >> payload [
	^ payload
]

{ #category : 'accessing' }
SloptalkLLMResponse >> payload: anObject [
	payload := anObject
]

{ #category : 'accessing' }
SloptalkLLMResponse >> text [
	^ text
]

{ #category : 'accessing' }
SloptalkLLMResponse >> text: aString [
	text := aString ifNil: [ '' ]
]
