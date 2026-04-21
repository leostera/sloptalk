"I represent one typed content part inside a normalized LLM input or output item."
Class {
	#name : 'SloptalkLLMContentPart',
	#superclass : 'Object',
	#instVars : [
		'type',
		'text',
		'value',
		'url'
	],
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'instance creation' }
SloptalkLLMContentPart class >> imageUrl: aString [
	^ self new
		type: 'imageUrl';
		url: aString;
		yourself
]

{ #category : 'instance creation' }
SloptalkLLMContentPart class >> json: anObject [
	^ self new
		type: 'json';
		value: anObject;
		yourself
]

{ #category : 'instance creation' }
SloptalkLLMContentPart class >> text: aString [
	^ self new
		type: 'text';
		text: aString;
		yourself
]

{ #category : 'printing' }
SloptalkLLMContentPart >> displayText [
	self isText ifTrue: [ ^ text ifNil: [ '' ] ].
	self isJson ifTrue: [ ^ value printString ].
	self isImageUrl ifTrue: [ ^ url ifNil: [ '' ] ].
	^ ''
]

{ #category : 'testing' }
SloptalkLLMContentPart >> isImageUrl [
	^ type = 'imageUrl'
]

{ #category : 'testing' }
SloptalkLLMContentPart >> isJson [
	^ type = 'json'
]

{ #category : 'testing' }
SloptalkLLMContentPart >> isText [
	^ type = 'text'
]

{ #category : 'accessing' }
SloptalkLLMContentPart >> text [
	^ text
]

{ #category : 'accessing' }
SloptalkLLMContentPart >> text: aString [
	text := aString ifNil: [ '' ]
]

{ #category : 'accessing' }
SloptalkLLMContentPart >> type [
	^ type
]

{ #category : 'accessing' }
SloptalkLLMContentPart >> type: aString [
	type := aString ifNil: [ 'text' ]
]

{ #category : 'accessing' }
SloptalkLLMContentPart >> url [
	^ url
]

{ #category : 'accessing' }
SloptalkLLMContentPart >> url: aString [
	url := aString
]

{ #category : 'accessing' }
SloptalkLLMContentPart >> value [
	^ value
]

{ #category : 'accessing' }
SloptalkLLMContentPart >> value: anObject [
	value := anObject
]
