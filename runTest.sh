xcodebuild -sdk iphonesimulator -scheme firstappTests CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO -destination 'platform=iOS Simulator,name=iPhone SE'  test | xcpretty 
