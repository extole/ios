# ExtoleKit

ExtoleKit is written in Swift, key abstractions are also available for Objective-C applications.

* Rest - Low level API, maps Extole Rest API
* App - High level API
* Log - implements logging


## ExtoleKit High Level API

### Notify Extole that share happened in application

```swift
let shareApp = SimpleShareExperince(
  programUrl: URL.init(string: "https://ios-santa.extole.io")!,
  programLabel: "refer-a-friend")

let customShare = CustomShare(channel: "sms")
shareApp.notify(share: customShare)
```
### Send Email Share via Extole

```swift
let shareApp = SimpleShareExperince(
  programUrl: URL.init(string: "https://ios-santa.extole.io")!,
  programLabel: "refer-a-friend")

let share = EmailShare(recipient_email: email, message: "Check this out")
shareApp.send(share: customShare)
```

### Load JSON from Extole zone request

```swift
let shareApp = SimpleShareExperince(
  programUrl: URL.init(string: "https://ios-santa.extole.io")!,
  programLabel: "refer-a-friend")

shareApp.fetchObject(zone: "settings", success: { (settings: Settings) in
             // use settings
    }, error: { (error) in
   // handle error 
    })
```

### Signal zone event

```swift
let shareApp = SimpleShareExperince(
  programUrl: URL.init(string: "https://ios-santa.extole.io")!,
  programLabel: "refer-a-friend")
let parameters : [URLQueryItem] = [
    URLQueryItem(name: "cart_value", value: "12.31")
]
shareApp.signal(zone: "conversion", parameters: parameters)

```

## ExtoleKit REST ( Low Level )

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
consunmerSession.deleteToken(success: {
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
let myProfile = MyProfile(
    email: "testprofile@extole.com",
    partner_user_id: "Zorro",
    first_name: "Test",
    last_name: "Profile")
consumerSession.updateProfile(profile: myProfile, success: {
  // ok
}, error: { error in
  // see error.code
}
```

### Shareable

#### Create Shareable

```swift
let newShareable = MyShareable.init(label: "refer-a-friend")
        
consumerSession.createShareable(shareable: newShareable, success: { shareableResult in
  // shareableResult.polling_id
  }, error: { error in
  // see error.code
})
```
#### Get Shareables

```swift
consumerSession.getShareables(success: { result in
  // result.first?.label
  }, error:  { error in
  // see error.code
})

```

### Share
#### Create Custom Share

```swift
let advocateCode = __SHAREABLE_CODE__
let customShare = CustomShare(advocate_code: advocateCode,
    channel: "sms",
    message: "check this out",
    recipient_email: "friend@extole.com",
    data: [:])
        
consumerSession.customShare(share: customShare, success: { shareResponse in
  // shareResponse.polling_id
  }, error: { error in
  // check error.code
})
```
### Zone

Zone shall return JSON data

#### Fetch Zone

```swift
struct SettingsSchema : Codable {
    let shareMessage: String 
}

consumerSession.fetchObject(zone: "settings",
  success: { (settings: SettingsSchema) in
    // settings.shareMessage
  }, error: { error in
    // see error.code
})

```

### Custom Network

You can define custom network, to add logging, custom HTTP headers etc.

```swift
class CustomExecutor : NetworkExecutor {
  func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
      var newRequest = request
      newRequest.addValue("customValue", forHTTPHeaderField: "X-My-Header")
      let urlSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
      let task = urlSession.dataTask(with: newRequest, completionHandler: completionHandler)
      task.resume()
  }
}

let network = Network(executor: CustomExecutor())

let program = ProgramURL(baseUrl: URL.init(string: "https://virtual.extole.io")!,
    network: network)

// program.getToken...
```
