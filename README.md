# HireMe

A Flutter-based recruitment platform connecting job seekers with companies.

## Overview

HireMe is a cross-platform mobile application that streamlines the hiring process for both job seekers and employers. Built with Flutter and leveraging Firebase and Supabase for backend services, the app supports dual-role authentication, real-time chat, job posting, and application management. It uses GetX for state management and follows a modular feature-first architecture.

## Features

### Job Seekers
- Browse and search job listings
- View detailed job descriptions
- Apply to jobs with resume/CV upload
- Save jobs for later review
- Track application status
- Chat with companies
- Manage profile and main fields

### Companies
- Post new job listings
- View and manage received applications
- Review individual applications
- Dashboard with analytics
- Chat with job seekers
- Manage company profile

### Auth & Onboarding
- Splash screen
- Onboarding flow
- Role selection (Job Seeker / Company)
- Login, registration, and password recovery

## Tech Stack

- **Framework:** Flutter (SDK ^3.11.0)
- **State Management:** GetX
- **Backend:** Firebase (Auth, Firestore, Storage, Realtime Database) + Supabase
- **Architecture:** Modular feature-first with GetX bindings, controllers, and views

## Folder Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   ├── core/
│   │   ├── helper/
│   │   └── utils/
│   ├── data/
│   ├── middleware/
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── forgot_password/
│   │   │   ├── login/
│   │   │   ├── onboarding/
│   │   │   ├── register/
│   │   │   ├── role_selector/
│   │   │   ├── select_user/
│   │   │   └── splash/
│   │   ├── company/
│   │   │   ├── application_list/
│   │   │   ├── application_review/
│   │   │   ├── company_chat/
│   │   │   ├── company_chat_details/
│   │   │   ├── company_main_wrapper/
│   │   │   ├── company_profile/
│   │   │   ├── dashboard/
│   │   │   └── post_job/
│   │   ├── job_seeker/
│   │   │   ├── apply_job/
│   │   │   ├── chat/
│   │   │   ├── chat_details/
│   │   │   ├── dashboard/
│   │   │   ├── job_details/
│   │   │   ├── Jobseekercongratulations/
│   │   │   ├── main_fields/
│   │   │   ├── my_applications/
│   │   │   └── saved_jobs/
│   │   ├── main_wrapper/
│   │   └── profile/
│   ├── routes/
│   └── services/
└── core/
    ├── models/
    ├── utils/
    └── widgets/
```

## Setup Instructions

### Prerequisites

- Flutter SDK ^3.11.0
- Dart SDK ^3.11.0
- Android Studio / VS Code with Flutter extensions
- Firebase project configured
- Supabase project configured

### Step 1: Clone the repository

```bash
git clone <repository-url>
cd hire_me
```

### Step 2: Install dependencies

```bash
flutter pub get
```

### Step 3: Configure Firebase

1. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Run the FlutterFire configuration:
   ```bash
   flutterfire configure --project=<your-firebase-project-id>
   ```

   This generates `lib/firebase_options.dart` with platform-specific Firebase config.

3. Enable the following Firebase services in your Firebase Console:
   - **Firebase Authentication** (email/password, etc.)
   - **Cloud Firestore**
   - **Firebase Storage**
   - **Firebase Realtime Database**

4. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in their respective platform directories.

### Step 4: Configure Supabase

Create a `.env` file in the project root with your Supabase credentials:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Step 5: Run the app

```bash
flutter run
```

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| get | ^4.7.3 | State management, routing, dependency injection |
| firebase_core | ^4.5.0 | Firebase initialization |
| firebase_auth | ^6.1.4 | User authentication |
| cloud_firestore | ^6.1.2 | NoSQL cloud database |
| firebase_storage | ^13.2.0 | Cloud file storage |
| firebase_database | ^12.3.0 | Realtime database |
| supabase_flutter | ^2.12.4 | Supabase backend integration |
| flutter_dotenv | ^6.0.1 | Environment variable management |
| flutter_native_splash | ^2.4.7 | Native splash screen configuration |
| email_otp | ^3.1.0 | Email OTP verification |
| file_picker | ^8.1.7 | File selection (CV/resume uploads) |
| image_picker | ^1.2.2 | Image selection from gallery/camera |
| rxdart | ^0.28.0 | Reactive programming utilities |
| shared_preferences | ^2.5.3 | Local key-value storage |
| url_launcher | ^6.3.2 | Opening URLs externally |
| flutter_svg | ^2.0.10 | SVG rendering |
| cupertino_icons | ^1.0.8 | iOS-style icons |
