# MindVault – An Anonymized Mental Health Database System

## Overview

MindVault is a database-driven web application designed for the secure storage, management, and analysis of anonymized mental health data. The project demonstrates core Database Management System (DBMS) concepts including database design, normalization, SQL programming, transactions, triggers, stored procedures, cursors, views, and role-based access control.

The system eliminates personally identifiable information and uses anonymized patient records for academic and analytical purposes.

---

## Features

* Anonymized patient data management
* Role-Based Access Control (Admin and Analyst)
* Patient record insertion and deletion
* Symptom tracking and severity analysis
* Therapy session management
* Treatment outcome tracking
* Advanced SQL operations:

  * Joins
  * Aggregate Functions
  * Nested Queries
  * Views
  * Triggers
  * Stored Procedures
  * Cursors
  * Transactions (TCL)
  * Privilege Management (DCL)
* Interactive web interface
* SQL query display alongside results

---

## Technology Stack

### Backend

* Node.js
* Express.js
* MySQL
* mysql2
* body-parser
* cors

### Frontend

* HTML5
* CSS3
* JavaScript (ES6)

### Database

* MySQL Server 8+

---

## Database Design

The database consists of the following major entities:

* Patient
* Symptom_Type
* Symptom_Record
* Therapy_Session
* Treatment_Outcome
* User
* Role
* Permission
* Assigned_Role
* Has_Permission

The schema is normalized up to Third Normal Form (3NF) and follows relational database design principles.

---

## Project Structure

```text
MindVault_Project_New/
│
├── index.html
├── server.js
├── package.json
├── package-lock.json
├── .gitignore
│
└── database/
    └── MindVault.sql
```

---

## Installation

### 1. Clone Repository

```bash
git clone <repository-url>
cd MindVault_Project_New
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Setup Database

1. Open MySQL Workbench.
2. Execute the script:

```sql
database/MindVault.sql
```

3. This will automatically:

   * Create the database
   * Create all tables
   * Insert sample data
   * Create views
   * Create triggers
   * Create stored procedures
   * Create cursor procedures
   * Configure permissions

### 4. Configure Database Credentials

Edit the database connection settings in `server.js`:

```javascript
const db = mysql.createConnection({
  host: 'localhost',
  user: 'your_username',
  password: 'your_password',
  database: 'MindVault'
});
```

### 5. Run the Application

```bash
node server.js
```

Open:

```text
http://localhost:3000
```

---

## Academic Objectives Demonstrated

* Entity Relationship Modeling (ER)
* Relational Schema Design
* Data Dictionary Creation
* Database Normalization (1NF, 2NF, 3NF)
* SQL and PL/SQL Programming
* Trigger Implementation
* Stored Procedures
* Cursor Usage
* Transactions (COMMIT / ROLLBACK)
* Role-Based Access Control
* Frontend-Backend Integration

---

## Security & Privacy

MindVault stores only anonymized data and excludes personally identifiable information (PII). The system is intended solely for educational and research demonstration purposes.

---

## Future Enhancements

* Password hashing using bcrypt
* JWT-based authentication
* Advanced analytics dashboard
* Data visualization and reporting
* Export to CSV/PDF
* Cloud deployment
* Machine Learning based trend analysis

---

## Developer

Suruchi Dhawan :)


Developed as part of the Database Management System (DBMS) Mini Project.

---

## License

This project is developed for academic and educational purposes under the Database Management System course.
