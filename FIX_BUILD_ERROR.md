# Fix iOS Build Error - PhaseScriptExecution

## Steps to Fix the Build Error

Run these commands in your terminal from the project root:

### 1. Clean Flutter build
```bash
flutter clean
```

### 2. Get Flutter dependencies
```bash
flutter pub get
```

### 3. Clean and reinstall CocoaPods
```bash
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install
cd ..
```

### 4. Clean Xcode build folder (if using Xcode)
- Open Xcode
- Go to Product → Clean Build Folder (Shift + Cmd + K)
- Or run: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### 5. Rebuild the project
```bash
flutter build ios
```

## What Was Fixed

1. **iOS Platform Version**: Changed from invalid `26.2` to `15.0` (latest modern version) in:
   - `ios/Podfile` - platform version and deployment target
   - `ios/Runner.xcodeproj/project.pbxproj` - all build configurations
2. **Material Icons**: Added `uses-material-design: true` to `pubspec.yaml`
3. **Icon Names**: Fixed all outlined icon names (removed trailing 'd')

## If Issues Persist

If you still get errors, try:
```bash
# Update CocoaPods
sudo gem install cocoapods
pod repo update

# Clear Flutter cache
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
```
