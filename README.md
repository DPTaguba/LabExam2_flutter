# Food List

## Objective

A single-page Flutter food/task list that follows the supplied reference: a compact title bar, an add-task field and button, and simple rows with edit and delete actions. Tasks are stored in Firebase Cloud Firestore and update live in the list.

## Firebase setup

The app initializes Firebase with the generated platform options in `lib/firebase_options.dart`. The Android app also uses `android/app/google-services.json` through the Google Services Gradle plugin.

1. In Firebase Console, create or select the `labexam2-c6b61` project and create a Cloud Firestore database.
2. Confirm the Android app package name matches `com.example.flutter_labexam_taguba` and that the app's `google-services.json` belongs to that Firebase project.
3. Configure Firestore security rules for the intended users. The app has no sign-in flow, so the default authenticated-only rules will reject its requests. For a class demo only, temporary open rules can be used; never use open read/write rules for a production database.
4. Run `flutter pub get`, then `flutter run` on an Android or iOS device/emulator.

## Firestore structure

Collection: `tasks`

Each document contains:

| Field | Type | Purpose |
| --- | --- | --- |
| `title` | String | Food or task text shown in the list |
| `createdAt` | Timestamp | Server creation time; newest items appear first |

## CRUD behavior

- **Create:** Enter a non-empty task and press `+` (or submit from the keyboard). The app trims whitespace and writes a document.
- **Read:** A Firestore snapshot stream displays all tasks and applies database changes automatically.
- **Update:** Tap the pencil, change the text, and save. Empty edits are rejected.
- **Delete:** Tap the trash icon to remove that document.
- Firestore errors appear in a message or in the task-list error state.

## Screenshots

The supplied reference image is the visual target: pale background, teal add button, compact white task rows, and muted edit/red delete icons. Capture a screenshot from the running app and include it here when preparing the final submission.

## Code organization

`lib/main.dart` contains Firebase initialization, the Firestore repository, and the single-page UI. `test/widget_test.dart` uses an in-memory repository to cover validation and each CRUD action without depending on a Firebase connection.
