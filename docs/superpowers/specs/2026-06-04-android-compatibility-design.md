# Design Spec: Android 7.1 Nougat (API Level 22/25) Compatibility

## Overview
Modify the minimum SDK configuration in the Android app package to support Android 7.1 Nougat tablets. While the target device reports running Android 7.1 (API 25) in its UI, it reports API Level 22 (Android 5.1 Lollipop) programmatically. To ensure complete compatibility and allow successful installation/execution on this target device, the application's `minSdkVersion` will be lowered to `21` (Android 5.0 Lollipop).

## Architecture & Configuration Changes

### 1. `android/app/build.gradle.kts`
Modify the `defaultConfig` block to explicitly set the `minSdk` version:
- **Change**: Change `minSdk = flutter.minSdkVersion` to `minSdk = 21`.
- **Reason**: API 21 is the standard Flutter minimum support level for Android, which comfortably covers the API 22 signature reported by the target device.

## Verification & Testing Plan
1. **Compilation Check**: Verify that the application builds successfully with the updated `minSdk` configuration by running `flutter build apk --debug`.
2. **Device Deployment**: Run/install the resulting package on the target device (reports API 22 / Android 5.1).
