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
	^ self
		completeRequest: (self requestForConversation: aConversation systemPrompt: aString)
]

{ #category : 'api' }
SloptalkLLMProvider >> completeRequest: aSloptalkLLMRequest [
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

{ #category : 'private' }
SloptalkLLMProvider >> requestForConversation: aConversation systemPrompt: aString [
	^ SloptalkLLMRequest
		systemPrompt: aString
		messages: aConversation messages
]

{ #category : 'accessing' }
SloptalkLLMProvider >> requestTimeoutSeconds [
	^ requestTimeoutSeconds
]

{ #category : 'accessing' }
SloptalkLLMProvider >> requestTimeoutSeconds: anInteger [
	requestTimeoutSeconds := anInteger
]
