"I describe a class loaded in the image."
Class {
	#name : 'SloptalkReadClassTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkReadClassTool >> description [
	^ 'Read a class definition, protocols, and local selectors.'
]

{ #category : 'api' }
SloptalkReadClassTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| class packageName instanceSelectors classSelectors |
	class := aSloptalkAgent
		classNamed: (
			self valueAt: #class in: aDictionary ifAbsent: [
				self error: 'Missing required argument: class' ]).
	packageName := (PackageOrganizer default packageOf: class) name asString.
	instanceSelectors := class localSelectors asSortedCollection.
	classSelectors := class classSide localSelectors asSortedCollection.

	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'Class: ';
			nextPutAll: class name;
			nextPut: Character lf;
			nextPutAll: 'Package: ';
			nextPutAll: packageName;
			nextPut: Character lf;
			nextPut: Character lf;
			nextPutAll: 'Definition:';
			nextPut: Character lf;
			nextPutAll: class definitionString;
			nextPut: Character lf;
			nextPut: Character lf;
			nextPutAll: 'Class-side definition:';
			nextPut: Character lf;
			nextPutAll: class classSide definitionString;
			nextPut: Character lf;
			nextPut: Character lf;
			nextPutAll: 'Instance protocols: ';
			nextPutAll: ((class protocolNames collect: [ :each | each asString ]) asSortedCollection joinUsing: ', ');
			nextPut: Character lf;
			nextPutAll: 'Class-side protocols: ';
			nextPutAll: ((class classSide protocolNames collect: [ :each | each asString ]) asSortedCollection joinUsing: ', ');
			nextPut: Character lf;
			nextPut: Character lf;
			nextPutAll: 'Local instance selectors: ';
			nextPutAll: (self selectorSummaryFor: instanceSelectors withAgent: aSloptalkAgent);
			nextPut: Character lf;
			nextPutAll: 'Local class selectors: ';
			nextPutAll: (self selectorSummaryFor: classSelectors withAgent: aSloptalkAgent) ]
]

{ #category : 'accessing' }
SloptalkReadClassTool >> name [
	^ 'read_class'
]

{ #category : 'documentation' }
SloptalkReadClassTool >> promptSpec [
	^ '- read_class: read a class definition and local methods. Arguments: {"class":"ClassName"}'
]

{ #category : 'private' }
SloptalkReadClassTool >> selectorSummaryFor: aCollection withAgent: aSloptalkAgent [
	| names limited |
	names := aCollection collect: [ :each | each asString ].
	limited := names first: (names size min: 120).
	^ aSloptalkAgent
		truncateText: (limited joinUsing: ', ')
		to: 4000
]
