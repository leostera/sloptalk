"I list methods defined directly on a class or metaclass."
Class {
	#name : 'SloptalkListMethodsTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkListMethodsTool >> description [
	^ 'List local methods on a class or class side.'
]

{ #category : 'api' }
SloptalkListMethodsTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| className classSide behavior protocolName query selectors limited |
	className := self valueAt: #class in: aDictionary ifAbsent: [
		self error: 'Missing required argument: class' ].
	classSide := self booleanAt: #class_side in: aDictionary ifAbsent: [ false ].
	protocolName := (self valueAt: #protocol in: aDictionary ifAbsent: [ '' ]) asString.
	query := (self valueAt: #query in: aDictionary ifAbsent: [ '' ]) asString.
	behavior := aSloptalkAgent behaviorNamed: className classSide: classSide.
	selectors := behavior localSelectors.

	protocolName ifNotEmpty: [
		selectors := selectors
			select: [ :each |
				(behavior protocolNameOfSelector: each) asString sameAs: protocolName ] ].
	query ifNotEmpty: [
		selectors := selectors
			select: [ :each |
				each asString includesSubstring: query caseSensitive: false ] ].

	selectors := selectors asSortedCollection.
	limited := selectors first: (selectors size min: 200).

	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'Methods on ';
			nextPutAll: (classSide
				ifTrue: [ className asString , ' class' ]
				ifFalse: [ className asString ]);
			nextPut: Character lf.
		limited
			ifEmpty: [ stream nextPutAll: 'No methods found.' ]
			ifNotEmpty: [
				limited do: [ :each |
					stream
						nextPutAll: each asString;
						nextPutAll: ' [';
						nextPutAll: (behavior protocolNameOfSelector: each) asString;
						nextPutAll: ']';
						nextPut: Character lf ].
				selectors size > limited size ifTrue: [
					stream nextPutAll: '... truncated ...' ] ] ]
]

{ #category : 'accessing' }
SloptalkListMethodsTool >> name [
	^ 'list_methods'
]

{ #category : 'documentation' }
SloptalkListMethodsTool >> promptSpec [
	^ '- list_methods: list local methods on a class. Arguments: {"class":"ClassName","class_side":false,"protocol":"optional protocol","query":"optional selector substring"}'
]
