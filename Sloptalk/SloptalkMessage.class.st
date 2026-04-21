"I represent a single chat message in a Sloptalk conversation."
Class {
	#name : 'SloptalkMessage',
	#superclass : 'Object',
	#instVars : [
		'role',
		'text',
		'details'
	],
	#category : 'Sloptalk-Model',
	#package : 'Sloptalk',
	#tag : 'Model'
}

{ #category : 'instance creation' }
SloptalkMessage class >> assistant: aString [
	^ self role: 'assistant' text: aString
]

{ #category : 'instance creation' }
SloptalkMessage class >> role: aRole text: aText [
	^ self role: aRole text: aText details: nil
]

{ #category : 'instance creation' }
SloptalkMessage class >> role: aRole text: aText details: aDictionary [
	^ self new
		role: aRole;
		text: aText;
		details: aDictionary;
		yourself
]

{ #category : 'instance creation' }
SloptalkMessage class >> system: aString [
	^ self role: 'system' text: aString
]

{ #category : 'instance creation' }
SloptalkMessage class >> user: aString [
	^ self role: 'user' text: aString
]

{ #category : 'printing' }
SloptalkMessage >> asTranscriptLine [
	^ role , ': ' , self displayText
]

{ #category : 'converting' }
SloptalkMessage >> asLLMInputItem [
	self isToolCallMessage ifTrue: [
		^ SloptalkLLMInputItem
			toolCallId: self toolCallId
			name: self toolName
			arguments: self toolArguments
			text: text ].

	self isToolResult ifTrue: [
		^ SloptalkLLMInputItem
			toolResultCallId: self toolCallId
			name: self toolName
			text: text
			isError: (self valueAt: #isError ifAbsent: [ false ]) ].

	^ SloptalkLLMInputItem
		messageRole: role
		text: text
]

{ #category : 'accessing' }
SloptalkMessage >> details [
	^ details
]

{ #category : 'accessing' }
SloptalkMessage >> details: aDictionary [
	details := aDictionary
]

{ #category : 'printing' }
SloptalkMessage >> displayText [
	self isToolCallMessage ifTrue: [
		^ 'tool(' , (self toolName ifNil: [ 'unknown' ]) , '): ' , self toolArguments printString ].

	self isToolResult ifTrue: [
		^ 'tool(' , (self toolName ifNil: [ 'unknown' ]) , '): ' , text ].

	^ text
]

{ #category : 'accessing' }
SloptalkMessage >> role [
	^ role
]

{ #category : 'accessing' }
SloptalkMessage >> role: aString [
	role := aString
]

{ #category : 'testing' }
SloptalkMessage >> isToolCallMessage [
	^ role = 'assistant' and: [ (self valueAt: #type ifAbsent: [ nil ]) = 'tool_call' ]
]

{ #category : 'testing' }
SloptalkMessage >> isToolResult [
	^ role = 'toolResult'
]

{ #category : 'accessing' }
SloptalkMessage >> responseId [
	^ self valueAt: #response_id ifAbsent: [ nil ]
]

{ #category : 'accessing' }
SloptalkMessage >> text [
	^ text
]

{ #category : 'accessing' }
SloptalkMessage >> text: aString [
	text := aString
]

{ #category : 'accessing' }
SloptalkMessage >> toolArguments [
	^ self valueAt: #arguments ifAbsent: [ Dictionary new ]
]

{ #category : 'accessing' }
SloptalkMessage >> toolCallId [
	^ self valueAt: #call_id ifAbsent: [ nil ]
]

{ #category : 'accessing' }
SloptalkMessage >> toolName [
	^ self valueAt: #tool ifAbsent: [ nil ]
]

{ #category : 'private' }
SloptalkMessage >> toolResultPromptText [
	| toolName status |
	toolName := self toolName ifNil: [ 'unknown' ].
	status := (self valueAt: #isError ifAbsent: [ false ])
		ifTrue: [ 'error' ]
		ifFalse: [ 'ok' ].

	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'Tool result';
			nextPut: Character lf;
			nextPutAll: 'name: ';
			nextPutAll: toolName;
			nextPut: Character lf;
			nextPutAll: 'status: ';
			nextPutAll: status;
			nextPut: Character lf;
			nextPutAll: 'content:';
			nextPut: Character lf;
			nextPutAll: text ]
]

{ #category : 'private' }
SloptalkMessage >> valueAt: aKey ifAbsent: aBlock [
	details ifNil: [ ^ aBlock value ].
	^ details
		at: aKey
		ifAbsent: [
			details
				at: aKey asString
				ifAbsent: aBlock ]
]
