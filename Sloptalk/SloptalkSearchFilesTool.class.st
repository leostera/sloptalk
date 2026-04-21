"I search text across workspace files."
Class {
	#name : 'SloptalkSearchFilesTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkSearchFilesTool >> description [
	^ 'Search for a text query across files in the workspace.'
]

{ #category : 'api' }
SloptalkSearchFilesTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| path query target matches |
	path := self valueAt: #path in: aDictionary ifAbsent: [ '.' ].
	query := self valueAt: #query in: aDictionary ifAbsent: [
		self error: 'Missing required argument: query' ].
	target := aSloptalkAgent resolveWorkspacePath: path.
	target exists ifFalse: [
		self error: 'Path does not exist: ' , path ].

	matches := OrderedCollection new.
	(target isFile
		ifTrue: [ { target } ]
		ifFalse: [ target allChildren select: [ :each | each isFile ] ])
		do: [ :file |
			self
				searchFile: file
				for: query
				withAgent: aSloptalkAgent
				into: matches ].

	^ String streamContents: [ :stream |
		| limit |
		limit := matches size min: 200.
		stream
			nextPutAll: 'Search query: ';
			nextPutAll: query;
			nextPut: Character lf.
		matches isEmpty
			ifTrue: [ stream nextPutAll: 'No matches found.' ]
			ifFalse: [
				1 to: limit do: [ :index |
					stream nextPutAll: (matches at: index); nextPut: Character lf ].
				matches size > 200 ifTrue: [
					stream nextPutAll: '... truncated ...' ] ] ]
]

{ #category : 'accessing' }
SloptalkSearchFilesTool >> name [
	^ 'search_files'
]

{ #category : 'documentation' }
SloptalkSearchFilesTool >> promptSpec [
	^ '- search_files: search for text in files. Arguments: {"query":"text to search","path":"directory or file path"}'
]

{ #category : 'private' }
SloptalkSearchFilesTool >> searchFile: aFileReference for: aString withAgent: aSloptalkAgent into: aCollection [
	| contents lines |
	contents := [ aFileReference contents ]
		on: Error
		do: [ :error | ^ self ].
	lines := contents lines.
	lines doWithIndex: [ :line :index |
		(line includesSubstring: aString)
			ifTrue: [
				aCollection add:
					((aSloptalkAgent relativePathFor: aFileReference)
						, ':'
						, index asString
						, ': '
						, line).
				aCollection size >= 250 ifTrue: [ ^ self ] ] ]
]
