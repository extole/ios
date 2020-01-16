set -e

xcodebuild -workspace Workspace.xcworkspace -scheme ExtoleKit CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO -destination generic/platform=iOS clean build

xcodebuild -sdk iphonesimulator -workspace Workspace.xcworkspace -scheme ExtoleSanta CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO -destination generic/platform=iOS  clean build

xcodebuild -sdk iphonesimulator -workspace Workspace.xcworkspace -scheme SantaPostbox CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO -destination generic/platform=iOS  clean build

xcodebuild -sdk iphonesimulator -workspace Workspace.xcworkspace -scheme ExtoleKit CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO -destination 'platform=iOS Simulator,name=iPhone 8'  test
