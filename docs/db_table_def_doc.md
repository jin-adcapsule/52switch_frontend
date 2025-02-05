# Database Table Definition Document
## 1. **Employee Collection**

| Field | Type | Description |
| --- | --- | --- |
| `_id` | ObjectId | Unique identifier for the document. |
| `employeeId` | String | Unique employee identifier (foreign key). |
| `phone` | String | Employee phone number (e.g., '010xxxxxxxx'). |
| `supervisorId` | String | Reference to the employee's supervisor (optional). |
| `dayoffRemaining` | Integer | Remaining day-off balance (default: 15). |
| `email` | String | Employee email address. |
| `name` | String | Employee name. |
| `position` | String | Job title (e.g., '사원', '선임'). |
| `joindate` | Date | Employee's joining date in ISO8601 format. |
| `groupId` | ObjectId | Group identifier (foreign key). |
| `locationId` | ObjectId | Workplace location identifier (foreign key). |

---

## 2. **Attendance Collection**

| Field | Type | Description |
| --- | --- | --- |
| `_id` | ObjectId | Unique identifier for the document. |
| `employeeId` | String | Reference to the employee identifier (foreign key). |
| `date` | Date | Attendance date ('yyyy-MM-dd'). |
| `checkInTime` | DateTime | Check-in time in ISO8601 format. |
| `checkOutTime` | DateTime | Check-out time in ISO8601 format. |
| `status` | Boolean | Toggle for attendance status. |
| `checkInStatus` | String | Status of check-in ('lateArrival', 'onTimeArrival'). |
| `checkOutStatus` | String | Status of check-out ('earlyLeft', 'onTimeLeft'). |
| `workTypeList` | Array | Array of work types (e.g., ['workFull', 'workFirstHalf']). |
| `_class` | String | Backend model class reference. |

---

## 3. **Day Off Collection**

| Field | Type | Description |
| --- | --- | --- |
| `_id` | ObjectId | Unique identifier for the document. |
| `employeeId` | String | Reference to the employee identifier (foreign key). |
| `dayoffType` | String | Type of day-off (e.g., '정기휴가'). |
| `dayoffDate` | Date | Date of the day-off ('yyyy-MM-dd'). |
| `requestKey` | String | Generated request key ('yyyyMMddhhmmsss'). |
| `requestStatus` | String | Status of request ('대기중', '승인', '반려'). |
| `requestComment` | String | Optional comments regarding the request. |
| `requestDate` | Date | Date when the request was made ('yyyy-MM-dd'). |
| `beforeDateRemaining` | Integer | Remaining day-off balance before the request. |

---

## 4. **Location Collection**

| Field | Type | Description |
| --- | --- | --- |
| `_id` | ObjectId | Unique identifier for the document. |
| `workplace` | String | Workplace name (e.g., "본사", "우리은행"). |
| `workhourOn` | Time | Start work hour ('hh:mm'). |
| `workhourhalf` | Time | Half-day work hour ('hh:mm'). |
| `workhourOff` | Time | End work hour ('hh:mm'). |

---

## 5. **Credential Collection**

| Field | Type | Description |
| --- | --- | --- |
| `_id` | ObjectId | Unique identifier for the document. |
| `employeeOid` | ObjectId | Reference to the employee identifier (foreign key). |
| `fcmToken` | String | Firebase Cloud Messaging token for notifications. |

---

## 6. **Group Collection**

| Field | Type | Description |
| --- | --- | --- |
| `_id` | ObjectId | Unique identifier for the document. |
| `groupName` | String | Name of the group (e.g., 'Front-End'). |
| `groupSupervisorRole` | String | Supervisor's role ('팀장', '파트장'). |
| `groupSupervisorEid` | String | Reference to the supervisor's employee ID. |
| `subgroup` | ObjectId | Reference to a subgroup ID. |
| `parentGroup` | ObjectId | Reference to the parent group ID. |