"I am the base announcement for turn lifecycle events."
Class {
	#name : 'SloptalkTurnAnnouncement',
	#superclass : 'Announcement',
	#instVars : [
		'agent',
		'turn'
	],
	#category : 'Sloptalk-Announcements',
	#package : 'Sloptalk',
	#tag : 'Announcements'
}

{ #category : 'instance creation' }
SloptalkTurnAnnouncement class >> agent: aSloptalkAgent turn: aSloptalkTurn [
	^ self new
		agent: aSloptalkAgent;
		turn: aSloptalkTurn;
		yourself
]

{ #category : 'accessing' }
SloptalkTurnAnnouncement >> agent [
	^ agent
]

{ #category : 'accessing' }
SloptalkTurnAnnouncement >> agent: aSloptalkAgent [
	agent := aSloptalkAgent
]

{ #category : 'accessing' }
SloptalkTurnAnnouncement >> turn [
	^ turn
]

{ #category : 'accessing' }
SloptalkTurnAnnouncement >> turn: aSloptalkTurn [
	turn := aSloptalkTurn
]
