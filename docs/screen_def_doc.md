# Screen Definition Document
This document outlines the key screens for 52 SWITCH Application, describing their layouts, functionalities, and navigation flow. It ensures that the UI/UX aligns with user expectations and application requirements.

---

## 1. **Login Screen**

### Purpose

Enable users to authenticate via phone number.

### Components

- **Phone Number Input Field**: Text input for phone number entry.
- **Login Button**: Triggers authentication process.
- **Verification Code Input**: Appears after entering a valid phone number.
- **Submit Button**: Verifies the code and logs in the user.

### Navigation

- Success: Redirect to **Home Screen**.
- Failure: Display error messages inline.

---

## 2. **Home Screen**

### Purpose

Central hub for accessing key features: attendance management, day-off requests, and profile.

### Components

- **Greeting Banner**: Displays personalized greetings (e.g., "Welcome, [Name]").
- **Attendance Status Widget**: Shows current day’s check-in/out status.
- **Buttons in Bottom Navigation Bar**:
    - **Home**: Redirects to this screen.
    - **Request Day-Off**: Navigates to Day-Off Request Screen.
    - **My Info**: Opens user profile and details.
    - **More**: Links to additional options or settings.

### Navigation

- Click on widgets or buttons to navigate to respective screens.

---

## 3. **Attendance Management Screen**

### Purpose

Allow employees to view, manage, and update attendance records.

### Components

- **Check-In/Out Buttons**: Toggle attendance status.
- **Attendance Log Table**: Displays past records.
- **Status Indicator**: Shows current attendance status (e.g., Late Arrival, Early Leave).

### Navigation

- Return to **Home Screen** via Bottom Navigation Bar.

---

## 4. **Day-Off Request Screen**

### Purpose

Enable employees to request, track, and manage day-offs.

### Components

- **Day-Off Type Dropdown**: Select day-off category.
- **Calendar Picker**: Select day-off date.
- **Comment Field**: Optional remarks for the supervisor.
- **Submit Button**: Sends the request for approval.
- **Request Status**: Displays pending, approved, or rejected status.

### Navigation

- Submit redirects back to **Home Screen**.

---

## 5. **Admin Dashboard**

### Purpose

Provide supervisors with tools to manage team attendance and day-off requests.

### Components

- **Attendance Overview Table**: Displays team attendance records.
- **Pending Requests Widget**: Highlights pending day-off approvals.
- **Action Buttons**:
    - Approve/Reject Day-Off Requests.
    - Edit Attendance Records.

### Navigation

- Access from the **More Menu** on Home Screen.

---

## 6. **My Info Screen**

### Purpose

Display user profile and personal details.

### Components

- **Profile Picture**: Editable user avatar.
- **Personal Info**: Name, phone, email, position, group, etc.
- **Day-Off Remaining**: Visual tracker for remaining day-offs.

### Navigation

- Accessible from Bottom Navigation Bar.

---

## 7. **More Options Screen**

### Purpose

Provide additional functionalities and settings.

### Components

- **Settings**: Application preferences.
- **Help & Support**: FAQ and contact info.
- **Logout Button**: Ends the current session.

### Navigation

- Return to **Home Screen** via Bottom Navigation Bar.

---

### Notes

- All screens must adhere to responsive design principles.
- Ensure smooth transitions and animations for enhanced UX.
- Maintain consistency in colors, fonts, and design elements across all screens.

---