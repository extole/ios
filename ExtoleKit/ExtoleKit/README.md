# ExtoleKit

ExtoleKit is written in Swift, key abstractions are also available for Objective-C applications.

* Rest - Low level API, maps Extole Rest API
* App - High level API
* Log - implements logging


## ExtoleKit High Level API

## ExtoleKit REST

### Overview
To use Extole Rest you need :
 * ProgramURL - where Extole Rest API is hosted, "https://__YOUR_DOMAIN__.extole.io"
 * Label - refer-a-friend, or other name that describes your program
 * ConsumerSession - Represents series of person interactions with Extole API, encapsulates access_token

With ConsumerSession initialized - you can call Extole Rest API.

### Session management

#### Create ConsumerSession

You will need to create new ConsumerSession, before calling any other Extole API.
Typically you will save ConsumerSession in application private storage,
so it can be resumed in subsequent application runs.

```swift
let program = ProgramURL(baseUrl: URL.init(string: "https://ios-santa.extole.io")!)
var consumerSession : ConsumerSession?

program.getToken(success: { token in
  // save token for later
  consumerSession = ConsumerSession.init(program: program, token: token)
}, error: { error in
  // running offline ?
})
```

#### Resume ConsumerSession
It's possible that ConsumerSession is expired, so you should validate it on application startup.

```swift
let savedToken = __READ_TOKEN_FROM_PRIVATE_STORAGE__
// 
let consumerToken = ConsumerToken.init(access_token: savedToken)
let consumerSession = ConsumerSession.init(program: program, token: consumerToken)

consumerSession.getToken(success: { token in
  // token is valid, it's safe to use consumerSession
}, error: { verifyTokenError in
  // token is not valid, possibly session has expired, see verifyTokenError.code
})

```

#### Invalidate ConsumerSession

```swift
let consumerSession = ...
programSession.deleteToken(success: {
      // token is removed from Extole API
      // you will need to create a new ConsumerSession
  }, error: { error in
      // delete failed , offline ?
})

```

### Profile

#### Get Profile

```swift
consumerSession.getProfile(success: { profile in
  // profile.first_name ..
}, error: { error in
  //
})
```

#### Update Profile
```swift
let myProfile = MyProfile(email: "testprofile@extole.com",
                                  partner_user_id: "Zorro",
                                  first_name: "Test",
                                  last_name: "Profile")
programSession.updateProfile(profile: myProfile, success: {
}, error: { error in
  // 
}
```
