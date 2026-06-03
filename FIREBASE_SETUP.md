# Firebase Setup Guide
> Follow these steps to get ConstructFlow connected to Firebase.

## Step 1: Create a Firebase Project

1. Go to https://console.firebase.google.com/
2. Click "Create a project"
3. Name it **"ConstructFlow"** (or whatever you prefer)
4. Google Analytics: **Enable it** (free, helps with usage insights)
5. Select your country/region
6. Click "Create project"

## Step 2: Enable Authentication

1. In the Firebase console, go to **Authentication** (left sidebar)
2. Click "Get started"
3. Under "Sign-in method", enable **Phone**
4. Add your phone number for testing
5. Click "Save"

## Step 3: Create Firestore Database

1. In the Firebase console, go to **Firestore Database** (left sidebar)
2. Click "Create database"
3. Select **Start in test mode** (we'll lock it down later)
4. Choose a region close to you (e.g., `us-central`)
5. Click "Enable"

## Step 4: Add Android App

1. In the Firebase console, click the **Android icon** (</>) to add an app
2. Package name: `com.constructflow.app`
3. App nickname: `ConstructFlow Android`
4. Debug signing certificate SHA-1: (optional for now, add later for release)
5. Click "Register app"
6. Download the `google-services.json` file
7. Place it at: `android/app/google-services.json`
8. Click "Next" through the remaining steps

## Step 5: Add iOS App

1. In the Firebase console, click the **iOS icon** to add an app
2. Bundle ID: `com.constructflow.app`
3. App nickname: `ConstructFlow iOS`
4. App Store ID: (optional, leave blank for now)
5. Click "Register app"
6. Download the `GoogleService-Info.plist` file
7. Place it at: `ios/Runner/GoogleService-Info.plist`
8. Click "Next" through the remaining steps

## Step 6: Run Drift Code Generation

Once the config files are in place, run:

```bash
cd ~/Documents/ConstructFlow
dart run build_runner build
```

This generates the database code from our Drift schema.

## Step 7: Install Dependencies

```bash
cd ~/Documents/ConstructFlow
flutter pub get
```

## Step 8: Run the App

```bash
# For iOS Simulator
flutter run

# For Android Emulator
flutter run

# For web (limited functionality — no voice/camera)
flutter run -d chrome
```

## Firestore Security Rules (Important!)

Once everything is working, go to Firestore → Rules and replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Projects: only crew members can access
    match /projects/{projectId} {
      allow read, write: if request.auth != null;
      // TODO: Add proper crew membership check
    }

    // Subcollections inherit project access
    match /projects/{projectId}/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Troubleshooting

- **"Firebase not initialized"**: Make sure `google-services.json` / `GoogleService-Info.plist` are in the right place
- **"Drift code not generated"**: Run `dart run build_runner build --delete-conflicting-outputs`
- **"Package not found"**: Run `flutter pub get`
- **Phone auth not working**: Make sure you added your phone number in the Firebase console test numbers
