"I coordinate a conversation and a Codex bridge."
Class {
	#name : 'SloptalkAgent',
	#superclass : 'Object',
	#instVars : [
		'conversation',
		'bridge',
		'tools',
		'maxSteps',
		'systemPrompt',
		'announcer',
		'pendingTurns',
		'queueLock',
		'workerProcess',
		'isBusy',
		'lastReply'
	],
	#category : 'Sloptalk-Core',
	#package : 'Sloptalk',
	#tag : 'Core'
}

{ #category : 'tools' }
SloptalkAgent >> addDefaultTools [
	self addImageTools
]

{ #category : 'tools' }
SloptalkAgent >> addFilesystemTools [
	self addTool: SloptalkListFilesTool new.
	self addTool: SloptalkReadFileTool new.
	self addTool: SloptalkWriteFileTool new.
	self addTool: SloptalkSearchFilesTool new
]

{ #category : 'tools' }
SloptalkAgent >> addImageTools [
	self addTool: SloptalkListPackagesTool new.
	self addTool: SloptalkListClassesTool new.
	self addTool: SloptalkListMethodsTool new.
	self addTool: SloptalkSearchMethodsTool new.
	self addTool: SloptalkReadClassTool new.
	self addTool: SloptalkReadMethodTool new.
	self addTool: SloptalkBrowsePackageTool new.
	self addTool: SloptalkBrowseClassTool new.
	self addTool: SloptalkBrowseMethodTool new.
	self addTool: SloptalkOpenPlaygroundTool new.
	self addTool: SloptalkEvaluateSmalltalkTool new.
	self addTool: SloptalkCompileMethodTool new
]

{ #category : 'tools' }
SloptalkAgent >> addTool: aSloptalkTool [
	tools add: aSloptalkTool.
	^ aSloptalkTool
]

{ #category : 'announcing' }
SloptalkAgent >> announce: anAnnouncement [
	announcer announce: anAnnouncement
]

{ #category : 'accessing' }
SloptalkAgent >> announcer [
	^ announcer
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

{ #category : 'private' }
SloptalkAgent >> compiledMethodForClass: aClassName selector: aSelector classSide: aBoolean [
	| behavior selector |
	behavior := self behaviorNamed: aClassName classSide: aBoolean.
	selector := aSelector asString asSymbol.
	^ behavior
		compiledMethodAt: selector
		ifAbsent: [
			self
				error:
					'Unknown method: '
						, (self methodLabelForBehavior: behavior selector: selector) ]
]

{ #category : 'defaults' }
SloptalkAgent >> defaultSystemPrompt [
	^ 'You are Sloptalk, a local coding agent running inside a live Pharo image.'
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
			nextPutAll: 'You are operating inside the image first, not just on files.';
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
			nextPutAll: '- Prefer image tools over filesystem tools for packages, classes, methods, and UI actions.';
			nextPut: Character lf;
			nextPutAll: '- After a tool result, either call another tool or answer the user.';
			nextPut: Character lf;
			nextPutAll: '- Use browse_* and open_playground when the user asks to open a tool window.';
			nextPut: Character lf;
			nextPutAll: '- Use compile_method for method edits and evaluate_smalltalk for arbitrary image actions.';
			nextPut: Character lf;
			nextPutAll: '- For file paths, prefer paths relative to the workspace root when filesystem tools are available.';
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

{ #category : 'private' }
SloptalkAgent >> behaviorNamed: aString classSide: aBoolean [
	| class |
	class := self classNamed: aString.
	^ aBoolean
		ifTrue: [ class classSide ]
		ifFalse: [ class instanceSide ]
]

{ #category : 'private' }
SloptalkAgent >> classNamed: aString [
	^ Smalltalk globals
		at: aString asString asSymbol
		ifAbsent: [ self error: 'Unknown class: ' , aString asString ]
]

{ #category : 'initialization' }
SloptalkAgent >> initialize [
	super initialize.
	conversation := SloptalkConversation new.
	bridge := SloptalkCodexBridge new.
	tools := OrderedCollection new.
	maxSteps := 8.
	systemPrompt := self defaultSystemPrompt.
	announcer := Announcer new.
	pendingTurns := OrderedCollection new.
	queueLock := Semaphore forMutualExclusion.
	workerProcess := nil.
	isBusy := false.
	lastReply := nil.
	self addDefaultTools
]

{ #category : 'api' }
SloptalkAgent >> receiveUserMessage: aString [
	^ self sendAndWait: aString
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

{ #category : 'accessing' }
SloptalkAgent >> lastReply [
	^ lastReply
]

{ #category : 'private' }
SloptalkAgent >> methodLabelFor: aCompiledMethod [
	^ self
		methodLabelForBehavior: aCompiledMethod methodClass
		selector: aCompiledMethod selector
]

{ #category : 'private' }
SloptalkAgent >> methodLabelForBehavior: aBehavior selector: aSelector [
	^ aBehavior isMeta
		ifTrue: [ aBehavior instanceSide name , ' class>>' , aSelector asString ]
		ifFalse: [ aBehavior name , '>>' , aSelector asString ]
]

{ #category : 'private' }
SloptalkAgent >> nextPendingTurn [
	^ queueLock critical: [
		pendingTurns
			ifEmpty: [ nil ]
			ifNotEmpty: [ pendingTurns removeFirst ] ]
]

{ #category : 'private' }
SloptalkAgent >> packageNamed: aString [
	^ PackageOrganizer default
		packageNamed: aString
		ifAbsent: [ self error: 'Unknown package: ' , aString asString ]
]

{ #category : 'accessing' }
SloptalkAgent >> pendingTurns [
	^ queueLock critical: [ pendingTurns asArray ]
]

{ #category : 'private' }
SloptalkAgent >> processPendingTurns [
	[
		[ | turn |
		turn := self nextPendingTurn.
		turn ifNil: [ ^ self ].
		self processTurn: turn ] repeat
	] ensure: [
		queueLock critical: [
			workerProcess := nil.
			pendingTurns ifNotEmpty: [
				workerProcess := self spawnWorkerProcess ] ] ]
]

{ #category : 'private' }
SloptalkAgent >> processTurn: aSloptalkTurn [
	| reply errorText |
	isBusy := true.
	aSloptalkTurn markRunning.
	self announce: (SloptalkTurnStarted agent: self turn: aSloptalkTurn).

	[
		conversation addUserMessage: aSloptalkTurn prompt.
		reply := self runLoop.
		lastReply := reply.
		aSloptalkTurn markCompletedWith: reply.
		self announce: (SloptalkTurnCompleted agent: self turn: aSloptalkTurn)
	] on: Error do: [ :error |
		errorText := error messageText.
		lastReply := 'Error: ' , errorText.
		conversation addAssistantMessage: 'Error: ' , errorText.
		aSloptalkTurn markFailedWith: errorText.
		self announce: (SloptalkTurnFailed agent: self turn: aSloptalkTurn) ]
		ensure: [ isBusy := false ]
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
	| turn |
	turn := SloptalkTurn prompt: aString.
	queueLock critical: [
		pendingTurns add: turn.
		self ensureWorkerRunning ].
	self announce: (SloptalkTurnQueued agent: self turn: turn).
	^ turn
]

{ #category : 'api' }
SloptalkAgent >> sendAndWait: aString [
	^ (self send: aString) waitForReply
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

{ #category : 'private' }
SloptalkAgent >> spawnWorkerProcess [
	^ [ self processPendingTurns ]
		forkAt: Processor userBackgroundPriority
		named: 'Sloptalk agent loop'
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

{ #category : 'accessing' }
SloptalkAgent >> busy [
	^ isBusy or: [ self pendingTurns isNotEmpty ]
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

{ #category : 'private' }
SloptalkAgent >> ensureWorkerRunning [
	workerProcess ifNotNil: [
		workerProcess isTerminated ifFalse: [ ^ self ].
		workerProcess := nil ].
	workerProcess := self spawnWorkerProcess
]

{ #category : 'private' }
SloptalkAgent >> evaluateSmalltalk: aString [
	^ OpalCompiler new
		source: aString;
		evaluate
]

{ #category : 'private' }
SloptalkAgent >> truncateText: aString to: anInteger [
	aString size <= anInteger ifTrue: [ ^ aString ].
	^ (aString copyFrom: 1 to: anInteger) , String lf , '... truncated ...'
]

{ #category : 'announcing' }
SloptalkAgent >> unsubscribe: anObject [
	announcer unsubscribe: anObject
]

{ #category : 'announcing' }
SloptalkAgent >> when: anAnnouncementClass do: aBlock [
	^ announcer when: anAnnouncementClass do: aBlock
]

{ #category : 'private' }
SloptalkAgent >> displayStringForObject: anObject [
	| display |
	display := [ anObject printString ]
		on: Error
		do: [ :error | '<printString error: ' , error messageText , '>' ].
	^ self truncateText: display to: 8000
]
