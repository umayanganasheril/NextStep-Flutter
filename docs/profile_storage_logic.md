# Profile Storage Logic Documentation

## Overview
The Profile feature uses **Firebase Storage** for avatar management and **Firestore** for user metadata synchronization.

## Architecture
1. **StorageService**: Handles raw file uploads to the `profiles/` bucket.
   - `uploadProfileImage(uid, file)`: Uploads a JPG image named after the user's UID. Returns the public download URL.
   - `deleteProfileImage(uid)`: Removes the user's avatar from storage.

2. **UserService**: Manages real-time data synchronization.
   - `getUserProfileStream(uid)`: Returns a stream of `UserModel` objects from Firestore.
   - `saveUserProfile(model)`: Performs a merge-set on the user's document.

## Data Flow
1. User picks an image via `ImagePicker`.
2. `StorageService` uploads the file and retrieves a URL.
3. The URL is bundled with other profile fields (name, bio) and sent to `UserService`.
4. Firestore updates trigger the `StreamBuilder` in `ProfileEditScreen`, causing a real-time UI refresh.

## Optimization
- **Offline Support**: Firestore's internal caching ensures profile data is visible even without a network connection.
- **Lazy Initialization**: Text controllers in `ProfileEditScreen` are initialized once from the stream to prevent cursor jitter during typing.
