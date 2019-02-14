/usr/libexec/PlistBuddy -c "Set gitRevision $(git rev-parse --short HEAD)" ExtoleKit/Info.plist

agvtool vers -ters

agvtool bump  -increment-minor-version

agvtool new-version X.Y.Z

agvtool new-marketing-version X.Y.Z
