"I will eventually talk to the local Codex CLI.
Right now I provide a stable seam for a future subprocess or socket bridge."
Class {
	#name : 'SloptalkCodexBridge',
	#superclass : 'Object',
	#instVars : [
		'workspacePath'
	],
	#category : 'Sloptalk-Bridge',
	#package : 'Sloptalk',
	#tag : 'Bridge'
}

{ #category : 'initialization' }
SloptalkCodexBridge >> initialize [
	super initialize.
	workspacePath := '.'
]

{ #category : 'api' }
SloptalkCodexBridge >> replyTo: aString in: aConversation [
	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'Codex bridge not wired yet.';
			nextPut: Character lf;
			nextPutAll: 'Workspace: ';
			nextPutAll: workspacePath;
			nextPut: Character lf;
			nextPutAll: 'Prompt: ';
			nextPutAll: aString;
			nextPut: Character lf;
			nextPutAll: 'Conversation size: ';
			nextPutAll: aConversation size asString ]
]

{ #category : 'accessing' }
SloptalkCodexBridge >> workspacePath [
	^ workspacePath
]

{ #category : 'accessing' }
SloptalkCodexBridge >> workspacePath: aString [
	workspacePath := aString
]
