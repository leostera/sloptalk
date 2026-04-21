"I carry one normalized response from an LLM provider back into Sloptalk."
Class {
	#name : 'SloptalkLLMResponse',
	#superclass : 'Object',
	#instVars : [
		'providerName',
		'model',
		'outputItems',
		'usage',
		'finishReason',
		'payload',
		'metadata'
	],
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'instance creation' }
SloptalkLLMResponse class >> providerName: aProviderName model: aModelString outputItems: aCollection usage: aSloptalkLLMUsage finishReason: aFinishReason payload: anObject metadata: aDictionary [
	^ self new
		providerName: aProviderName;
		model: aModelString;
		outputItems: aCollection;
		usage: aSloptalkLLMUsage;
		finishReason: aFinishReason;
		payload: anObject;
		metadata: aDictionary;
		yourself
]

{ #category : 'instance creation' }
SloptalkLLMResponse class >> text: aString [
	^ self text: aString payload: nil metadata: Dictionary new
]

{ #category : 'instance creation' }
SloptalkLLMResponse class >> text: aString payload: anObject metadata: aDictionary [
	^ self
		providerName: nil
		model: nil
		outputItems: { SloptalkLLMOutputItem assistantText: aString }
		usage: SloptalkLLMUsage zero
		finishReason: 'stop'
		payload: anObject
		metadata: aDictionary
]

{ #category : 'accessing' }
SloptalkLLMResponse >> finishReason [
	^ finishReason
]

{ #category : 'accessing' }
SloptalkLLMResponse >> finishReason: aString [
	finishReason := aString ifNil: [ 'unknown' ]
]

{ #category : 'accessing' }
SloptalkLLMResponse >> firstToolCall [
	^ self toolCallOutputItems
		ifEmpty: [ nil ]
		ifNotEmpty: [ :items | items first ]
]

{ #category : 'testing' }
SloptalkLLMResponse >> hasToolCalls [
	^ self toolCallOutputItems isNotEmpty
]

{ #category : 'initialization' }
SloptalkLLMResponse >> initialize [
	super initialize.
	providerName := nil.
	model := nil.
	outputItems := #().
	usage := SloptalkLLMUsage zero.
	finishReason := 'unknown'.
	payload := nil.
	metadata := Dictionary new
]

{ #category : 'accessing' }
SloptalkLLMResponse >> messageOutputItems [
	^ outputItems select: [ :each | each isMessage ]
]

{ #category : 'accessing' }
SloptalkLLMResponse >> metadata [
	^ metadata
]

{ #category : 'accessing' }
SloptalkLLMResponse >> metadata: aDictionary [
	metadata := aDictionary ifNil: [ Dictionary new ]
]

{ #category : 'accessing' }
SloptalkLLMResponse >> metadataAt: aKey ifAbsent: aBlock [
	^ metadata
		at: aKey
		ifAbsent: [
			metadata
				at: aKey asString
				ifAbsent: aBlock ]
]

{ #category : 'accessing' }
SloptalkLLMResponse >> model [
	^ model
]

{ #category : 'accessing' }
SloptalkLLMResponse >> model: aString [
	model := aString
]

{ #category : 'accessing' }
SloptalkLLMResponse >> outputItems [
	^ outputItems
]

{ #category : 'accessing' }
SloptalkLLMResponse >> outputItems: aCollection [
	outputItems := aCollection ifNil: [ #() ] ifNotNil: [ aCollection asArray ]
]

{ #category : 'accessing' }
SloptalkLLMResponse >> payload [
	^ payload
]

{ #category : 'accessing' }
SloptalkLLMResponse >> payload: anObject [
	payload := anObject
]

{ #category : 'accessing' }
SloptalkLLMResponse >> providerName [
	^ providerName
]

{ #category : 'accessing' }
SloptalkLLMResponse >> providerName: aString [
	providerName := aString
]

{ #category : 'accessing' }
SloptalkLLMResponse >> reasoningOutputItems [
	^ outputItems select: [ :each | each isReasoning ]
]

{ #category : 'accessing' }
SloptalkLLMResponse >> text [
	| messageItems |
	messageItems := self messageOutputItems.
	^ String streamContents: [ :stream |
		messageItems
			doWithIndex: [ :each :index |
				index > 1 ifTrue: [
					stream
						nextPut: Character lf;
						nextPut: Character lf ].
				stream nextPutAll: each text ] ]
]

{ #category : 'accessing' }
SloptalkLLMResponse >> toolCallOutputItems [
	^ outputItems select: [ :each | each isToolCall ]
]

{ #category : 'accessing' }
SloptalkLLMResponse >> usage [
	^ usage
]

{ #category : 'accessing' }
SloptalkLLMResponse >> usage: aSloptalkLLMUsage [
	usage := aSloptalkLLMUsage ifNil: [ SloptalkLLMUsage zero ]
]
