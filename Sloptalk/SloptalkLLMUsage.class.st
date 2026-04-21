"I keep normalized token usage for one provider response."
Class {
	#name : 'SloptalkLLMUsage',
	#superclass : 'Object',
	#instVars : [
		'promptTokens',
		'completionTokens',
		'totalTokens'
	],
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'instance creation' }
SloptalkLLMUsage class >> promptTokens: aPromptInteger completionTokens: aCompletionInteger totalTokens: aTotalInteger [
	^ self new
		promptTokens: aPromptInteger;
		completionTokens: aCompletionInteger;
		totalTokens: aTotalInteger;
		yourself
]

{ #category : 'instance creation' }
SloptalkLLMUsage class >> zero [
	^ self
		promptTokens: 0
		completionTokens: 0
		totalTokens: 0
]

{ #category : 'accessing' }
SloptalkLLMUsage >> completionTokens [
	^ completionTokens ifNil: [ 0 ]
]

{ #category : 'accessing' }
SloptalkLLMUsage >> completionTokens: anInteger [
	completionTokens := anInteger ifNil: [ 0 ]
]

{ #category : 'accessing' }
SloptalkLLMUsage >> promptTokens [
	^ promptTokens ifNil: [ 0 ]
]

{ #category : 'accessing' }
SloptalkLLMUsage >> promptTokens: anInteger [
	promptTokens := anInteger ifNil: [ 0 ]
]

{ #category : 'accessing' }
SloptalkLLMUsage >> totalTokens [
	^ totalTokens ifNil: [ self promptTokens + self completionTokens ]
]

{ #category : 'accessing' }
SloptalkLLMUsage >> totalTokens: anInteger [
	totalTokens := anInteger ifNil: [ self promptTokens + self completionTokens ]
]
