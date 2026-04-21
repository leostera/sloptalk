"I post JSON requests to an HTTP endpoint and normalize JSON responses."
Class {
	#name : 'SloptalkHTTPJSONProvider',
	#superclass : 'SloptalkLLMProvider',
	#instVars : [
		'baseUrl',
		'endpointPath',
		'apiKey'
	],
	#category : 'Sloptalk-Providers',
	#package : 'Sloptalk',
	#tag : 'Providers'
}

{ #category : 'accessing' }
SloptalkHTTPJSONProvider >> apiKey [
	^ apiKey
]

{ #category : 'accessing' }
SloptalkHTTPJSONProvider >> apiKey: aString [
	apiKey := aString
]

{ #category : 'private' }
SloptalkHTTPJSONProvider >> assistantTextFromPayload: aDictionary [
	self subclassResponsibility
]

{ #category : 'accessing' }
SloptalkHTTPJSONProvider >> baseUrl [
	^ baseUrl
]

{ #category : 'accessing' }
SloptalkHTTPJSONProvider >> baseUrl: aString [
	baseUrl := aString
]

{ #category : 'api' }
SloptalkHTTPJSONProvider >> completeRequest: aSloptalkLLMRequest [
	| client responseBody payload |
	client := ZnClient new.
	[
		[
			self prepareRequest: aSloptalkLLMRequest.
			self prepareClient: client.
			client
				post: self endpointUrl
				contents: (self requestBodyForRequest: aSloptalkLLMRequest)
		] on: ConnectionTimedOut do: [ :error |
			self
				error:
					'Chat completion request timed out after '
						, requestTimeoutSeconds asString
						, ' seconds' ].
		client isSuccess ifFalse: [
			responseBody := [ client response entity contents ]
				on: Error
				do: [ :error | '' ].
			self
				error:
					'Chat completion request failed with status '
						, client response statusLine asString
						, (responseBody
							ifEmpty: [ '' ]
							ifNotEmpty: [ ': ' , responseBody ]) ].
		payload := client contents.
		^ self responseFromPayload: payload
	] ensure: [ client close ]
]

{ #category : 'defaults' }
SloptalkHTTPJSONProvider >> defaultApiKey [
	self subclassResponsibility
]

{ #category : 'defaults' }
SloptalkHTTPJSONProvider >> defaultBaseUrl [
	self subclassResponsibility
]

{ #category : 'defaults' }
SloptalkHTTPJSONProvider >> defaultEndpointPath [
	self subclassResponsibility
]

{ #category : 'accessing' }
SloptalkHTTPJSONProvider >> displayString [
	^ self providerName , ' (' , model , ') @ ' , baseUrl
]

{ #category : 'private' }
SloptalkHTTPJSONProvider >> endpointUrl [
	^ baseUrl , endpointPath
]

{ #category : 'accessing' }
SloptalkHTTPJSONProvider >> endpointPath [
	^ endpointPath
]

{ #category : 'accessing' }
SloptalkHTTPJSONProvider >> endpointPath: aString [
	endpointPath := aString
]

{ #category : 'initialization' }
SloptalkHTTPJSONProvider >> initialize [
	super initialize.
	baseUrl := self defaultBaseUrl.
	endpointPath := self defaultEndpointPath.
	apiKey := self defaultApiKey
]

{ #category : 'private' }
SloptalkHTTPJSONProvider >> normalizeContent: anObject [
	anObject isString ifTrue: [ ^ anObject ].
	(anObject isCollection and: [ anObject isString not ]) ifTrue: [
		^ String streamContents: [ :stream |
			anObject do: [ :part |
				| text |
				text := part isDictionary
					ifTrue: [ self valueAt: #text in: part ifAbsent: [ '' ] ]
					ifFalse: [ part asString ].
				stream nextPutAll: text ] ] ].
	^ anObject asString
]

{ #category : 'private' }
SloptalkHTTPJSONProvider >> prepareClient: aZnClient [
	aZnClient
		beOneShot;
		timeout: requestTimeoutSeconds;
		forJsonREST.
	apiKey ifNotNil: [
		aZnClient setBearerAuthentication: apiKey ]
]

{ #category : 'private' }
SloptalkHTTPJSONProvider >> prepareRequest: aSloptalkLLMRequest [
	^ aSloptalkLLMRequest
]

{ #category : 'private' }
SloptalkHTTPJSONProvider >> requestBodyForRequest: aSloptalkLLMRequest [
	self subclassResponsibility
]

{ #category : 'private' }
SloptalkHTTPJSONProvider >> responseFromPayload: aDictionary [
	^ SloptalkLLMResponse
		text: (self assistantTextFromPayload: aDictionary)
		payload: aDictionary
		metadata: (self responseMetadataFromPayload: aDictionary)
]

{ #category : 'private' }
SloptalkHTTPJSONProvider >> responseMetadataFromPayload: aDictionary [
	| metadata responseId |
	metadata := Dictionary new.
	responseId := self
		valueAt: #id
		in: aDictionary
		ifAbsent: [
			self
				valueAt: #response_id
				in: aDictionary
				ifAbsent: [ nil ] ].
	responseId ifNotNil: [
		metadata at: #response_id put: responseId ].
	^ metadata
]

{ #category : 'private' }
SloptalkHTTPJSONProvider >> valueAt: aKey in: aDictionary ifAbsent: aBlock [
	^ aDictionary
		at: aKey
		ifAbsent: [
			aDictionary
				at: aKey asString
				ifAbsent: aBlock ]
]
