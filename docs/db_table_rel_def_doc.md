# Database Table Relationship Definition Document
### 1. Employee Collection

- **Primary Key**: `_id`
- **Relationships**:
    - **`employeeId`** is a foreign key in the **Attendance Collection** and the **Day Off Collection**.
    - **`groupId`** is a foreign key in the **Group Collection**.
    - **`locationId`** is a foreign key in the **Location Collection**.

### 2. Attendance Collection

- **Primary Key**: `_id`
- **Relationships**:
    - **`employeeId`** is a foreign key referencing the **Employee Collection**.

### 3. Day Off Collection

- **Primary Key**: `_id`
- **Relationships**:
    - **`employeeId`** is a foreign key referencing the **Employee Collection**.

### 4. Location Collection

- **Primary Key**: `_id`
- **Relationships**:
    - Referenced by the **Employee Collection** via the `locationId` foreign key.

### 5. Credential Collection

- **Primary Key**: `_id`
- **Relationships**:
    - **`employeeOid`** is a foreign key referencing the **Employee Collection**.

### 6. Group Collection

- **Primary Key**: `_id`
- **Relationships**:
    - **`parentGroup`** and **`subgroup`** are self-referencing keys within the **Group Collection**.
    - Referenced by the **Employee Collection** via the `groupId` foreign key.

### Entity Relationship Overview

1. **Employee Collection**:
    - Acts as the central entity, with relationships to attendance, day off, group, location, and credential data.
2. **Attendance Collection**:
    - Maintains daily attendance data with a dependency on `employeeId` for employee-specific records.
3. **Day Off Collection**:
    - Tracks employee leave information and is dependent on `employeeId` for employee-specific leave data.
4. **Location Collection**:
    - Defines work location details and associates with employees via `locationId`.
5. **Credential Collection**:
    - Stores authentication data linked to employees via `employeeOid`.
6. **Group Collection**:
    - Represents organizational groups and hierarchies, with self-referencing relationships for subgrouping and parent grouping.

### Constraints and Indexing

- Foreign key constraints will ensure data integrity between collections.
- Indexes on keys like `employeeId`, `groupId`, and `locationId` will optimize query performance for related data.

---

This structure ensures normalized data and efficient relationships across all collections, supporting scalability and maintainability.