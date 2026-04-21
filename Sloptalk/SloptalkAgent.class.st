"I coordinate a conversation and a Codex bridge."
Class {
	#name : 'SloptalkAgent',
	#superclass : 'Object',
	#instVars : [
		'conversation',
		'bridge',
		'tools',
		'maxSteps',
		'systemPrompt'
	],
	#category : 'Sloptalk-Core',
	#package : 'Sloptalk',
	#tag : 'Core'
}

{ #category : 'tools' }
SloptalkAgent >> addDefaultTools [
	self addTool: SloptalkListFilesTool new.
	self addTool: SloptalkReadFileTool new.
	self addTool: SloptalkWriteFileTool new.
	self addTool: SloptalkSearchFilesTool new
]

{ #category : 'tools' }
SloptalkAgent >> addTool: aSloptalkTool [
	tools add: aSloptalkTool.
	^ aSloptalkTool
]

{ #category : 'accessing' }
SloptalkAgent >> bridge [
	^ bridge
]

{ #category : 'accessing' }
SloptalkAgent >> bridge: aSloptalkCodexBridge [
	bridge := aSloptalkCodexBridge
]

{ #category : 'private' }
SloptalkAgent >> decisionFromResponse: aString [
	| normalized |
	normalized := self normalizedJsonTextFrom: aString.

	^ [ STONJSON fromString: normalized ]
		on: Error
		do: [ :error |
			{
				#type -> 'assistant'.
				#message -> aString
			} asDictionary ]
]

{ #category : 'private' }
SloptalkAgent >> decisionTypeOf: aDictionary [
	^ self valueAt: #type in: aDictionary ifAbsent: [ 'assistant' ]
]

{ #category : 'accessing' }
SloptalkAgent >> model [
	^ bridge model
]

{ #category : 'accessing' }
SloptalkAgent >> model: aString [
	bridge model: aString
]

{ #category : 'accessing' }
SloptalkAgent >> conversation [
	^ conversation
]

{ #category : 'defaults' }
SloptalkAgent >> defaultSystemPrompt [
	^ 'You are Sloptalk, a local coding agent working inside a Pharo image.' 
]

{ #category : 'private' }
SloptalkAgent >> effectiveSystemPrompt [
	^ String streamContents: [ :stream |
		stream
			nextPutAll: systemPrompt;
			nextPut: Character lf;
			nextPut: Character lf;
			nextPutAll: 'Workspace root: ';
			nextPutAll: self workspaceReference fullName;
			nextPut: Character lf;
			nextPut: Character lf;
			nextPutAll: 'You can use tools. Respond with JSON only. Do not use markdown fences. Do not explain the JSON.';
			nextPut: Character lf;
			nextPutAll: 'Return exactly one of these objects:';
			nextPut: Character lf;
			nextPutAll: '{"type":"assistant","message":"final answer for the user"}';
			nextPut: Character lf;
			nextPutAll: '{"type":"tool_call","tool":"tool_name","arguments":{"key":"value"}}';
			nextPut: Character lf;
			nextPut: Character lf;
			nextPutAll: 'Rules:';
			nextPut: Character lf;
			nextPutAll: '- Call at most one tool per response.';
			nextPut: Character lf;
			nextPutAll: '- Use tools when you need workspace information.';
			nextPut: Character lf;
			nextPutAll: '- After a tool result, either call another tool or answer the user.';
			nextPut: Character lf;
			nextPutAll: '- For file paths, prefer paths relative to the workspace root.';
			nextPut: Character lf;
			nextPut: Character lf;
			nextPutAll: 'Available tools:';
			nextPut: Character lf.
		tools do: [ :tool |
			stream nextPutAll: tool promptSpec; nextPut: Character lf ] ]
]

{ #category : 'private' }
SloptalkAgent >> executeToolDecision: aDecision rawResponse: aString [
	| toolName arguments resultText isError |
	toolName := self valueAt: #tool in: aDecision ifAbsent: [ 'unknown' ].
	arguments := self valueAt: #arguments in: aDecision ifAbsent: [ Dictionary new ].

	conversation addMessage: (
		SloptalkMessage
			role: 'assistant'
			text: aString
			details: aDecision).

	isError := false.
	resultText := [
		(self toolNamed: toolName) executeWithArguments: arguments forAgent: self ]
			on: Error
			do: [ :error |
				isError := true.
				'Error: ' , error messageText ].

	conversation
		addToolResultNamed: toolName
		text: resultText
		isError: isError
]

{ #category : 'private' }
SloptalkAgent >> finalAssistantTextFrom: aDecision rawResponse: aString [
	^ self valueAt: #message in: aDecision ifAbsent: [ aString ]
]

{ #category : 'initialization' }
SloptalkAgent >> initialize [
	super initialize.
	conversation := SloptalkConversation new.
	bridge := SloptalkCodexBridge new.
	tools := OrderedCollection new.
	maxSteps := 8.
	systemPrompt := self defaultSystemPrompt.
	self addDefaultTools
]

{ #category : 'api' }
SloptalkAgent >> receiveUserMessage: aString [
	conversation addUserMessage: aString.
	^ self runLoop
]

{ #category : 'accessing' }
SloptalkAgent >> maxSteps [
	^ maxSteps
]

{ #category : 'accessing' }
SloptalkAgent >> maxSteps: anInteger [
	maxSteps := anInteger
]

{ #category : 'private' }
SloptalkAgent >> normalizedJsonTextFrom: aString [
	| trimmed firstLineBreak |
	trimmed := aString trimBoth.
	(trimmed beginsWith: '```') ifTrue: [
		firstLineBreak := trimmed indexOf: Character lf.
		firstLineBreak > 0 ifTrue: [
			trimmed := (trimmed copyFrom: firstLineBreak + 1 to: trimmed size) trimBoth ].
		(trimmed endsWith: '```') ifTrue: [
			trimmed := (trimmed copyFrom: 1 to: trimmed size - 3) trimBoth ] ].
	^ trimmed
]

{ #category : 'printing' }
SloptalkAgent >> transcriptString [
	^ conversation transcriptString
]

{ #category : 'private' }
SloptalkAgent >> runLoop [
	| stepCount rawResponse decision type reply |
	stepCount := 0.

	[ stepCount < maxSteps ] whileTrue: [
		stepCount := stepCount + 1.
		rawResponse := bridge
			completeConversation: conversation
			systemPrompt: self effectiveSystemPrompt.
		decision := self decisionFromResponse: rawResponse.
		type := self decisionTypeOf: decision.

		type = 'assistant' ifTrue: [
			reply := self finalAssistantTextFrom: decision rawResponse: rawResponse.
			conversation addAssistantMessage: reply.
			^ reply ].

		type = 'tool_call' ifTrue: [
			self executeToolDecision: decision rawResponse: rawResponse ].

		(type ~= 'assistant' and: [ type ~= 'tool_call' ]) ifTrue: [
			reply := rawResponse.
			conversation addAssistantMessage: reply.
			^ reply ] ].

	reply := 'Stopped after reaching the maximum number of steps.'.
	conversation addAssistantMessage: reply.
	^ reply
]

{ #category : 'api' }
SloptalkAgent >> send: aString [
	^ self receiveUserMessage: aString
]

{ #category : 'accessing' }
SloptalkAgent >> systemPrompt [
	^ systemPrompt
]

{ #category : 'accessing' }
SloptalkAgent >> systemPrompt: aString [
	systemPrompt := aString
]

{ #category : 'private' }
SloptalkAgent >> toolNamed: aString [
	^ tools
		detect: [ :tool | tool name = aString ]
		ifNone: [ self error: 'Unknown tool: ' , aString ]
]

{ #category : 'accessing' }
SloptalkAgent >> tools [
	^ tools asArray
]

{ #category : 'private' }
SloptalkAgent >> valueAt: aKey in: aDictionary ifAbsent: aBlock [
	^ aDictionary
		at: aKey
		ifAbsent: [
			aDictionary
				at: aKey asString
				ifAbsent: aBlock ]
]

{ #category : 'accessing' }
SloptalkAgent >> baseUrl [
	^ bridge baseUrl
]

{ #category : 'accessing' }
SloptalkAgent >> baseUrl: aString [
	bridge baseUrl: aString
]

{ #category : 'accessing' }
SloptalkAgent >> workspacePath [
	^ bridge workspacePath
]

{ #category : 'accessing' }
SloptalkAgent >> workspacePath: aString [
	bridge workspacePath: aString
]

{ #category : 'private' }
SloptalkAgent >> workspaceReference [
	^ self workspacePath asFileReference
]

{ #category : 'private' }
SloptalkAgent >> resolveWorkspacePath: aString [
	| workspace target |
	workspace := self workspaceReference.
	target := aString asFileReference.
	target isAbsolute ifFalse: [
		target := workspace resolveString: aString ].
	((workspace fullPath = target fullPath)
		or: [ workspace containsPath: target fullPath ]) ifFalse: [
		self error: 'Path is outside the workspace: ' , aString ].
	^ target
]

{ #category : 'private' }
SloptalkAgent >> relativePathFor: aFileReference [
	| workspace |
	workspace := self workspaceReference.
	^ ((workspace fullPath = aFileReference fullPath)
		ifTrue: [ '.' asPath ]
		ifFalse: [ aFileReference relativeToReference: workspace ]) pathString
]
