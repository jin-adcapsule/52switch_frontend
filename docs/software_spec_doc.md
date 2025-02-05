
# Software Specification Document

### **Project Title:**

52 SWITCH Cloning

### **Version:**

1.0

### **Date:**

December 2024

### **Author:**

Chaejin Lim

---

### **1. Project Overview**

52 SWITCH is a mobile application developed for Android and iOS platforms, aimed at providing employees with a simple and efficient way to track attendance, request days off, and manage team employee data. The application will include features like real-time updates, login via phone number, and employee attendance tracking.

---

### **2. Scope**

The application will provide the following functionalities:

- **User Authentication:** Login using phone number with Firebase Authentication.
- **Attendance Management:** Employees can check in and check out daily, with attendance data stored in MongoDB.
- **Day-Off Request:** Employees can request days off and view approval status.
- **Admin Dashboard:** Admins can approve or reject day-off requests and view employee attendance.
- **Real-time Data:** Firebase and GraphQL will be used for real-time updates.
- **Database:** MongoDB will store employee and attendance data.

---

### **3. Functional Requirements**

### **3.1 Authentication**

- **Login:** Employees will log in using their phone number via Firebase Authentication. The first login is required, and the session remains active indefinitely.
- **Password Reset:** Optional, not implemented in the first phase.

### **3.2 Attendance Tracking**

- **Check-in/Check-out:** Employees can record attendance with date, check-in time, check-out time, and location (latitude and longitude).
- **Attendance Status:** Employees can view their current attendance status (e.g., Present, Absent, Late).
- **Remarks:** Employees can add remarks during check-in/check-out.

### **3.3 Day-Off Requests**

- **Request Day Off:** Employees can request a day off by selecting the date and submitting a request.
- **Approval Workflow:** Admins can approve or reject day-off requests.
- **View Status:** Employees can view the status of their day-off request (Approved/Rejected).

### **3.4 Admin Dashboard**

- **Employee Management:** Admins can view and manage employee data, such as attendance history and day-off requests.
- **Day-Off Approvals:** Admins can approve or reject day-off requests from employees.

---

### **4. Non-Functional Requirements**

- **Platform Support:** Android and iOS.
- **Performance:** The app should load within 2 seconds under normal conditions.
- **Security:** Data will be securely stored and transmitted using HTTPS and Firebase Authentication.
- **Scalability:** The system should support up to 200 active users.

---

### **5. System Architecture**

- **Frontend:** Flutter for cross-platform mobile development (Android and iOS).
- **Backend:** Spring Boot with GraphQL for API management and business logic.
- **Database:** MongoDB for storing employee data and attendance logs.
- **Real-time Updates:** Firebase for real-time attendance updates and notifications.

---

### **6. Database Schema**

### **Employee Collection**

| Field | Type | Description |
| --- | --- | --- |
| `_id` | String | Unique identifier for the document (Authentication ID). |
| `employeeId` | String | Unique employee key (Foreign Key). |
| `phone` | String | Employee phone number (e.g., `010xxxxxxxx`). |
| `supervisorId` | String | Supervisor's employee ID (Foreign Key). |
| `dayoffRemaining` | Integer | Remaining day-off balance (default: 15). |
| `email` | String | Employee email address (e.g., `xxx@xxx.com`). |
| `name` | String | Employee's full name. |
| `position` | String | Employee position (e.g., `'사원'`, `'선임'`). |
| `joindate` | Date | Employee's joining date (ISO 8601). |
| `groupId` | String | Group ID (Foreign Key to Group Collection). |
| `locationId` | String | Location ID (Foreign Key to Location Collection). |

### **Attendance Collection**

| Field | Type | Description |
| --- | --- | --- |
| `_id` | String | Unique identifier for the document. |
| `date` | Date | Attendance date (format: `'yyyy-MM-dd'`). |
| `employeeId` | String | Employee ID (Foreign Key to Employee Collection). |
| `checkInTime` | DateTime | Check-in time (ISO 8601). |
| `status` | Boolean | Attendance status toggle (e.g., checked-in/checked-out). |
| `checkOutTime` | DateTime | Check-out time (ISO 8601). |
| `_class` | String | Backend model reference for ORM mapping. |
| `checkInStatus` | String | Check-in status (`'lateArrival'` or `'onTimeArrival'`). |
| `checkOutStatus` | String | Check-out status (`'earlyLeft'` or `'onTimeLeft'`). |
| `workTypeList` | Array | Work types (`['workFull', 'workFirstHalf', ...]`). |

### **Day-Off Collection**

| Field | Type | Description |
| --- | --- | --- |
| `_id` | String | Unique identifier for the document. |
| `employeeId` | String | Employee ID (Foreign Key to Employee Collection). |
| `dayoffType` | String | Type of day off (e.g., `'정기휴가'`, ...). |
| `dayoffDate` | Date | Day-off date (format: `'yyyy-MM-dd'`). |
| `requestKey` | String | Unique request key (`'yyyyMMddhhmmsss-generatedKey'`). |
| `requestStatus` | String | Status of request (`'대기중'`, `'승인'`, `'반려'`). |
| `requestComment` | String | Comments on the request (e.g., `'재가하여 주기시...'`). |
| `requestDate` | Date | Date the request was made (format: `'yyyy-MM-dd'`). |
| `beforeDateRemaining` | Integer | Remaining day-off balance before request (max: 15). |

### **Location Collection**

| Field | Type | Description |
| --- | --- | --- |
| `_id` | String | Unique identifier for the document (Foreign Key). |
| `workplace` | String | Workplace name (e.g., `'본사'`, `'우리은행'`). |
| `workhourOn` | Time | Standard work start time (format: `'hh:mm'`). |
| `workhourhalf` | Time | Standard half-day time (format: `'hh:mm'`). |
| `workhourOff` | Time | Standard work end time (format: `'hh:mm'`). |

### **Credential Collection**

| Field | Type | Description |
| --- | --- | --- |
| `_id` | String | Unique identifier for the document. |
| `employeeOid` | String | Employee ID (Foreign Key to Employee Collection). |
| `fcmToken` | String | Firebase Cloud Messaging token for notifications. |

### **Group Collection**

| Field | Type | Description |
| --- | --- | --- |
| `_id` | String | Unique identifier for the group (Foreign Key). |
| `groupName` | String | Name of the group (e.g., `'Front-End'`). |
| `groupSupervisorRole` | String | Supervisor's role within the group (e.g., `'팀장'`, `'파트장'`). |
| `groupSupervisorEid` | String | Supervisor's employee ID. |
| `subgroup` | String | Reference to a subgroup's ID (if applicable). |
| `parentGroup` | String | Reference to the parent group's ID (if applicable). |

---

### **7. User Interface**

- **Home Screen:** Navigation bar with buttons for "Request Day Off," "Admin," "My Info," and "More."
- **Day-Off Request Screen:** Form to submit a day-off request with date selection and remarks.
- **Attendance Screen:** Display of attendance status with check-in/check-out times and remarks.

---

### **8. Assumptions and Constraints**

- **Assumptions:**
    - The app will be used by employees who have a valid phone number for authentication.
    - The admin is a single entity responsible for managing requests and data.
- **Constraints:**
    - The app does not use geolocation for attendance tracking, but latitude and longitude will be used for future expansions.
    - Limited to 200 active users, which is the initial estimate for user base.

---

### **9. Technologies**

- **Frontend:** Flutter
- **Backend:** Spring Boot, GraphQL
- **Database:** MongoDB
- **Authentication:** Firebase Authentication
- **Real-Time Updates:** Firebase
- **Hosting:** Firebase or custom cloud solution

---

### **10. Testing Requirements**

- **Unit Testing:** Ensure key features (e.g., login, day-off request) are thoroughly unit tested.
- **Integration Testing:** Ensure the frontend and backend communicate seamlessly.
- **User Acceptance Testing (UAT):** Validate user flows, such as day-off requests and attendance recording.

---

### **11. Project Timeline**

| Phase | Start Date | End Date |
| --- | --- | --- |
| **Requirement Gathering** | Nov 11, 2024 | Nov 25, 2024 |
| **Design & Development** | Nov 26, 2024 | Dec 10, 2025 |
| **Testing & Deployment** | Dec 11, 2025 | Dec 25, 2025 |