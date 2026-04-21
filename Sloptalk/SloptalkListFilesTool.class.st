"I list files relative to the agent workspace."
Class {
	#name : 'SloptalkListFilesTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkListFilesTool >> description [
	^ 'List files and directories under a workspace path.'
]

{ #category : 'api' }
SloptalkListFilesTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| path recursive target entries limited |
	path := self valueAt: #path in: aDictionary ifAbsent: [ '.' ].
	recursive := self valueAt: #recursive in: aDictionary ifAbsent: [ false ].
	target := aSloptalkAgent resolveWorkspacePath: path.
	target exists ifFalse: [
		self error: 'Path does not exist: ' , path ].
	target isDirectory ifFalse: [
		self error: 'Path is not a directory: ' , path ].

	entries := recursive
		ifTrue: [ target allChildren ]
		ifFalse: [ target children ].

	limited := (entries
		collect: [ :each |
			| relative |
			relative := aSloptalkAgent relativePathFor: each.
			each isDirectory
				ifTrue: [ relative , '/' ]
				ifFalse: [ relative ] ])
		asSortedCollection.

	^ String streamContents: [ :stream |
		| limit |
		limit := limited size min: 200.
		stream
			nextPutAll: 'Listing for ';
			nextPutAll: (aSloptalkAgent relativePathFor: target);
			nextPut: Character lf.
		1 to: limit do: [ :index |
			stream nextPutAll: (limited at: index); nextPut: Character lf ].
		limited size > 200 ifTrue: [
			stream nextPutAll: '... truncated ...' ] ]
]

{ #category : 'accessing' }
SloptalkListFilesTool >> name [
	^ 'list_files'
]

{ #category : 'documentation' }
SloptalkListFilesTool >> promptSpec [
	^ '- list_files: list files under a directory. Arguments: {"path":"relative/or/absolute/path","recursive":false}'
]
