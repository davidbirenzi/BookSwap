# Fix Firebase Configuration Error

## Quick Setup (5 minutes)

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Create New Project**: Click "Add project" → Enter "BookSwap" → Continue
3. **Enable Authentication**: 
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"
4. **Enable Firestore**: 
   - Go to Firestore Database → Create database → Start in test mode
5. **Enable Storage**: 
   - Go to Storage → Get started → Start in test mode

## Android Setup
1. **Add Android App**: 
   - Click "Add app" → Android icon
   - Package name: `com.example.book_swap_app`
   - Download `google-services.json`
2. **Replace File**: 
   - Replace `android/app/google-services.json` with downloaded file

## Update Firebase Options
Replace `lib/firebase_options.dart` with the config from Firebase console:
- Go to Project Settings → General → Your apps → Firebase SDK snippet → Config

## Test
Run `flutter run` - signup should work without errors.