"I open the system browser on a class."
Class {
	#name : 'SloptalkBrowseClassTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkBrowseClassTool >> description [
	^ 'Open the system browser on a class or class side.'
]

{ #category : 'api' }
SloptalkBrowseClassTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| className classSide behavior |
	className := self valueAt: #class in: aDictionary ifAbsent: [
		self error: 'Missing required argument: class' ].
	classSide := self booleanAt: #class_side in: aDictionary ifAbsent: [ false ].
	behavior := aSloptalkAgent behaviorNamed: className classSide: classSide.
	UIManager default defer: [
		(Smalltalk tools toolNamed: #browser) openOnClass: behavior ].
	^ 'Scheduled browser opening for ' , (classSide
		ifTrue: [ className asString , ' class' ]
		ifFalse: [ className asString ])
]

{ #category : 'accessing' }
SloptalkBrowseClassTool >> name [
	^ 'browse_class'
]

{ #category : 'documentation' }
SloptalkBrowseClassTool >> promptSpec [
	^ '- browse_class: open the browser on a class. Arguments: {"class":"ClassName","class_side":false}'
]
