"I implement the local ChatGPT device-auth flow used for Codex access."
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

{ #category : 'accessing' }
SloptalkCodexAuth class >> clientId [
	^ 'app_EMoamEEZ73f0CkXaXp7hrann'
]

{ #category : 'private' }
SloptalkCodexAuth class >> defaultPollingIntervalSeconds [
	^ 5
]

{ #category : 'private' }
SloptalkCodexAuth class >> defaultRequestTimeoutSeconds [
	^ 60
]

{ #category : 'private' }
SloptalkCodexAuth class >> defaultVerificationUrl [
	^ self issuerUrl , '/codex/device'
]

{ #category : 'private' }
SloptalkCodexAuth class >> deviceAuthTokenUrl [
	^ self issuerUrl , '/api/accounts/deviceauth/token'
]

{ #category : 'private' }
SloptalkCodexAuth class >> deviceAuthUserCodeUrl [
	^ self issuerUrl , '/api/accounts/deviceauth/usercode'
]

{ #category : 'private' }
SloptalkCodexAuth class >> deviceRedirectUrl [
	^ self issuerUrl , '/deviceauth/callback'
]

{ #category : 'private' }
SloptalkCodexAuth class >> extractAccountIdFromClaims: aDictionary [
	| authClaims organizations firstOrganization |
	authClaims := aDictionary
		at: 'https://api.openai.com/auth'
		ifAbsent: [ Dictionary new ].
	(authClaims isDictionary and: [
		(authClaims at: 'chatgpt_account_id' ifAbsent: [ nil ]) isString ]) ifTrue: [
		^ authClaims at: 'chatgpt_account_id' ].

	(aDictionary at: 'chatgpt_account_id' ifAbsent: [ nil ]) ifNotNil: [ :accountId |
		accountId isString ifTrue: [ ^ accountId ] ].

	organizations := aDictionary
		at: 'organizations'
		ifAbsent: [ authClaims at: 'organizations' ifAbsent: [ #() ] ].
	(organizations isCollection and: [ organizations isString not ]) ifFalse: [ ^ nil ].
	firstOrganization := organizations
		detect: [ :each | each isDictionary and: [ (each at: 'id' ifAbsent: [ nil ]) isString ] ]
		ifNone: [ nil ].
	^ firstOrganization
		ifNil: [ nil ]
		ifNotNil: [ firstOrganization at: 'id' ]
]

{ #category : 'api' }
SloptalkCodexAuth class >> extractAccountIdFromTokens: aDictionary [
	| idToken accessToken |
	idToken := aDictionary at: #idToken ifAbsent: [
		aDictionary at: 'id_token' ifAbsent: [ nil ] ].
	accessToken := aDictionary at: #accessToken ifAbsent: [
		aDictionary at: 'access_token' ifAbsent: [ nil ] ].

	idToken ifNotNil: [ :token |
		(self extractJwtAccountId: token) ifNotNil: [ :accountId | ^ accountId ] ].
	accessToken ifNotNil: [ :token |
		(self extractJwtAccountId: token) ifNotNil: [ :accountId | ^ accountId ] ].
	^ nil
]

{ #category : 'private' }
SloptalkCodexAuth class >> extractJwtAccountId: aJwtString [
	^ [ self
		extractAccountIdFromClaims: (self jwtClaimsFrom: aJwtString) ]
			on: Error
			do: [ :error | nil ]
]

{ #category : 'api' }
SloptalkCodexAuth class >> exchangeDeviceAuthorizationCode: anAuthorizationCode codeVerifier: aCodeVerifier [
	| client responseBody |
	client := ZnClient new.
	[
		client
			beOneShot;
			timeout: self defaultRequestTimeoutSeconds.
		client headerAt: 'Accept' put: 'application/json'.
		client
			url: self tokenUrl;
			formAt: 'grant_type' put: 'authorization_code';
			formAt: 'code' put: anAuthorizationCode;
			formAt: 'redirect_uri' put: self deviceRedirectUrl;
			formAt: 'client_id' put: self clientId;
			formAt: 'code_verifier' put: aCodeVerifier;
			post.
		client isSuccess ifFalse: [
			self error: 'Failed to exchange device code. Status: ' , client response statusLine asString ].
		responseBody := STONJSON fromString: client response entity contents.
		^ {
			#accessToken -> (self valueAt: 'access_token' in: responseBody ifAbsent: [ self error: 'Missing access_token' ]).
			#refreshToken -> (self valueAt: 'refresh_token' in: responseBody ifAbsent: [ self error: 'Missing refresh_token' ]).
			#idToken -> (self valueAt: 'id_token' in: responseBody ifAbsent: [ nil ]).
			#expiresIn -> (self valueAt: 'expires_in' in: responseBody ifAbsent: [ 3600 ])
		} asDictionary
	] ensure: [ client close ]
]

{ #category : 'private' }
SloptalkCodexAuth class >> issuerUrl [
	^ 'https://auth.openai.com'
]

{ #category : 'private' }
SloptalkCodexAuth class >> jsonClient [
	^ ZnClient new
		beOneShot;
		timeout: self defaultRequestTimeoutSeconds;
		forJsonREST;
		yourself
]

{ #category : 'private' }
SloptalkCodexAuth class >> jwtClaimsFrom: aJwtString [
	| payload padded normalized |
	payload := (aJwtString findTokens: '.') at: 2 ifAbsent: [
		self error: 'Invalid JWT token' ].
	normalized := payload copy.
	normalized := normalized copyReplaceAll: '-' with: '+'.
	normalized := normalized copyReplaceAll: '_' with: '/'.
	padded := self paddedBase64String: normalized.
	^ STONJSON fromString: padded base64Decoded utf8Decoded
]

{ #category : 'accessing' }
SloptalkCodexAuth class >> openAuthenticationDocs [
	^ WebBrowser openOn: self authenticationDocsUrl
]

{ #category : 'private' }
SloptalkCodexAuth class >> paddedBase64String: aString [
	| remainder |
	remainder := aString size \\ 4.
	remainder = 0 ifTrue: [ ^ aString ].
	^ aString , (String new: 4 - remainder withAll: $=)
]

{ #category : 'api' }
SloptalkCodexAuth class >> pollDeviceAuthorizationForId: aDeviceAuthId userCode: aUserCode [
	| client status responseBody authorizationCode codeVerifier |
	client := self jsonClient.
	[
		client
			post: self deviceAuthTokenUrl
			contents: ({
				'device_auth_id' -> aDeviceAuthId.
				'user_code' -> aUserCode
			} asDictionary).
		status := client response status.

		status = 200 ifTrue: [
			responseBody := client contents.
			authorizationCode := self
				valueAt: 'authorization_code'
				in: responseBody
				ifAbsent: [ self error: 'Missing authorization_code' ].
			codeVerifier := self
				valueAt: 'code_verifier'
				in: responseBody
				ifAbsent: [ self error: 'Missing code_verifier' ].
			^ {
				#status -> #authorized.
				#authorizationCode -> authorizationCode.
				#codeVerifier -> codeVerifier
			} asDictionary ].

		(#(403 404) includes: status) ifTrue: [
			^ { #status -> #pending } asDictionary ].

		status = 401 ifTrue: [
			^ {
				#status -> #declined.
				#errorText -> 'Authorization was declined.'
			} asDictionary ].

		^ {
			#status -> #error.
			#errorText -> 'Polling failed with status ' , client response statusLine asString
		} asDictionary
	] ensure: [ client close ]
]

{ #category : 'api' }
SloptalkCodexAuth class >> refreshSession: aSloptalkCodexSession [
	| client responseBody expiresIn accountId |
	aSloptalkCodexSession refreshToken ifNil: [
		self error: 'Missing refresh token for Codex session refresh.' ].

	client := ZnClient new.
	[
		client
			beOneShot;
			timeout: self defaultRequestTimeoutSeconds.
		client headerAt: 'Accept' put: 'application/json'.
		client
			url: self tokenUrl;
			formAt: 'grant_type' put: 'refresh_token';
			formAt: 'refresh_token' put: aSloptalkCodexSession refreshToken;
			formAt: 'client_id' put: self clientId;
			post.
		client isSuccess ifFalse: [
			self error: 'Failed to refresh Codex session. Status: ' , client response statusLine asString ].
		responseBody := STONJSON fromString: client response entity contents.
		expiresIn := self valueAt: 'expires_in' in: responseBody ifAbsent: [ 3600 ].
		accountId := self extractAccountIdFromTokens: responseBody.
		aSloptalkCodexSession
			accessToken: (self valueAt: 'access_token' in: responseBody ifAbsent: [ self error: 'Missing access_token' ]);
			refreshToken: (self valueAt: 'refresh_token' in: responseBody ifAbsent: [ aSloptalkCodexSession refreshToken ]);
			idToken: (self valueAt: 'id_token' in: responseBody ifAbsent: [ aSloptalkCodexSession idToken ]);
			expiresAt: (DateAndTime now + (Duration seconds: expiresIn));
			accountId: (accountId ifNil: [ aSloptalkCodexSession accountId ]).
		^ aSloptalkCodexSession
	] ensure: [ client close ]
]

{ #category : 'api' }
SloptalkCodexAuth class >> requestDeviceCode [
	| client responseBody deviceAuthId userCode interval verificationUrl |
	client := self jsonClient.
	[
		client
			post: self deviceAuthUserCodeUrl
			contents: ({ 'client_id' -> self clientId } asDictionary).
		client isSuccess ifFalse: [
			self error: 'Failed to request a device code. Status: ' , client response statusLine asString ].
		responseBody := client contents.
		deviceAuthId := self
			valueAt: 'device_auth_id'
			in: responseBody
			ifAbsent: [ self error: 'Missing device_auth_id' ].
		userCode := self
			valueAt: 'user_code'
			in: responseBody
			ifAbsent: [
				self valueAt: 'usercode' in: responseBody ifAbsent: [
					self error: 'Missing user_code' ] ].
		interval := self
			valueAt: 'interval'
			in: responseBody
			ifAbsent: [ self defaultPollingIntervalSeconds ].
		verificationUrl := self
			valueAt: 'verification_url'
			in: responseBody
			ifAbsent: [ self defaultVerificationUrl ].
		^ {
			#deviceAuthId -> deviceAuthId.
			#userCode -> userCode.
			#interval -> interval asInteger.
			#verificationUrl -> verificationUrl
		} asDictionary
	] ensure: [ client close ]
]

{ #category : 'private' }
SloptalkCodexAuth class >> tokenUrl [
	^ self issuerUrl , '/oauth/token'
]

{ #category : 'private' }
SloptalkCodexAuth class >> valueAt: aKey in: aDictionary ifAbsent: aBlock [
	^ aDictionary
		at: aKey
		ifAbsent: [
			aDictionary
				at: aKey asString
				ifAbsent: aBlock ]
]
