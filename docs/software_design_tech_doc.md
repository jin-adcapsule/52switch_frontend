# Software Design Technical Document

## 1. Introduction

This document outlines the technical design and architecture for the **52SWITCH APP**. The goal is to create a scalable, real-time application with seamless integration between frontend and backend systems, ensuring a user-friendly experience and maintainability for future development.

---

## 2. System Overview

### **Purpose**

The system manages employee attendance, day-off requests, and approvals, providing:

- Real-time attendance tracking.
- Secure and efficient day-off request handling.
- User role-based access controls.

### **Scope**

- **Users:** Employees, Supervisors, and Administrators (approx. 200 users).
- **Platforms:** Flutter (mobile frontend), Spring Boot (backend with GraphQL), Firebase, and MongoDB.

---

## 3. Architecture Overview

### **Tech Stack**

- **Frontend:** Flutter (Dart)
- **Backend:** Spring Boot with GraphQL
- **Database:** MongoDB
- **Authentication:** Firebase Authentication (Phone-based login)
- **Real-time Updates:** Firebase Cloud Messaging (FCM)

### **High-Level Architecture**

1. **Frontend** communicates with **GraphQL API** for data fetching and mutations.
2. **Spring Boot Backend** integrates with Firebase for authentication and MongoDB for persistence.
3. Real-time updates are handled via Firebase Cloud Messaging.

---

## 4. Functional Components

### **Frontend (Flutter)**

### **Key Features**

1. **Login:** Phone number authentication via Firebase.
2. **Dashboard:** Displays attendance status, remaining day-offs, and quick actions (e.g., request day-off).
3. **Bottom Navigation:** Includes tabs for Home, My Info, Request Day-Off, and Admin (role-based visibility).
4. **Toggle Themes:** Adjusts colors and layouts dynamically based on user interaction.

### **UI Design Guidelines**

- Responsive layout for Android and iOS.
- Clear role-based navigation.
- Error handling and validation for all user inputs.

---

### **Backend (Spring Boot with GraphQL)**

### **Key Features**

1. **Authentication:** Validate Firebase tokens and manage session states.
2. **GraphQL API:**
    - **Queries:** Fetch attendance, day-off balances, and user profiles.
    - **Mutations:** Update attendance records and submit day-off requests.
3. **Business Logic:** Handle status calculations (e.g., late arrival, early leave).
4. **Role Management:** Differentiate between employees, supervisors, and admins.

### **GraphQL Schema Example**

```graphql
# Employee Query
query {
  getEmployee(employeeId: "12345") {
    name
    position
    dayoffRemaining
  }
}

# Attendance Mutation
mutation {
  checkIn(employeeId: "12345", timestamp: "2024-12-20T09:00:00Z") {
    status
    checkInTime
  }
}

```

---

### **Database (MongoDB)**

### **Collections Overview**

1. **Employee Collection**
    - Stores employee details, supervisor relationships, and remaining day-offs.
2. **Attendance Collection**
    - Logs check-in/check-out times and statuses.
3. **Day-Off Collection**
    - Tracks requests, approvals, and rejections.
4. **Location Collection**
    - Defines workplace and workhour details.
5. **Credential Collection**
    - Links Firebase tokens to employees.
6. **Group Collection**
    - Manages organizational group structures.

### **Example Schema**

```json
{
  "employeeId": "E12345",
  "name": "John Doe",
  "position": "Senior Developer",
  "dayoffRemaining": 12,
  "supervisorId": "E67890",
  "groupId": "G001"
}

```

---

## 5. Integration Design

### **Authentication**

- Firebase Authentication for login.
- Backend validates Firebase JWT and generates session tokens.

### **Real-Time Updates**

- Firebase Cloud Messaging used for notifying employees of status changes (e.g., day-off approvals).

### **Data Flow**

1. **Login Process:**
    - User logs in using phone number.
    - Firebase generates JWT.
    - Backend verifies JWT and fetches user data from MongoDB.
2. **Attendance Management:**
    - Employee checks in via Flutter app.
    - Frontend sends mutation to GraphQL API.
    - Backend updates MongoDB and triggers notifications if required.

---

## 6. Deployment Plan

### **Environments**

- **Development:** Local Firebase emulator, test MongoDB instance.
- **Production:** Deployed on cloud-based environments with scalable backend and database.

### **CI/CD Workflow**

- **GitHub Actions:**
    - Automated tests for Flutter frontend and Spring Boot backend.
    - Separate build pipelines for iOS and Android.
    - Artifact uploads for APK/IPA files.

---

## 7. Security and Compliance

1. **Data Encryption:**
    - All communication secured using HTTPS.
    - MongoDB secured with access control and encryption.
2. **Access Control:**
    - Role-based access control enforced via backend.
3. **Sensitive Data Handling:**
    - Firebase credentials and API keys stored in GitHub Secrets.

---

## 8. Performance Considerations

1. Optimize GraphQL queries to minimize data retrieval time.
2. Use indexed fields in MongoDB for frequent queries (e.g., `employeeId`, `date`).
3. Reduce frontend latency with preloading of critical data.

---

## 9. Conclusion

The outlined design provides a clear and scalable approach. By adhering to these specifications, the system will meet business requirements while maintaining robustness and extensibility.