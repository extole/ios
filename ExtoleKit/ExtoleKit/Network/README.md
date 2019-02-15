# ExtoleKit REST API inegration

Most operations are exposed by ProgramSession.

## Create ProgramSession

```swift
let program = Program(baseUrl: URL.init(string: "https://ios-santa.extole.io")!)
var programSession : ProgramSession?

program.getToken(success: { token in
  // save token for later
  programSession = ProgramSession.init(program: program, token: token!)
}, error: { error in
  // retry later
})

```
## Verify ConsumerToken
You should verify saved access_token before it's used

```swift
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
programSession.getProfile(success: { profile in
  // profile?.first_name ..
}, error: { error in
  switch(error) {
  case GetProfileError.invalidAccessToken: // token is invalid, get a new token 
  default: // some other error happened - retry later
  }
})
```

## Update Profile
```swift
let myProfile = MyProfile(email: "testprofile@extole.com",
                                  partner_user_id: "Zorro",
                                  first_name: "Test",
                                  last_name: "Profile")
programSession.updateProfile(profile: myProfile, success: {
}, error: { error in
  switch(error) {
  case UpdateProfileError.invalidAccessToken: // token is invalid, get a new token 
  default: // some other error happened - retry later
  }
}
```
