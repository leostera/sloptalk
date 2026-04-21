"I represent one queued or running agent turn."
Class {
	#name : 'SloptalkTurn',
	#superclass : 'Object',
	#instVars : [
		'prompt',
		'reply',
		'errorText',
		'status',
		'doneSemaphore',
		'createdAt',
		'completedAt'
	],
	#category : 'Sloptalk-Model',
	#package : 'Sloptalk',
	#tag : 'Model'
}

{ #category : 'instance creation' }
SloptalkTurn class >> prompt: aString [
	^ self new
		prompt: aString;
		yourself
]

{ #category : 'accessing' }
SloptalkTurn >> completedAt [
	^ completedAt
]

{ #category : 'accessing' }
SloptalkTurn >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
SloptalkTurn >> errorText [
	^ errorText
]

{ #category : 'initialization' }
SloptalkTurn >> initialize [
	super initialize.
	status := 'queued'.
	doneSemaphore := Semaphore new.
	createdAt := DateAndTime now
]

{ #category : 'testing' }
SloptalkTurn >> isFailed [
	^ status = 'failed'
]

{ #category : 'testing' }
SloptalkTurn >> isFinished [
	^ (status = 'completed') or: [ status = 'failed' ]
]

{ #category : 'lifecycle' }
SloptalkTurn >> markCompletedWith: aString [
	reply := aString.
	status := 'completed'.
	completedAt := DateAndTime now.
	doneSemaphore signal
]

{ #category : 'lifecycle' }
SloptalkTurn >> markFailedWith: aString [
	errorText := aString.
	status := 'failed'.
	completedAt := DateAndTime now.
	doneSemaphore signal
]

{ #category : 'lifecycle' }
SloptalkTurn >> markRunning [
	status := 'running'
]

{ #category : 'accessing' }
SloptalkTurn >> prompt [
	^ prompt
]

{ #category : 'accessing' }
SloptalkTurn >> prompt: aString [
	prompt := aString
]

{ #category : 'accessing' }
SloptalkTurn >> reply [
	^ reply
]

{ #category : 'accessing' }
SloptalkTurn >> status [
	^ status
]

{ #category : 'waiting' }
SloptalkTurn >> wait [
	self isFinished ifFalse: [ doneSemaphore wait ].
	^ self
]

{ #category : 'waiting' }
SloptalkTurn >> waitForReply [
	self wait.
	self isFailed ifTrue: [ Error signal: errorText ].
	^ reply
]
