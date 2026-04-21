"I compile a method into a class or metaclass."
Class {
	#name : 'SloptalkCompileMethodTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkCompileMethodTool >> description [
	^ 'Compile a Smalltalk method into a class or class side.'
]

{ #category : 'api' }
SloptalkCompileMethodTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| className source protocolName classSide behavior selector |
	className := self valueAt: #class in: aDictionary ifAbsent: [
		self error: 'Missing required argument: class' ].
	source := self valueAt: #source in: aDictionary ifAbsent: [
		self error: 'Missing required argument: source' ].
	protocolName := self valueAt: #protocol in: aDictionary ifAbsent: [ Protocol unclassified ].
	classSide := self booleanAt: #class_side in: aDictionary ifAbsent: [ false ].
	behavior := aSloptalkAgent behaviorNamed: className classSide: classSide.
	selector := behavior compile: source asString classified: protocolName.

	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'Compiled ';
			nextPutAll: (aSloptalkAgent
				methodLabelForBehavior: behavior
				selector: selector);
			nextPutAll: ' under protocol ';
			nextPutAll: protocolName asString ]
]

{ #category : 'accessing' }
SloptalkCompileMethodTool >> name [
	^ 'compile_method'
]

{ #category : 'documentation' }
SloptalkCompileMethodTool >> promptSpec [
	^ '- compile_method: compile a method into a class. Arguments: {"class":"ClassName","source":"full method source","protocol":"accessing","class_side":false}'
]
