"I evaluate arbitrary Smalltalk inside the image."
Class {
	#name : 'SloptalkEvaluateSmalltalkTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkEvaluateSmalltalkTool >> description [
	^ 'Evaluate Smalltalk code directly in the image and return the result.'
]

{ #category : 'api' }
SloptalkEvaluateSmalltalkTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| code result |
	code := self valueAt: #code in: aDictionary ifAbsent: [
		self error: 'Missing required argument: code' ].
	result := aSloptalkAgent evaluateSmalltalk: code asString.

	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'Result class: ';
			nextPutAll: result class name;
			nextPut: Character lf;
			nextPutAll: 'Result value:';
			nextPut: Character lf;
			nextPutAll: (aSloptalkAgent displayStringForObject: result) ]
]

{ #category : 'accessing' }
SloptalkEvaluateSmalltalkTool >> name [
	^ 'evaluate_smalltalk'
]

{ #category : 'documentation' }
SloptalkEvaluateSmalltalkTool >> promptSpec [
	^ '- evaluate_smalltalk: run arbitrary Smalltalk in the image. Arguments: {"code":"Smalltalk code"}'
]
