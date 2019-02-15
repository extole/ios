# ExtoleKit REST API inegration

Most REST API require you to supply ConsumerToken,
you should use the same access_token for the duration of user session.

## Get ConsumerToken

```swift
let program = Program(baseUrl: URL.init(string: "https://ios-santa.extole.io")!)
program.getToken(success: { token in
  // save token for later
}, error: { error in
  // handle error here
})

```

## Verify ConsumerToken
You should verify saved access_token before it's used

```swift
let program = Program(baseUrl: URL.init(string: "https://ios-santa.extole.io")!)
let programSession = ProgramSession.init(program: program, token: existingToken)
programSession.getToken(success: { token in
  // token is valid
}, error: { error in
  // error verifying token
  switch(error) {
  case GetTokenError.invalidAccessToken: // token is invalid, get a new token 
  default: // some other error happened - retry later
  }
})

```

## Get Profile
```swift
let program = Program(baseUrl: URL.init(string: "https://ios-santa.extole.io")!)
let programSession = ProgramSession.init(program: program, token: existingToken)
programSession.getProfile(success: { profile in
  // profile?.first_name ..
}, error: { error in
  switch(error) {
  case GetTokenError.invalidAccessToken: // token is invalid, get a new token 
  default: // some other error happened - retry later
  }
})
```
