

# ExtoleKit

Lets you use Extole API in iOS applications

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Install XCode

```
xcode-select -switch /Applications/Xcode.app/Contents/Developer/
```

### Running the tests

ExtoleKit includes a set of integration tests, execute following to ensure your environment is healthy.
```
./runTests.sh
```

## Structure

* ExtoleSanta is a sample application
* ExtoleKit is a library that should be distributed with your application
 
### ExtoleSanta
ExtoleSanta app lets you share your Santa withlist with your friends, uses ExtoleKit library.

#### First Run
On first execution ExtoleApp fetches new access_token, and creates default shareable for anonymous profile.

AppDeletegate.swift
'''
 let iosSanta = ExtoleApp.init(programUrl: URL.init(string: "https://ios-santa.extole.com")!)

 func applicationDidBecomeActive(_ application: UIApplication) {
        iosSanta.applicationDidBecomeActive()
 }

'''



### ExtoleKit
