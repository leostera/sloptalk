"I keep an ordered collection of Sloptalk messages."
Class {
	#name : 'SloptalkConversation',
	#superclass : 'Object',
	#instVars : [
		'messages'
	],
	#category : 'Sloptalk-Model',
	#package : 'Sloptalk',
	#tag : 'Model'
}

{ #category : 'adding' }
SloptalkConversation >> addAssistantMessage: aString [
	^ self addAssistantMessage: aString details: nil
]

{ #category : 'adding' }
SloptalkConversation >> addAssistantMessage: aString details: aDictionary [
	^ self
		addMessage: (
			SloptalkMessage
				role: 'assistant'
				text: aString
				details: aDictionary)
]

{ #category : 'adding' }
SloptalkConversation >> addMessage: aSloptalkMessage [
	messages add: aSloptalkMessage.
	^ aSloptalkMessage
]

{ #category : 'adding' }
SloptalkConversation >> addSystemMessage: aString [
	^ self addMessage: (SloptalkMessage system: aString)
]

{ #category : 'adding' }
SloptalkConversation >> addToolResultNamed: aString text: aText isError: aBoolean [
	^ self
		addToolResultNamed: aString
		callId: nil
		text: aText
		isError: aBoolean
]

{ #category : 'adding' }
SloptalkConversation >> addToolResultNamed: aString callId: aCallId text: aText isError: aBoolean [
	^ self
		addMessage: (
			SloptalkMessage
				role: 'toolResult'
				text: aText
				details: {
					#call_id -> aCallId.
					#tool -> aString.
					#isError -> aBoolean
				} asDictionary)
]

{ #category : 'adding' }
SloptalkConversation >> addUserMessage: aString [
	^ self addMessage: (SloptalkMessage user: aString)
]

{ #category : 'initialization' }
SloptalkConversation >> initialize [
	super initialize.
	messages := OrderedCollection new
]

{ #category : 'accessing' }
SloptalkConversation >> lastMessage [
	^ messages ifEmpty: [ nil ] ifNotEmpty: [ messages last ]
]

{ #category : 'accessing' }
SloptalkConversation >> messages [
	^ messages asArray
]

{ #category : 'accessing' }
SloptalkConversation >> size [
	^ messages size
]

{ #category : 'printing' }
SloptalkConversation >> transcriptString [
	^ String streamContents: [ :stream |
		messages doWithIndex: [ :message :index |
			stream nextPutAll: message asTranscriptLine.
			index < messages size ifTrue: [
				stream nextPut: Character lf ] ] ]
]
