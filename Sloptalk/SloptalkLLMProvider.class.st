"I am the abstract base for Sloptalk language model providers."
Class {
	#name : 'SloptalkLLMProvider',
	#superclass : 'Object',
	#instVars : [
		'model',
		'requestTimeoutSeconds'
	],
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'api' }
SloptalkLLMProvider >> completeConversation: aConversation systemPrompt: aString [
	self subclassResponsibility
]

{ #category : 'defaults' }
SloptalkLLMProvider >> defaultModel [
	self subclassResponsibility
]

{ #category : 'defaults' }
SloptalkLLMProvider >> defaultRequestTimeoutSeconds [
	^ 600
]

{ #category : 'accessing' }
SloptalkLLMProvider >> displayString [
	^ self providerName , ' (' , model , ')'
]

{ #category : 'initialization' }
SloptalkLLMProvider >> initialize [
	super initialize.
	model := self defaultModel.
	requestTimeoutSeconds := self defaultRequestTimeoutSeconds
]

{ #category : 'accessing' }
SloptalkLLMProvider >> model [
	^ model
]

{ #category : 'accessing' }
SloptalkLLMProvider >> model: aString [
	model := aString
]

{ #category : 'accessing' }
SloptalkLLMProvider >> providerName [
	^ self class name
]

{ #category : 'accessing' }
SloptalkLLMProvider >> requestTimeoutSeconds [
	^ requestTimeoutSeconds
]

{ #category : 'accessing' }
SloptalkLLMProvider >> requestTimeoutSeconds: anInteger [
	requestTimeoutSeconds := anInteger
]
