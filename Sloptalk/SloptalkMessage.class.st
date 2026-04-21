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
SloptalkMessage >> asChatCompletionMessage [
	role = 'toolResult' ifTrue: [
		^ {
			#role -> 'user'.
			#content -> self toolResultPromptText
		} asDictionary ].

	^ {
		#role -> role.
		#content -> text
	} asDictionary
]

{ #category : 'converting' }
SloptalkMessage >> asResponsesInputMessage [
	role = 'toolResult' ifTrue: [
		^ {
			#type -> 'message'.
			#role -> 'user'.
			#content -> {
				{
					#type -> 'input_text'.
					#text -> self toolResultPromptText
				} asDictionary
			}
		} asDictionary ].

	^ {
		#type -> 'message'.
		#role -> role.
		#content -> {
			{
				#type -> (role = 'assistant'
					ifTrue: [ 'output_text' ]
					ifFalse: [ 'input_text' ]).
				#text -> text
			} asDictionary
		}
	} asDictionary
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
	| type toolName arguments |
	role = 'assistant' ifTrue: [
		type := self valueAt: #type ifAbsent: [ nil ].
		type = 'tool_call' ifTrue: [
			toolName := self valueAt: #tool ifAbsent: [ 'unknown' ].
			arguments := self valueAt: #arguments ifAbsent: [ Dictionary new ].
			^ 'tool(' , toolName , '): ' , arguments printString ] ].

	role = 'toolResult' ifTrue: [
		toolName := self valueAt: #tool ifAbsent: [ 'unknown' ].
		^ 'tool(' , toolName , '): ' , text ].

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

{ #category : 'accessing' }
SloptalkMessage >> text [
	^ text
]

{ #category : 'accessing' }
SloptalkMessage >> text: aString [
	text := aString
]

{ #category : 'private' }
SloptalkMessage >> toolResultPromptText [
	| toolName status |
	toolName := self valueAt: #tool ifAbsent: [ 'unknown' ].
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
