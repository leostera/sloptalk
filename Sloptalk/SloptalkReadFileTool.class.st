"I read text files from the workspace."
Class {
	#name : 'SloptalkReadFileTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkReadFileTool >> description [
	^ 'Read a text file from the workspace.'
]

{ #category : 'api' }
SloptalkReadFileTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| path target contents |
	path := self valueAt: #path in: aDictionary ifAbsent: [
		self error: 'Missing required argument: path' ].
	target := aSloptalkAgent resolveWorkspacePath: path.
	target exists ifFalse: [
		self error: 'File does not exist: ' , path ].
	target isFile ifFalse: [
		self error: 'Path is not a file: ' , path ].
	contents := target contents.
	contents size > 12000 ifTrue: [
		contents := (contents copyFrom: 1 to: 12000), String lf, '... truncated ...' ].
	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'File: ';
			nextPutAll: (aSloptalkAgent relativePathFor: target);
			nextPut: Character lf;
			nextPutAll: contents ]
]

{ #category : 'accessing' }
SloptalkReadFileTool >> name [
	^ 'read_file'
]

{ #category : 'documentation' }
SloptalkReadFileTool >> promptSpec [
	^ '- read_file: read a text file. Arguments: {"path":"relative/or/absolute/path"}'
]
