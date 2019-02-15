

# Extole iOS SDK

Lets you use Extole API in iOS applications

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Install XCode

```
$ xcode-select -switch /Applications/Xcode.app/Contents/Developer/
```

### Running the tests

ExtoleKit includes a set of integration tests, execute following to ensure your environment is healthy.
```
$ ./runTests.sh
```

## Structure

* ExtoleSanta is a sample application
* ExtoleKit is a library that should be distributed with your application
 
### ExtoleSanta
ExtoleSanta app lets you share your Santa withlist with your friends, uses ExtoleKit library.

#### Startup
On first execution ExtoleSanta fetches new access_token, and creates default shareable for anonymous profile.
ExtoleSanta saves access_token and re-uses it for subsequent runs.

```swift
 // AppDeletegate.swift
 let iosSanta = ExtoleSanta.init(programUrl: URL.init(string: "https://ios-santa.extole.com")!)

 func applicationDidBecomeActive(_ application: UIApplication) {
        iosSanta.applicationDidBecomeActive()
 }
```
Control is then passed to HomeViewController that displays:
* Current Session State ( Anonymous, Identified, LoggedOut, Error )
* Share Action Button
* Persons Identity ( Email )
* Profile Information ( FirstName, LastName )
* Share Message
* Share Link

#### Share Action

Share action is available when ExtoleSanta goes to ReadyToShare state.
ReadyToShare means that access_token is valid, and shareable is present.
```swift
// HomeViewController.swift
class HomeViewController : ExtoleSantaStateListener { // implements ExtoleSantaStateListener

  override viewDidLoad() {
     extoleApp.stateListener = self 
  }

  func onStateChanged(state: ExtoleSanta.State) {
    switch state {
      case .ReadyToShare : // show share action button, calls doShare when clicked
      case default : // hide share action button
    }
  }

  func doShare() {
        // read share link and message of shareable
        guard let shareLink = extoleApp.selectedShareable?.link else {
            self.showError(message: "No Shareable")
            return
        }
        guard let message = extoleApp.shareMessage else {
            return
        }
        // display iOS share dialog using UIActivityViewController
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        present(activityViewController,..)

        // notify Extole share happened
        activityViewController.completionWithItemsHandler =  {(activityType : UIActivity.ActivityType?, completed : Bool, returnedItems: [Any]?, activityError : Error?) in
            if let completedActivity = activityType, completed {
                self.extoleApp.signalShare(channel: completedActivity.rawValue)
            }
        }
  }

}
```

#### Identify
It is possible to share without setting identity, but in that case Santa wont give you presents.
When user clicks on empty email details - control is passed to IdentifyViewController.

```swift
// IdentifyViewController.swift

// event handler for Done button
func editDone() {
  // send email to Extole
  extoleApp.identify(email: emailText.text)
}
```

#### Logout and New Session
Normaly we want to keep access_token across application runs, but in case user wants to Logout:

```swift
// HomeViewController.swift
func logoutClick() {
  // this will delete access_token in application and in Extole
  // state will change to LoggedOut
  extoleApp.logout()
}

func newSessionClick() {
  // this will fetch new access_token, creating anonymous Profile
  extoleApp.newSession()
}
```

#### Workflow customizations

ExtoleSanta.swift - defines application level logic;
for example to save/restore access_token at startup:

```swift
var savedToken : String? {
    get {
        return settings.string(forKey: "extole.access_token")
    }
    set(newSavedToken) {
        settings.set(newSavedToken, forKey: "extole.access_token")
    }
}
func applicationDidBecomeActive() {
    if let existingToken = self.savedToken {
        self.sessionManager.activate(existingToken: existingToken)
    } else {
        self.sessionManager.newSession()
    }
}
```

### ExtoleKit

[[Details|ExtoleKit/Readme.md]]

* [Network](ExtoleKit/ExtoleKit/Network/README.md) - functions to work with REST API
* Token, Profile, Program, Share, Shareable, Zone - Extole data types
* Log - implements logging
* SessionManager, ProfileManager, ShareableManager, ContentManager - high level ExtoleAPIs
