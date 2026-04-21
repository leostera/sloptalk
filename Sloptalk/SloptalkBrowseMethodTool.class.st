"I open the system browser on a method."
Class {
	#name : 'SloptalkBrowseMethodTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkBrowseMethodTool >> description [
	^ 'Open the system browser on a method.'
]

{ #category : 'api' }
SloptalkBrowseMethodTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| className selector classSide method |
	className := self valueAt: #class in: aDictionary ifAbsent: [
		self error: 'Missing required argument: class' ].
	selector := self valueAt: #selector in: aDictionary ifAbsent: [
		self error: 'Missing required argument: selector' ].
	classSide := self booleanAt: #class_side in: aDictionary ifAbsent: [ false ].
	method := aSloptalkAgent
		compiledMethodForClass: className
		selector: selector
		classSide: classSide.
	UIManager default defer: [
		(Smalltalk tools toolNamed: #browser)
			openOnClass: method methodClass
			selector: method selector ].
	^ 'Scheduled browser opening for ' , (aSloptalkAgent methodLabelFor: method)
]

{ #category : 'accessing' }
SloptalkBrowseMethodTool >> name [
	^ 'browse_method'
]

{ #category : 'documentation' }
SloptalkBrowseMethodTool >> promptSpec [
	^ '- browse_method: open the browser on a method. Arguments: {"class":"ClassName","selector":"methodSelector","class_side":false}'
]
