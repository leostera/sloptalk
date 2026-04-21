"I hold the locally stored ChatGPT OAuth session used for Codex requests."
Class {
	#name : 'SloptalkCodexSession',
	#superclass : 'Object',
	#instVars : [
		'accessToken',
		'refreshToken',
		'idToken',
		'expiresAt',
		'accountId'
	],
	#category : 'Sloptalk-Integration',
	#package : 'Sloptalk',
	#tag : 'Integration'
}

{ #category : 'instance creation' }
SloptalkCodexSession class >> accessToken: anAccessToken refreshToken: aRefreshToken idToken: anIdToken expiresAt: aDateAndTime accountId: anAccountId [
	^ self new
		accessToken: anAccessToken;
		refreshToken: aRefreshToken;
		idToken: anIdToken;
		expiresAt: aDateAndTime;
		accountId: anAccountId;
		yourself
]

{ #category : 'accessing' }
SloptalkCodexSession >> accessToken [
	^ accessToken
]

{ #category : 'accessing' }
SloptalkCodexSession >> accessToken: aString [
	accessToken := aString
]

{ #category : 'accessing' }
SloptalkCodexSession >> accountId [
	^ accountId
]

{ #category : 'accessing' }
SloptalkCodexSession >> accountId: aString [
	accountId := aString
]

{ #category : 'testing' }
SloptalkCodexSession >> expired [
	expiresAt ifNil: [ ^ false ].
	^ expiresAt <= (DateAndTime now + (Duration seconds: 60))
]

{ #category : 'accessing' }
SloptalkCodexSession >> expiresAt [
	^ expiresAt
]

{ #category : 'accessing' }
SloptalkCodexSession >> expiresAt: aDateAndTime [
	expiresAt := aDateAndTime
]

{ #category : 'accessing' }
SloptalkCodexSession >> idToken [
	^ idToken
]

{ #category : 'accessing' }
SloptalkCodexSession >> idToken: aString [
	idToken := aString
]

{ #category : 'testing' }
SloptalkCodexSession >> isConnected [
	^ accessToken isString and: [ accessToken isNotEmpty ]
]

{ #category : 'accessing' }
SloptalkCodexSession >> refreshToken [
	^ refreshToken
]

{ #category : 'accessing' }
SloptalkCodexSession >> refreshToken: aString [
	refreshToken := aString
]
