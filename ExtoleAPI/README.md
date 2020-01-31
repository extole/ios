# ExtoleAPI

Low level Extole consumer API mappings.

## Build / Test

swift package generate-xcodeproj
xcodebuild build -sdk iphoneos -scheme 'ExtoleAPI-Package'
xcodebuild test -destination 'name=iPhone 8' -scheme 'ExtoleAPI-Package'

