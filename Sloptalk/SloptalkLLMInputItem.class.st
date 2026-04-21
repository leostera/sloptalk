"I represent one normalized provider input item, similar to `agents` raw input items."
Class {
	#name : 'SloptalkLLMInputItem',
	#superclass : 'Object',
	#instVars : [
		'type',
		'role',
		'contentParts',
		'callId',
		'toolName',
		'arguments',
		'resultText',
		'rawText',
		'isError'
	],
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'instance creation' }
SloptalkLLMInputItem class >> assistantText: aString [
	^ self messageRole: 'assistant' text: aString
]

{ #category : 'instance creation' }
SloptalkLLMInputItem class >> messageRole: aString contentParts: aCollection [
	^ self new
		type: 'message';
		role: aString;
		contentParts: aCollection;
		yourself
]

{ #category : 'instance creation' }
SloptalkLLMInputItem class >> messageRole: aString text: aString [
	^ self
		messageRole: aString
		contentParts: { SloptalkLLMContentPart text: aString }
]

{ #category : 'instance creation' }
SloptalkLLMInputItem class >> systemText: aString [
	^ self messageRole: 'system' text: aString
]

{ #category : 'instance creation' }
SloptalkLLMInputItem class >> toolCallId: aString name: aToolName arguments: anObject [
	^ self
		toolCallId: aString
		name: aToolName
		arguments: anObject
		text: nil
]

{ #category : 'instance creation' }
SloptalkLLMInputItem class >> toolCallId: aString name: aToolName arguments: anObject text: aTextString [
	^ self new
		type: 'toolCall';
		callId: aString;
		toolName: aToolName;
		arguments: anObject;
		rawText: aTextString;
		yourself
]

{ #category : 'instance creation' }
SloptalkLLMInputItem class >> toolResultCallId: aString text: aString [
	^ self
		toolResultCallId: aString
		name: nil
		text: aString
		isError: false
]

{ #category : 'instance creation' }
SloptalkLLMInputItem class >> toolResultCallId: aString name: aToolName text: aString isError: aBoolean [
	^ self new
		type: 'toolResult';
		callId: aString;
		toolName: aToolName;
		resultText: aString;
		isError: aBoolean;
		yourself
]

{ #category : 'instance creation' }
SloptalkLLMInputItem class >> userText: aString [
	^ self messageRole: 'user' text: aString
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> arguments [
	^ arguments ifNil: [ Dictionary new ]
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> arguments: anObject [
	arguments := anObject
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> callId [
	^ callId
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> callId: aString [
	callId := aString
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> contentParts [
	^ contentParts ifNil: [ #() ]
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> contentParts: aCollection [
	contentParts := aCollection ifNil: [ #() ] ifNotNil: [ aCollection asArray ]
]

{ #category : 'testing' }
SloptalkLLMInputItem >> isMessage [
	^ type = 'message'
]

{ #category : 'testing' }
SloptalkLLMInputItem >> isError [
	^ isError ifNil: [ false ]
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> isError: aBoolean [
	isError := aBoolean ifNil: [ false ]
]

{ #category : 'testing' }
SloptalkLLMInputItem >> isSystemMessage [
	^ self isMessage and: [ role = 'system' ]
]

{ #category : 'testing' }
SloptalkLLMInputItem >> isToolCall [
	^ type = 'toolCall'
]

{ #category : 'testing' }
SloptalkLLMInputItem >> isToolResult [
	^ type = 'toolResult'
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> resultText [
	^ resultText ifNil: [ '' ]
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> resultText: aString [
	resultText := aString ifNil: [ '' ]
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> rawText [
	^ rawText
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> rawText: aString [
	rawText := aString
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> role [
	^ role
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> role: aString [
	role := aString
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> text [
	self isToolResult ifTrue: [ ^ self resultText ].
	self isToolCall ifTrue: [ ^ rawText ifNil: [ '' ] ].
	self isMessage ifFalse: [ ^ '' ].
	^ String streamContents: [ :stream |
		self contentParts
			do: [ :each | stream nextPutAll: each displayText ] ]
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> toolName [
	^ toolName
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> toolName: aString [
	toolName := aString
]

{ #category : 'printing' }
SloptalkLLMInputItem >> toolResultPromptText [
	| status |
	status := self isError
		ifTrue: [ 'error' ]
		ifFalse: [ 'ok' ].

	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'Tool result';
			nextPut: Character lf;
			nextPutAll: 'name: ';
			nextPutAll: (toolName ifNil: [ 'unknown' ]);
			nextPut: Character lf;
			nextPutAll: 'status: ';
			nextPutAll: status;
			nextPut: Character lf;
			nextPutAll: 'content:';
			nextPut: Character lf;
			nextPutAll: self resultText ]
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> type [
	^ type
]

{ #category : 'accessing' }
SloptalkLLMInputItem >> type: aString [
	type := aString ifNil: [ 'message' ]
]
