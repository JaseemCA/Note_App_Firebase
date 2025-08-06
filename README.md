# Personal Notes App - Flutter & Firebase

## Overview

A simple **Personal Notes App** built using **Flutter** and **Firebase**. Users can:

* Register & Login using Firebase Authentication.
* Create, Update, Delete Notes (Title, Content, Timestamps).
* Each user's data is isolated & secure.

---
 a) Initialize Firebase in Project

```bash
firebase init
```

* Select: Firestore, Authentication, Storage.
* Use default settings (firestore.rules, storage.rules).
* This creates: `firebase.json`, `.firebaserc`, `firestore.rules`, `storage.rules`.

 b) Configure FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-project-id>
```

* Select platforms: Android, iOS, Web, Windows.
* This generates: `lib/firebase_options.dart`

---

 🔑 Firebase Console Configuration

1. Enable Authentication

* Go to **Firebase Console > Authentication > Sign-in method**.
* Enable **Email/Password**.

 2. Enable Firestore Database

* Firebase Console > Firestore Database > Create Database**.
* Select **Start in Test Mode** (For Dev).
* Location: (Choose closest region).

---

 📂 Project Structure

```
lib/
 ├── firebase_options.dart
 ├── services/
 │     ├── auth_service.dart
 │     └── firestore_services.dart
 ├── screens/
 │     ├── login_screen.dart
 │     ├── register_screen.dart
 │     ├── notes_list.dart
 │     └── note_editor.dart
 │     └── splash_screen.dart 
 └── main.dart
```

---

 Features Implemented

* [x] Firebase Authentication (Email/Password)
* [x] Firestore Integration (CRUD Notes)
* [x] User-specific Firestore Data Structure: `/users/{userId}/notes/{noteId}`
* [x] Timestamps for Created & Updated


 Useful Links

* [Firebase Docs](https://firebase.google.com/docs)
* [FlutterFire Docs](https://firebase.flutter.dev/docs/overview)

---
Developed by

JASEEM CA


