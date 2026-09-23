#!/bin/bash
# Quick Reference Commands for Digaxy Native Notifications Setup
# Copy-paste these commands as needed

# ============================================
# STEP 1: CLEAN & REINSTALL DEPENDENCIES
# ============================================
flutter clean
flutter pub get

# ============================================
# STEP 2: BUILD FOR TESTING
# ============================================

# Android
flutter run -d android

# iOS
flutter run -d iphone

# ============================================
# STEP 3: ANALYZE FOR ERRORS
# ============================================
flutter analyze

# ============================================
# STEP 4: VERIFY DEPENDENCIES
# ============================================
flutter pub list-outdated

# ============================================
# STEP 5: GET YOUR FCM TOKEN (for testing)
# ============================================
# Run app with: flutter run
# Watch console for: 🔔 FCM Token: xxxxx...
# Copy that token and send to backend for testing

# ============================================
# STEP 6: BUILD FOR PRODUCTION
# ============================================

# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release

# ============================================
# STEP 7: INSTALL FOR TESTING
# ============================================

# Android
flutter install

# iOS (requires Xcode configured)
# Use Xcode or via CLI:
xcrun xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath ios/build \
  -allowProvisioningUpdates

# ============================================
# ANDROID SPECIFIC
# ============================================

# Build Android-only
flutter build android

# Check Android config
cat android/app/google-services.json | head -20

# Run Gradle validation
./android/gradlew check

# Verify Android plugins
./android/gradlew app:dependencies

# ============================================
# iOS SPECIFIC
# ============================================

# Open project in Xcode
open ios/Runner.xcworkspace

# Build iOS-only
flutter build ios

# Verify iOS pods
cd ios && pod install && cd ..

# ============================================
# FIREBASE TESTING
# ============================================

# Check if firebase_core is working
dart test lib/firebase_options.dart

# Run app in verbose mode (see all logs)
flutter run -v

# View logs while app running
flutter logs

# Monitor specific platform logs
# Android:
adb logcat | grep "Digaxy"
adb logcat | grep "FCM"
adb logcat | grep "Firebase"

# iOS:
log stream --level debug --predicate 'eventMessage contains[c] "Digaxy"'

# ============================================
# DEBUGGING
# ============================================

# Hot reload (after code changes)
# Press 'r' in terminal while app running

# Hot restart (after dependency changes)
# Press 'R' in terminal while app running

# Full invalidation and rebuild
flutter clean && flutter pub get && flutter run

# Check for issues
flutter doctor

# Detailed error information
flutter run --verbose

# ============================================
# GIT OPERATIONS
# ============================================

# Check status
git status

# Add changes
git add .

# Commit
git commit -m "feat: Implement native Firebase Cloud Messaging notifications"

# Push
git push origin main

# ============================================
# USEFUL LINKS
# ============================================

# Open Firebase Console
# https://console.firebase.google.com

# Open Google Cloud Console  
# https://console.cloud.google.com

# View Flutter Docs
# https://flutter.dev/docs

# View Firebase Docs
# https://firebase.google.com/docs

# ============================================
# TROUBLESHOOTING COMMANDS
# ============================================

# Clear Dart cache
rm -rf ~/Library/Caches/dart-pub ~/.dart-tool

# Clear Flutter cache
flutter clean

# Reset to known good state
git status
flutter clean
flutter pub get
flutter analyze

# Check system info
flutter doctor -v

# Verify Java installation (Android)
java -version

# Verify Xcode (iOS)
xcodebuild -version

# ============================================
# PERFORMANCE TESTING
# ============================================

# Build with performance mode
flutter run --profile

# Build with release optimization
flutter run --release

# Check frame rate
flutter logs | grep "fps"

# ============================================
# DEVICE MANAGEMENT
# ============================================

# List available devices
flutter devices

# Launch specific device
flutter run -d <device_id>

# Uninstall app from device
flutter uninstall

# ============================================
# DOCUMENTATION READING
# ============================================

# Read main docs (in order)
cat IMPLEMENTATION_COMPLETE.md
cat WHAT_YOULL_SEE.md  
cat FIREBASE_SETUP.md

# View index of all docs
cat DOCUMENTATION_INDEX.md

# See backend examples
cat FIREBASE_MESSAGE_EXAMPLES.md

# Understand architecture
cat NOTIFICATION_ARCHITECTURE.md

# ============================================
# BACKUP & VERSION CONTROL
# ============================================

# Create branch for Firebase work
git checkout -b feature/native-notifications

# After testing, create pull request
# hub pull-request -m "Add native Firebase notifications"

# Tag version after successful deploy
git tag -a v1.0.0-notifications -m "Release native notifications"
git push origin v1.0.0-notifications

# ============================================
# PRODUCTION DEPLOYMENT
# ============================================

# Pre-deployment checks
flutter analyze
flutter test
flutter build apk --release
flutter build ios --release

# View build size
du -sh build/app/outputs/flutter-apk/app-release.apk

# Check for secrets in code
grep -r "YOUR_" lib/firebase_options.dart

# ============================================
# QUICK CHEAT SHEET
# ============================================

# Start fresh
flutter clean && flutter pub get

# Code check
flutter analyze

# Run app
flutter run

# View logs
flutter logs

# Stop app
# Press 'q' in terminal

# Full rebuild
flutter clean && flutter pub get && flutter run

# Production build
flutter build apk --release && flutter build ios --release

# ============================================
# NOTES:
# ============================================
# 1. Replace <device_id> with actual device ID from: flutter devices
# 2. iOS commands may need Xcode configured (see FIREBASE_SETUP.md)
# 3. Android commands need gradle installed
# 4. Always run: flutter clean && flutter pub get after major changes
# 5. For production, use --release flag for builds
# 6. Check console output for 🔔 FCM Token when testing
# ============================================
