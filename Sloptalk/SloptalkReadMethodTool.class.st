"I read one compiled method from the image."
Class {
	#name : 'SloptalkReadMethodTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkReadMethodTool >> description [
	^ 'Read the source code for one method.'
]

{ #category : 'api' }
SloptalkReadMethodTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
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

	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'Method: ';
			nextPutAll: (aSloptalkAgent methodLabelFor: method);
			nextPut: Character lf;
			nextPutAll: 'Protocol: ';
			nextPutAll: method protocolName asString;
			nextPut: Character lf;
			nextPut: Character lf;
			nextPutAll: (aSloptalkAgent truncateText: method sourceCode to: 12000) ]
]

{ #category : 'accessing' }
SloptalkReadMethodTool >> name [
	^ 'read_method'
]

{ #category : 'documentation' }
SloptalkReadMethodTool >> promptSpec [
	^ '- read_method: read one method source. Arguments: {"class":"ClassName","selector":"methodSelector","class_side":false}'
]
