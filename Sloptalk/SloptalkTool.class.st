"I am the abstract base class for Sloptalk tools."
Class {
	#name : 'SloptalkTool',
	#superclass : 'Object',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkTool >> description [
	self subclassResponsibility
]

{ #category : 'api' }
SloptalkTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	self subclassResponsibility
]

{ #category : 'private' }
SloptalkTool >> booleanAt: aKey in: aDictionary ifAbsent: aBlock [
	| value |
	value := self valueAt: aKey in: aDictionary ifAbsent: [ ^ aBlock value ].
	((value == true) or: [ value == false ]) ifTrue: [ ^ value ].
	value isString ifTrue: [
		(value sameAs: 'true') ifTrue: [ ^ true ].
		(value sameAs: 'false') ifTrue: [ ^ false ] ].
	self error: 'Expected a boolean for ' , aKey asString
]

{ #category : 'accessing' }
SloptalkTool >> name [
	self subclassResponsibility
]

{ #category : 'documentation' }
SloptalkTool >> promptSpec [
	self subclassResponsibility
]

{ #category : 'private' }
SloptalkTool >> valueAt: aKey in: aDictionary ifAbsent: aBlock [
	^ aDictionary
		at: aKey
		ifAbsent: [
			aDictionary
				at: aKey asString
				ifAbsent: aBlock ]
]
