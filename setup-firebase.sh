#!/bin/bash
# Firebase Setup Automation Script
# Run this after downloading Firebase config files

echo "🔥 Digaxy Firebase Setup Script"
echo "================================"
echo ""

# Check if google-services.json exists
if [ -f "android/app/google-services.json" ]; then
    echo "✅ android/app/google-services.json found"
else
    echo "❌ android/app/google-services.json NOT found"
    echo "   Get it from Firebase Console > Project Settings > google-services.json"
fi

# Check if firebase_options.dart has been updated
if grep -q "YOUR_" lib/firebase_options.dart; then
    echo "❌ lib/firebase_options.dart still has placeholder values"
    echo "   Replace all YOUR_* values with your Firebase project credentials"
else
    echo "✅ lib/firebase_options.dart appears to be configured"
fi

# Note about iOS file
echo "⚠️  iOS configuration must be done manually:"
echo "   1. Download GoogleService-Info.plist from Firebase Console"
echo "   2. Open ios/Runner.xcworkspace in Xcode"
echo "   3. Drag GoogleService-Info.plist to Runner folder"
echo "   4. Ensure it's added to Runner target"

echo ""
echo "📝 Next steps:"
echo "   1. flutter clean"
echo "   2. flutter pub get"
echo "   3. flutter run -d <device_id>"

echo ""
echo "🧪 Test via Firebase Console:"
echo "   1. Firebase Console > Cloud Messaging"
echo "   2. Send Test Message"
echo "   3. Select your device"
echo "   4. Enter title/body"
echo "   5. Click Send"
echo "   ✓ Notification should appear on device"
