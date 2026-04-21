"I list packages loaded in the image."
Class {
	#name : 'SloptalkListPackagesTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkListPackagesTool >> description [
	^ 'List package names available in the current image.'
]

{ #category : 'api' }
SloptalkListPackagesTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| query names limited |
	query := (self valueAt: #query in: aDictionary ifAbsent: [ '' ]) asString.
	names := (PackageOrganizer default packageNames
		collect: [ :each | each asString ])
		asSortedCollection.
	query ifNotEmpty: [
		names := names select: [ :each | each includesSubstring: query caseSensitive: false ] ].
	limited := names first: (names size min: 200).

	^ String streamContents: [ :stream |
		stream nextPutAll: 'Packages'; nextPut: Character lf.
		limited
			ifEmpty: [ stream nextPutAll: 'No packages found.' ]
			ifNotEmpty: [
				limited do: [ :each |
					stream nextPutAll: each; nextPut: Character lf ].
				names size > limited size ifTrue: [
					stream nextPutAll: '... truncated ...' ] ] ]
]

{ #category : 'accessing' }
SloptalkListPackagesTool >> name [
	^ 'list_packages'
]

{ #category : 'documentation' }
SloptalkListPackagesTool >> promptSpec [
	^ '- list_packages: list package names in the image. Arguments: {"query":"optional substring"}'
]
