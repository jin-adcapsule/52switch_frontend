# 52Switch: Attendance and Day-Off Management Application

**52Switch** is a comprehensive attendance and day-off management application designed to streamline employee attendance tracking and day-off requests/approvals. The project is built using **Flutter** for the frontend, **Spring Boot** with **GraphQL** for the backend, and **MongoDB** as the database.

[Software Specification Doc](docs/software_spec_doc.md) \
[Software Design Technical Doc](docs/software_design_tech_doc.md) \
[Screen Definition Doc](docs/screen_def_doc.md) \
[Functional Definition Doc](docs/func_def_doc.md) \
[Database Table Definition Doc](docs/db_table_def_doc.md) \
[Database Table relationship Doc](docs/db_table_rel_def_doc.md) \



## Features
- **Real-Time Attendance Tracking:** Employees can check in and out seamlessly.
- **Day-Off Requests:** Employees can request time off directly from the app.
- **Admin Panel:** Manage attendance and approve/reject day-off requests.
- **User-Friendly Interface:** Mobile-friendly interface with customizable themes.
- **Secure Authentication:** Phone number-based login system with session persistence.
- **Real-Time Updates:** Leverages GraphQL subscriptions for dynamic updates.

---
## Continuous Integration

Every push or pull request to the `dev` branch automatically triggers a build for either Android or iOS, depending on the self-hosted CI runner’s OS. The generated artifacts (APK for Android or APP for iOS) are available for download from the CI workflow's artifact section.

---

## Prerequisites
- **Frontend**: Flutter, Dart ver.5.3.4
- **Authentication**: Firebase(depends on server)

## Setup Instructions
### Step 1: Clone the repository:
   ```bash
   git clone https://github.com/jin-adcapsule/52switch-frontend.git
   cd 52switch-frontend
   ```
### Step 2: Run the setup script in root:
   On Linux/Mac:
   ```bash
      bash setup.sh 
   ```
   On Windows:
   ```bash
      setup.bat
   ```
### Step 3. Configure environment files:
   Update the following file with your frontend environment variables:
   ```plaintext
   dummy/lib/env_config.dart
   ```

### Step 4. Save required files in correct directories:
   Ensure these files are placed in the correct directories (contact the project owner if unsure):
   1. **Android:**
   ```plaintext
   dummy/android/app/google-services.json 
   ``` 
   2. **IOS:**
   ```plaintext
   dummy/ios/Runner/GoogleService-Info.plist
   ```  
   3. **(optional)Firebase:**  
   Own firebase option is to be generated using Firebase CLI
   ```plaintext
   dummy/lib/firebase_options.dart
   ```

### Step 5. Run flutter on simulator:  
   Before running the Flutter app, configure the use of the Firebase emulator in the following file:
   ```plaintext
   dummy/config_env.dart
   ```

      
For further assistance or refinements, feel free to reach out:

**Contact:**  
Chaejin Lim  
📧 [jin.chaejin.lim@adcapsule.co.kr](mailto:jin.chaejin.lim@adcapsule.co.kr)