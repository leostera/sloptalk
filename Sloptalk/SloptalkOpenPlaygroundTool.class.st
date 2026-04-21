"I open a Playground or Workspace window."
Class {
	#name : 'SloptalkOpenPlaygroundTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkOpenPlaygroundTool >> description [
	^ 'Open the Playground and optionally prefill it with code.'
]

{ #category : 'api' }
SloptalkOpenPlaygroundTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| contents |
	contents := (self valueAt: #contents in: aDictionary ifAbsent: [ '' ]) asString.
	UIManager default defer: [
		contents isEmpty
			ifTrue: [ (Smalltalk tools toolNamed: #workspace) open ]
			ifFalse: [ (Smalltalk tools toolNamed: #workspace) openContents: contents ] ].
	^ contents isEmpty
		ifTrue: [ 'Scheduled empty Playground opening.' ]
		ifFalse: [ 'Scheduled Playground opening with provided contents.' ]
]

{ #category : 'accessing' }
SloptalkOpenPlaygroundTool >> name [
	^ 'open_playground'
]

{ #category : 'documentation' }
SloptalkOpenPlaygroundTool >> promptSpec [
	^ '- open_playground: open a Playground window. Arguments: {"contents":"optional Smalltalk code"}'
]
