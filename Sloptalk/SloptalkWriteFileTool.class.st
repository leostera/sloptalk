"I write text files inside the workspace."
Class {
	#name : 'SloptalkWriteFileTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkWriteFileTool >> description [
	^ 'Write a text file in the workspace.'
]

{ #category : 'api' }
SloptalkWriteFileTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| path content target |
	path := self valueAt: #path in: aDictionary ifAbsent: [
		self error: 'Missing required argument: path' ].
	content := self valueAt: #content in: aDictionary ifAbsent: [
		self error: 'Missing required argument: content' ].
	target := aSloptalkAgent resolveWorkspacePath: path.
	target parent ensureCreateDirectory.
	target ensureCreateFile.
	target writeStreamDo: [ :stream | stream nextPutAll: content ].

	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'Wrote ';
			nextPutAll: (aSloptalkAgent relativePathFor: target);
			nextPutAll: ' (';
			nextPutAll: content size asString;
			nextPutAll: ' chars)' ]
]

{ #category : 'accessing' }
SloptalkWriteFileTool >> name [
	^ 'write_file'
]

{ #category : 'documentation' }
SloptalkWriteFileTool >> promptSpec [
	^ '- write_file: write a full text file. Arguments: {"path":"relative/or/absolute/path","content":"full file contents"}'
]
