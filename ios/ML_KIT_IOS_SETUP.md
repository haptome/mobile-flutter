# ML Kit Face Detection - iOS Setup

## Changes Made to Podfile

The iOS Podfile has been updated to support Google ML Kit Face Detection. The following changes were made:

### 1. Updated iOS Platform Version
- **Changed from:** `platform :ios, '13.0'`
- **Changed to:** `platform :ios, '15.5'`
- **Reason:** ML Kit Face Detection requires iOS 15.5 or newer

### 2. Added iOS Version Variable
```ruby
$iOSVersion = '15.5'
```
This variable is used to ensure all pods meet the minimum deployment target.

### 3. Updated post_install Hook
Added ML Kit-specific configuration to exclude 32-bit architectures and enforce minimum deployment target:

```ruby
post_install do |installer|
  # ML Kit Face Detection configuration
  installer.pods_project.build_configurations.each do |config|
    # Exclude 32-bit architectures (armv7) as ML Kit only supports 64-bit
    config.build_settings["EXCLUDED_ARCHS[sdk=*]"] = "armv7"
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iOSVersion
  end
  
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # Ensure all pods meet minimum iOS deployment target
    target.build_configurations.each do |config|
      if Gem::Version.new($iOSVersion) > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iOSVersion
      end
    end
  end
end
```

## Next Steps

### 1. Run Pod Install
Navigate to the iOS directory and run pod install:
```bash
cd mobile-flutter/ios
pod install
```

### 2. Update Xcode Project Settings (Manual Step Required)
Open the project in Xcode and exclude armv7 architecture:

1. Open `mobile-flutter/ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** project in the Project Navigator
3. Select the **Runner** target
4. Go to **Build Settings** tab
5. Search for "Excluded Architectures"
6. Under **Excluded Architectures** → **Any iOS SDK**, add: `armv7`

### 3. Verify Deployment Target
Ensure the deployment target is set correctly:

1. In Xcode, select the **Runner** project
2. Select the **Runner** target
3. Go to **General** tab
4. Under **Deployment Info**, verify **iOS Deployment Target** is set to **15.5** or higher

## Important Notes

### Architecture Support
- ✅ ML Kit supports 64-bit architectures: `x86_64` (simulator) and `arm64` (device)
- ❌ ML Kit does NOT support 32-bit architectures: `i386` and `armv7`
- This means the app will only run on 64-bit iOS devices (iPhone 5s and newer)

### Minimum Requirements
- **iOS Version:** 15.5 or newer
- **Xcode:** 15.3.0 or newer
- **Swift:** 5.0 or newer
- **Device:** 64-bit iOS devices only

### Camera Permissions
The Info.plist already includes the required camera usage description:
```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to capture ID documents with auto-detection and perform face liveness verification for KYC.</string>
```

## Troubleshooting

### Build Errors Related to Architecture
If you encounter build errors about unsupported architectures:
1. Clean the build folder: **Product** → **Clean Build Folder** (Cmd+Shift+K)
2. Delete the `Pods` folder and `Podfile.lock`
3. Run `pod install` again
4. Verify armv7 is excluded in Xcode Build Settings

### Deployment Target Warnings
If you see warnings about deployment target:
1. Ensure all pods have deployment target ≥ 15.5
2. The post_install hook should handle this automatically
3. If issues persist, manually update the deployment target in Xcode

### Pod Install Fails
If pod install fails with dependency conflicts:
1. Update CocoaPods: `sudo gem install cocoapods`
2. Update pod repo: `pod repo update`
3. Try again: `pod install`

## References

- [ML Kit Face Detection for iOS](https://developers.google.com/ml-kit/vision/face-detection/ios)
- [google_mlkit_face_detection Flutter Package](https://pub.dev/packages/google_mlkit_face_detection)
- [ML Kit iOS Requirements](https://developers.google.com/ml-kit/migration/ios)

## Related Files

- `mobile-flutter/ios/Podfile` - Updated with ML Kit configuration
- `mobile-flutter/ios/Runner/Info.plist` - Contains camera permissions
- `mobile-flutter/pubspec.yaml` - Contains `google_mlkit_face_detection: ^0.10.0` dependency
