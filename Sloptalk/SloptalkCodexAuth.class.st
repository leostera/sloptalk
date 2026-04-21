"I expose a small bridge to Codex CLI authentication commands."
Class {
	#name : 'SloptalkCodexAuth',
	#superclass : 'Object',
	#category : 'Sloptalk-Integration',
	#package : 'Sloptalk',
	#tag : 'Integration'
}

{ #category : 'accessing' }
SloptalkCodexAuth class >> authenticationDocsUrl [
	^ 'https://developers.openai.com/codex/auth'
]

{ #category : 'testing' }
SloptalkCodexAuth class >> codexInstalled [
	^ ((self runShellCommand: 'command -v codex') at: #exitCode) = 0
]

{ #category : 'api' }
SloptalkCodexAuth class >> loginStatusText [
	| result output |
	self codexInstalled ifFalse: [
		^ 'Codex CLI not found in PATH.' ].
	result := self runShellCommand: 'codex login status'.
	output := (result at: #output) trimBoth.
	output ifNotEmpty: [ ^ output ].
	^ (result at: #exitCode) = 0
		ifTrue: [ 'Codex CLI is installed.' ]
		ifFalse: [ 'Codex login status is unavailable.' ]
]

{ #category : 'api' }
SloptalkCodexAuth class >> openAuthenticationDocs [
	^ WebBrowser openOn: self authenticationDocsUrl
]

{ #category : 'api' }
SloptalkCodexAuth class >> openDeviceLogin [
	self codexInstalled ifFalse: [
		self openAuthenticationDocs.
		^ UIManager default
			inform: 'Codex CLI was not found. Install Codex first, then run `codex login --device-auth`.' ].

	OSPlatform current isMacOS ifTrue: [
		^ self openMacDeviceLogin ].

	self openAuthenticationDocs.
	^ UIManager default
		inform:
			'Run `codex login --device-auth` in a terminal, then come back and refresh Codex status.'
]

{ #category : 'private' }
SloptalkCodexAuth class >> openMacDeviceLogin [
	LibC system:
		'osascript -e ''tell application "Terminal" to activate'' -e ''tell application "Terminal" to do script "codex login --device-auth"'''.
	self openAuthenticationDocs
]

{ #category : 'private' }
SloptalkCodexAuth class >> runShellCommand: aString [
	| outputPath exitCode output |
	outputPath := FileLocator temp / 'sloptalk-codex-command-output.txt'.
	exitCode := LibC system: aString , ' > "' , outputPath fullName , '" 2>&1'.
	output := outputPath exists
		ifTrue: [
			[ outputPath readStreamDo: [ :stream | stream contents ] ]
				ensure: [ outputPath delete ] ]
		ifFalse: [ '' ].
	^ {
		#exitCode -> exitCode.
		#output -> output
	} asDictionary
]
