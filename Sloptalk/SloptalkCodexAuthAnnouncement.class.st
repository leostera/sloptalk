"I announce changes to the shared Codex auth state."
Class {
	#name : 'SloptalkCodexAuthAnnouncement',
	#superclass : 'Announcement',
	#instVars : [
		'app',
		'state'
	],
	#category : 'Sloptalk-Announcements',
	#package : 'Sloptalk',
	#tag : 'Announcements'
}

{ #category : 'instance creation' }
SloptalkCodexAuthAnnouncement class >> app: aSloptalkApp state: aDictionary [
	^ self new
		app: aSloptalkApp;
		state: aDictionary;
		yourself
]

{ #category : 'accessing' }
SloptalkCodexAuthAnnouncement >> app [
	^ app
]

{ #category : 'accessing' }
SloptalkCodexAuthAnnouncement >> app: aSloptalkApp [
	app := aSloptalkApp
]

{ #category : 'accessing' }
SloptalkCodexAuthAnnouncement >> state [
	^ state
]

{ #category : 'accessing' }
SloptalkCodexAuthAnnouncement >> state: aDictionary [
	state := aDictionary
]
