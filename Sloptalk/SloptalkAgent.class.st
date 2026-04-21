"I coordinate a conversation and a Codex bridge."
Class {
	#name : 'SloptalkAgent',
	#superclass : 'Object',
	#instVars : [
		'conversation',
		'bridge'
	],
	#category : 'Sloptalk-Core',
	#package : 'Sloptalk',
	#tag : 'Core'
}

{ #category : 'accessing' }
SloptalkAgent >> bridge [
	^ bridge
]

{ #category : 'accessing' }
SloptalkAgent >> bridge: aSloptalkCodexBridge [
	bridge := aSloptalkCodexBridge
]

{ #category : 'accessing' }
SloptalkAgent >> conversation [
	^ conversation
]

{ #category : 'initialization' }
SloptalkAgent >> initialize [
	super initialize.
	conversation := SloptalkConversation new.
	bridge := SloptalkCodexBridge new
]

{ #category : 'api' }
SloptalkAgent >> receiveUserMessage: aString [
	| reply |
	conversation addUserMessage: aString.
	reply := bridge replyTo: aString in: conversation.
	conversation addAssistantMessage: reply.
	^ reply
]

{ #category : 'printing' }
SloptalkAgent >> transcriptString [
	^ conversation transcriptString
]

{ #category : 'accessing' }
SloptalkAgent >> workspacePath [
	^ bridge workspacePath
]

{ #category : 'accessing' }
SloptalkAgent >> workspacePath: aString [
	bridge workspacePath: aString
]
