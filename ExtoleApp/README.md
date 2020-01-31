# ExtoleApp

High Level API for Extole advocate experience.


## Build / Test

swift package generate-xcodeproj
xcodebuild build -sdk iphoneos -scheme 'ExtoleApp-Package'
xcodebuild test -destination 'name=iPhone 8' -scheme 'ExtoleApp-Package'
