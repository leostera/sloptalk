"I open the system browser on a package."
Class {
	#name : 'SloptalkBrowsePackageTool',
	#superclass : 'SloptalkTool',
	#category : 'Sloptalk-Tools',
	#package : 'Sloptalk',
	#tag : 'Tools'
}

{ #category : 'documentation' }
SloptalkBrowsePackageTool >> description [
	^ 'Open the system browser on a package.'
]

{ #category : 'api' }
SloptalkBrowsePackageTool >> executeWithArguments: aDictionary forAgent: aSloptalkAgent [
	| packageName package |
	packageName := self valueAt: #package in: aDictionary ifAbsent: [
		self error: 'Missing required argument: package' ].
	package := aSloptalkAgent packageNamed: packageName.
	UIManager default defer: [
		(Smalltalk tools toolNamed: #browser) openOnPackage: package ].
	^ 'Scheduled browser opening for package ' , package name asString
]

{ #category : 'accessing' }
SloptalkBrowsePackageTool >> name [
	^ 'browse_package'
]

{ #category : 'documentation' }
SloptalkBrowsePackageTool >> promptSpec [
	^ '- browse_package: open the browser on a package. Arguments: {"package":"Package-Name"}'
]
