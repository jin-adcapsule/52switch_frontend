***

**52Switch: Attendance and Day-Off Management Application**

***
**52Switch** is a comprehensive attendance and day-off management application designed to streamline employee attendance tracking and day-off requests/approvals.<br>The project is built using **Flutter** for the frontend, **Spring Boot** with **GraphQL** for the backend, and **MongoDB** as the database.

[52SWITCH Project Documentation KR](https://gilded-brush-9bc.notion.site/52SWITCH-2025-01-09-151fbe5a819680628769e0db7e4aace6?pvs=4)

## Basic Features
- **Day-Off Requests:** Employees can request day-off directly from the app.
- **Supervisor Panel:** Manage approve/reject day-off requests from supervisee.
- **User-Friendly Interface:** Mobile-friendly interface with customizable themes.
- **Secure Authentication:** Multi step phone number-based login system.<br>1. deviced stored token<br>2. device phone number authentication<br>3. db stored token and phone number

## Enhancement beyond current Application
- **Holiday:** Calendar now disables holidays.
- **Background Notification:** Notification now activated also in background both for IOS and Android.
- **Work Start Toggle Nofification:** each employee's work start time is computed by location / day off (half) / holiday. Toggle Notification is sent to each employee.    

***

**52Switch Client Application**

***

## Prerequisites
- **Frontend**: Flutter, Dart LTS
- **Authentication**: Firebase Authentication, Secured Storage
- **Notification**: Firebase Cloud Messaging(FCM), Local Notification Service

## CI/CD Artifact
Every push or pull trigger automated build in Github Action<br>
The generated artifacts (APK for Android or APP for iOS) are available in artifact section.

## Local Setup Instructions
### Step 1. Configure required parameters and file:
   (contact the project owner for target os google key, host server address)<br>
   Ensure these files are placed in the correct directories (contact the project owner if unsure):
   1. **Android:**
   ```bash
   $root/android/app/google-services.json 
   ``` 
   2. **IOS:**
   ```bash
   $root/ios/Runner/GoogleService-Info.plist
   ```  
   3. **(optional)Firebase:**  
   Own firebase option is to be generated using Firebase CLI
   ```bash
   $root/lib/firebase_options.dart
   ```
### Step 2. Run flutter on simulator:  
   Before running the Flutter app, ensure simulator or phone available.:
   ```bash
   flutter run --debug --dart-define=HOST_ADDRESS={{hostaddress}} --dart-define=SERVER_PORT={{serverport}} 
   ```

For further assistance or refinements, feel free to reach out:

**Contact:**  
Chaejin Lim  
📧 [jin.chaejin.lim@adcapsule.co.kr](mailto:jin.chaejin.lim@adcapsule.co.kr)