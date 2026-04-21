"I represent one normalized provider output item, similar to `agents` raw output items."
Class {
	#name : 'SloptalkLLMOutputItem',
	#superclass : 'Object',
	#instVars : [
		'type',
		'role',
		'contentParts',
		'callId',
		'toolName',
		'arguments',
		'text'
	],
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'instance creation' }
SloptalkLLMOutputItem class >> assistantText: aString [
	^ self messageRole: 'assistant' text: aString
]

{ #category : 'instance creation' }
SloptalkLLMOutputItem class >> messageRole: aString contentParts: aCollection [
	^ self new
		type: 'message';
		role: aString;
		contentParts: aCollection;
		yourself
]

{ #category : 'instance creation' }
SloptalkLLMOutputItem class >> messageRole: aString text: aString [
	^ self
		messageRole: aString
		contentParts: { SloptalkLLMContentPart text: aString }
]

{ #category : 'instance creation' }
SloptalkLLMOutputItem class >> reasoningText: aString [
	^ self new
		type: 'reasoning';
		text: aString;
		yourself
]

{ #category : 'instance creation' }
SloptalkLLMOutputItem class >> toolCallId: aString name: aToolName arguments: anObject [
	^ self new
		type: 'toolCall';
		callId: aString;
		toolName: aToolName;
		arguments: anObject;
		yourself
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> arguments [
	^ arguments ifNil: [ Dictionary new ]
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> arguments: anObject [
	arguments := anObject
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> callId [
	^ callId
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> callId: aString [
	callId := aString
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> contentParts [
	^ contentParts ifNil: [ #() ]
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> contentParts: aCollection [
	contentParts := aCollection ifNil: [ #() ] ifNotNil: [ aCollection asArray ]
]

{ #category : 'testing' }
SloptalkLLMOutputItem >> isMessage [
	^ type = 'message'
]

{ #category : 'testing' }
SloptalkLLMOutputItem >> isReasoning [
	^ type = 'reasoning'
]

{ #category : 'testing' }
SloptalkLLMOutputItem >> isToolCall [
	^ type = 'toolCall'
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> role [
	^ role
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> role: aString [
	role := aString
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> text [
	self isReasoning ifTrue: [ ^ text ifNil: [ '' ] ].
	self isMessage ifFalse: [ ^ '' ].
	^ String streamContents: [ :stream |
		self contentParts
			do: [ :each | stream nextPutAll: each displayText ] ]
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> text: aString [
	text := aString ifNil: [ '' ]
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> toolName [
	^ toolName
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> toolName: aString [
	toolName := aString
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> type [
	^ type
]

{ #category : 'accessing' }
SloptalkLLMOutputItem >> type: aString [
	type := aString ifNil: [ 'message' ]
]
