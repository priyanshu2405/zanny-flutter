#!/usr/bin/env bash
# One-time setup: creates android/ and ios/ and adds the permissions the app needs.
set -e
flutter create --project-name zany_pottery --org ca.zanypottery --platforms android,ios .
flutter pub get

MANIFEST=android/app/src/main/AndroidManifest.xml
if ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
  perl -0pi -e 's#<manifest([^>]*)>#<manifest$1>\n    <uses-permission android:name="android.permission.INTERNET"/>\n    <uses-permission android:name="android.permission.CAMERA"/>\n    <queries>\n        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>\n        <intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>\n        <intent><action android:name="android.intent.action.SENDTO"/><data android:scheme="mailto"/></intent>\n    </queries>#' "$MANIFEST"
fi

PLIST=ios/Runner/Info.plist
if ! grep -q "NSCameraUsageDescription" "$PLIST"; then
  perl -0pi -e 's#<dict>#<dict>\n\t<key>NSCameraUsageDescription</key>\n\t<string>Take photos of your finished pieces.</string>\n\t<key>NSPhotoLibraryUsageDescription</key>\n\t<string>Upload photos of your finished pieces.</string>\n\t<key>LSApplicationQueriesSchemes</key>\n\t<array><string>tel</string><string>mailto</string><string>https</string></array>#' "$PLIST"
fi

echo "Setup complete. Run: flutter run"
