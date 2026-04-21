"I search method source text across the image."
Class {
	#name : 'SloptalkSearchMethodsTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkSearchMethodsTool >> description [
	^ 'Search for text inside method source code across the image.'
]

{ #category : 'api' }
SloptalkSearchMethodsTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| query caseSensitive methods limited |
	query := self valueAt: #query in: aDictionary ifAbsent: [
		self error: 'Missing required argument: query' ].
	caseSensitive := self booleanAt: #case_sensitive in: aDictionary ifAbsent: [ false ].
	methods := SystemNavigation new
		allMethodsWithSourceString: query
		matchCase: caseSensitive.
	limited := methods first: (methods size min: 200).

	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'Methods containing ';
			nextPutAll: query asString;
			nextPut: Character lf.
		limited
			ifEmpty: [ stream nextPutAll: 'No methods found.' ]
			ifNotEmpty: [
				limited do: [ :each |
					stream
						nextPutAll: (aSloptalkAgent methodLabelFor: each);
						nextPutAll: ' [';
						nextPutAll: each protocolName asString;
						nextPutAll: ']';
						nextPut: Character lf ].
				methods size > limited size ifTrue: [
					stream nextPutAll: '... truncated ...' ] ] ]
]

{ #category : 'accessing' }
SloptalkSearchMethodsTool >> name [
	^ 'search_methods'
]

{ #category : 'documentation' }
SloptalkSearchMethodsTool >> promptSpec [
	^ '- search_methods: search method source in the image. Arguments: {"query":"source text","case_sensitive":false}'
]
