"I list classes available in the image."
Class {
	#name : 'SloptalkListClassesTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkListClassesTool >> description [
	^ 'List classes in a package or across the whole image.'
]

{ #category : 'api' }
SloptalkListClassesTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| packageName query classes limited title |
	packageName := self valueAt: #package in: aDictionary ifAbsent: [ nil ].
	query := (self valueAt: #query in: aDictionary ifAbsent: [ '' ]) asString.
	classes := packageName
		ifNil: [
			Smalltalk globals values
				select: [ :each | each isBehavior and: [ each isMeta not ] ] ]
		ifNotNil: [ (aSloptalkAgent packageNamed: packageName) definedClasses ].

	query ifNotEmpty: [
		classes := classes
			select: [ :each | each name includesSubstring: query caseSensitive: false ] ].

	classes := classes asSortedCollection: [ :left :right | left name <= right name ].
	limited := classes first: (classes size min: 200).
	title := packageName
		ifNil: [ 'Classes' ]
		ifNotNil: [ 'Classes in ' , packageName asString ].

	^ String streamContents: [ :stream |
		stream nextPutAll: title; nextPut: Character lf.
		limited
			ifEmpty: [ stream nextPutAll: 'No classes found.' ]
			ifNotEmpty: [
				limited do: [ :each |
					stream nextPutAll: each name; nextPut: Character lf ].
				classes size > limited size ifTrue: [
					stream nextPutAll: '... truncated ...' ] ] ]
]

{ #category : 'accessing' }
SloptalkListClassesTool >> name [
	^ 'list_classes'
]

{ #category : 'documentation' }
SloptalkListClassesTool >> promptSpec [
	^ '- list_classes: list classes in the image. Arguments: {"package":"optional package name","query":"optional class name substring"}'
]
