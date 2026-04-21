"I represent a single chat message in a Sloptalk conversation."
Class {
	#name : 'SloptalkMessage',
	#superclass : 'Object',
	#instVars : [
		'role',
		'text'
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
	^ self new
		role: aRole;
		text: aText;
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
	^ role , ': ' , text
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
