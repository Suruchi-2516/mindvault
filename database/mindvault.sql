-- ============================================================
-- MindVault - Complete MySQL Setup Script
-- Includes: DDL, DML, DQL, DCL, TCL, Triggers, Procedures, Cursor
-- ============================================================

DROP DATABASE IF EXISTS MindVault;
CREATE DATABASE MindVault;
USE MindVault;

-- ============================================================
-- DDL - CREATE TABLES
-- ============================================================

CREATE TABLE Patient (
    Patient_ID VARCHAR(10) PRIMARY KEY,
    Age_Range VARCHAR(10),
    Gender CHAR(1),
    Case_Category VARCHAR(50) NOT NULL,
    Profile_Creation_Date DATE
);

CREATE TABLE Symptom_Type (
    Symptom_Type_ID VARCHAR(10) PRIMARY KEY,
    Symptom_Name VARCHAR(50) NOT NULL,
    Description TEXT
);

CREATE TABLE Symptom_Record (
    Patient_ID VARCHAR(10),
    Symptom_Type_ID VARCHAR(10),
    Record_Date DATE,
    Severity_Score INT CHECK (Severity_Score BETWEEN 1 AND 10),
    Notes TEXT,
    PRIMARY KEY (Patient_ID, Symptom_Type_ID, Record_Date),
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE CASCADE,
    FOREIGN KEY (Symptom_Type_ID) REFERENCES Symptom_Type(Symptom_Type_ID)
);

CREATE TABLE Therapy_Session (
    Session_ID VARCHAR(10) PRIMARY KEY,
    Patient_ID VARCHAR(10),
    Therapy_Type VARCHAR(50),
    Duration_Minutes INT,
    Frequency_Per_Week INT,
    Session_Date DATE,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE CASCADE
);

CREATE TABLE Treatment_Outcome (
    Outcome_ID VARCHAR(10) PRIMARY KEY,
    Patient_ID VARCHAR(10),
    Evaluation_Date DATE,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE CASCADE
);

CREATE TABLE User (
    User_ID VARCHAR(10) PRIMARY KEY,
    Username VARCHAR(50) UNIQUE,
    Password_Hash VARCHAR(100),
    Account_Status VARCHAR(20)
);

CREATE TABLE Role (
    Role_ID VARCHAR(10) PRIMARY KEY,
    Role_Name VARCHAR(50)
);

CREATE TABLE Permission (
    Permission_ID VARCHAR(10) PRIMARY KEY,
    Permission_Name VARCHAR(50),
    Description TEXT
);

CREATE TABLE Assigned_Role (
    User_ID VARCHAR(10),
    Role_ID VARCHAR(10),
    Assignment_Date DATE,
    Assigned_By VARCHAR(50),
    PRIMARY KEY (User_ID, Role_ID),
    FOREIGN KEY (User_ID) REFERENCES User(User_ID),
    FOREIGN KEY (Role_ID) REFERENCES Role(Role_ID)
);

CREATE TABLE Has_Permission (
    Role_ID VARCHAR(10),
    Permission_ID VARCHAR(10),
    Granted_Date DATE,
    PRIMARY KEY (Role_ID, Permission_ID),
    FOREIGN KEY (Role_ID) REFERENCES Role(Role_ID),
    FOREIGN KEY (Permission_ID) REFERENCES Permission(Permission_ID)
);

-- ============================================================
-- INDEX
-- ============================================================

CREATE INDEX idx_patient ON Symptom_Record(Patient_ID);
CREATE INDEX idx_symptom_type ON Symptom_Record(Symptom_Type_ID);

-- ============================================================
-- DML - INSERT DATA
-- ============================================================

-- Symptom Types
INSERT INTO Symptom_Type VALUES
('S01', 'Anxiety',       'Persistent worry and nervousness'),
('S02', 'Insomnia',      'Difficulty falling or staying asleep'),
('S03', 'Fatigue',       'Persistent low energy and tiredness'),
('S04', 'Panic',         'Sudden intense fear or discomfort'),
('S05', 'Mood Swings',   'Rapid or extreme emotional changes'),
('S06', 'Depression',    'Persistent sadness and loss of interest'),
('S07', 'Irritability',  'Easily annoyed or angered'),
('S08', 'Hopelessness',  'Feeling that nothing will improve'),
('S09', 'Flashbacks',    'Involuntary memories of past trauma'),
('S10', 'Hypervigilance','Heightened state of alertness');

-- Patients (30 records)
INSERT INTO Patient VALUES
('P001', '18-25', 'F', 'Anxiety',    '2024-01-10'),
('P002', '26-35', 'M', 'Depression', '2024-01-12'),
('P003', '18-25', 'F', 'Stress',     '2024-01-15'),
('P004', '36-45', 'M', 'PTSD',       '2024-01-20'),
('P005', '26-35', 'F', 'Anxiety',    '2024-01-22'),
('P006', '18-25', 'M', 'Anxiety',    '2024-02-01'),
('P007', '26-35', 'F', 'Depression', '2024-02-02'),
('P008', '36-45', 'M', 'Stress',     '2024-02-03'),
('P009', '18-25', 'F', 'Anxiety',    '2024-02-04'),
('P010', '26-35', 'M', 'PTSD',       '2024-02-05'),
('P011', '46-55', 'F', 'Depression', '2024-02-06'),
('P012', '18-25', 'M', 'Stress',     '2024-02-07'),
('P013', '26-35', 'F', 'OCD',        '2024-02-08'),
('P014', '36-45', 'M', 'Anxiety',    '2024-02-09'),
('P015', '18-25', 'F', 'Depression', '2024-02-10'),
('P016', '26-35', 'M', 'PTSD',       '2024-02-11'),
('P017', '46-55', 'F', 'Anxiety',    '2024-02-12'),
('P018', '18-25', 'M', 'Stress',     '2024-02-13'),
('P019', '26-35', 'F', 'Depression', '2024-02-14'),
('P020', '36-45', 'M', 'OCD',        '2024-02-15'),
('P021', '18-25', 'F', 'Anxiety',    '2024-02-16'),
('P022', '26-35', 'M', 'PTSD',       '2024-02-17'),
('P023', '46-55', 'F', 'Depression', '2024-02-18'),
('P024', '18-25', 'M', 'Stress',     '2024-02-19'),
('P025', '26-35', 'F', 'Anxiety',    '2024-02-20'),
('P026', '36-45', 'M', 'Depression', '2024-02-21'),
('P027', '18-25', 'F', 'PTSD',       '2024-02-22'),
('P028', '26-35', 'M', 'Stress',     '2024-02-23'),
('P029', '46-55', 'F', 'OCD',        '2024-02-24'),
('P030', '18-25', 'M', 'Anxiety',    '2024-02-25');

-- Symptom Records (30+ records)
INSERT INTO Symptom_Record VALUES
('P001', 'S01', '2024-02-01', 7, 'Moderate anxiety before work'),
('P001', 'S02', '2024-02-05', 5, 'Mild sleep issues'),
('P002', 'S03', '2024-02-03', 8, 'Severe fatigue, barely functional'),
('P002', 'S06', '2024-02-04', 9, 'Severe depression episode'),
('P003', 'S04', '2024-02-06', 6, 'Moderate panic at crowded places'),
('P004', 'S05', '2024-02-07', 9, 'Severe mood swings'),
('P004', 'S09', '2024-02-08', 8, 'Frequent flashbacks'),
('P005', 'S01', '2024-02-08', 4, 'Improving, mild anxiety'),
('P006', 'S01', '2024-02-10', 7, 'Anxiety around social situations'),
('P006', 'S04', '2024-02-11', 6, 'Panic attack at mall'),
('P007', 'S06', '2024-02-12', 9, 'Severe depression, withdrawn'),
('P007', 'S08', '2024-02-13', 8, 'Expressing hopelessness'),
('P008', 'S03', '2024-02-14', 5, 'Moderate fatigue from work stress'),
('P008', 'S07', '2024-02-15', 6, 'Irritable at home'),
('P009', 'S01', '2024-02-16', 3, 'Mild anxiety, improving'),
('P009', 'S02', '2024-02-17', 4, 'Occasional insomnia'),
('P010', 'S09', '2024-02-18', 8, 'War-related flashbacks'),
('P010', 'S10', '2024-02-19', 9, 'Extreme hypervigilance'),
('P011', 'S06', '2024-02-20', 7, 'Moderate depression, seeking help'),
('P012', 'S03', '2024-02-21', 6, 'Fatigue due to exams'),
('P013', 'S01', '2024-02-22', 5, 'OCD-driven anxiety'),
('P014', 'S01', '2024-02-23', 8, 'High anxiety, job loss'),
('P015', 'S06', '2024-02-24', 9, 'Severe depression, grief-related'),
('P016', 'S09', '2024-02-25', 7, 'Accident-related flashbacks'),
('P017', 'S01', '2024-02-26', 4, 'Low anxiety, stable'),
('P018', 'S03', '2024-02-27', 5, 'Moderate fatigue'),
('P019', 'S06', '2024-02-28', 6, 'Depression improving with therapy'),
('P020', 'S07', '2024-02-29', 7, 'Irritability worsening'),
('P021', 'S01', '2024-03-01', 8, 'Anxiety from relationship issues'),
('P022', 'S09', '2024-03-02', 9, 'PTSD flashbacks daily'),
('P023', 'S06', '2024-03-03', 6, 'Moderate depression'),
('P024', 'S03', '2024-03-04', 3, 'Mild fatigue, recovering'),
('P025', 'S01', '2024-03-05', 7, 'Anxiety before assessments'),
('P026', 'S06', '2024-03-06', 5, 'Depression, attending CBT'),
('P027', 'S09', '2024-03-07', 8, 'PTSD, nightmares reported'),
('P028', 'S03', '2024-03-08', 4, 'Fatigue improving'),
('P029', 'S01', '2024-03-09', 6, 'OCD anxiety manageable'),
('P030', 'S01', '2024-03-10', 5, 'Mild anxiety, coping well');

-- Therapy Sessions
INSERT INTO Therapy_Session VALUES
('T101', 'P001', 'CBT',           60, 2, '2024-02-10'),
('T102', 'P002', 'Counseling',    45, 1, '2024-02-12'),
('T103', 'P003', 'Group Therapy', 50, 3, '2024-02-14'),
('T104', 'P004', 'CBT',           60, 2, '2024-02-16'),
('T105', 'P005', 'Mindfulness',   40, 2, '2024-02-18'),
('T106', 'P006', 'CBT',           60, 2, '2024-02-20'),
('T107', 'P007', 'Counseling',    45, 3, '2024-02-22'),
('T108', 'P008', 'Mindfulness',   30, 1, '2024-02-24'),
('T109', 'P009', 'Group Therapy', 50, 2, '2024-02-26'),
('T110', 'P010', 'EMDR',          60, 2, '2024-02-28'),
('T111', 'P011', 'Counseling',    45, 1, '2024-03-01'),
('T112', 'P012', 'CBT',           60, 2, '2024-03-03'),
('T113', 'P013', 'CBT',           60, 3, '2024-03-05'),
('T114', 'P014', 'Mindfulness',   40, 2, '2024-03-07'),
('T115', 'P015', 'Counseling',    45, 3, '2024-03-09');

-- Treatment Outcomes
INSERT INTO Treatment_Outcome VALUES
('O01', 'P001', '2024-03-01'),
('O02', 'P002', '2024-03-05'),
('O03', 'P003', '2024-03-07'),
('O04', 'P004', '2024-03-10'),
('O05', 'P005', '2024-03-12'),
('O06', 'P006', '2024-03-14'),
('O07', 'P007', '2024-03-16'),
('O08', 'P008', '2024-03-18');

-- Users, Roles, Permissions
INSERT INTO User VALUES
('U01', 'admin',   'admin123',    'Active'),
('U02', 'analyst', 'analyst123',  'Active'),
('U03', 'viewer',  'viewer123',   'Inactive');

INSERT INTO Role VALUES
('R01', 'Admin'),
('R02', 'Analyst');

INSERT INTO Permission VALUES
('PR01', 'READ',   'Can view all data'),
('PR02', 'WRITE',  'Can insert and update data'),
('PR03', 'DELETE', 'Can delete records'),
('PR04', 'QUERY',  'Can run custom SQL queries');

INSERT INTO Assigned_Role VALUES
('U01', 'R01', '2024-01-01', 'System'),
('U02', 'R02', '2024-01-01', 'System');

INSERT INTO Has_Permission VALUES
('R01', 'PR01', '2024-01-01'),
('R01', 'PR02', '2024-01-01'),
('R01', 'PR03', '2024-01-01'),
('R01', 'PR04', '2024-01-01'),
('R02', 'PR01', '2024-01-01');

-- ============================================================
-- TRIGGER - Clamp Severity Score to max 10
-- ============================================================

DELIMITER $$

CREATE TRIGGER trg_check_severity
BEFORE INSERT ON Symptom_Record
FOR EACH ROW
BEGIN
    IF NEW.Severity_Score > 10 THEN
        SET NEW.Severity_Score = 10;
    END IF;
    IF NEW.Severity_Score < 1 THEN
        SET NEW.Severity_Score = 1;
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- STORED PROCEDURE 1 - Get all records for a patient
-- ============================================================

DELIMITER $$

CREATE PROCEDURE GetPatientData(IN pid VARCHAR(10))
BEGIN
    SELECT SR.Patient_ID, ST.Symptom_Name, SR.Severity_Score, SR.Record_Date, SR.Notes
    FROM Symptom_Record SR
    JOIN Symptom_Type ST ON SR.Symptom_Type_ID = ST.Symptom_Type_ID
    WHERE SR.Patient_ID = pid
    ORDER BY SR.Record_Date DESC;
END$$

DELIMITER ;

-- ============================================================
-- STORED PROCEDURE 2 - Get patients with high severity
-- ============================================================

DELIMITER $$

CREATE PROCEDURE GetHighSeverityPatients(IN threshold INT)
BEGIN
    SELECT DISTINCT P.Patient_ID, P.Case_Category, P.Age_Range, SR.Severity_Score
    FROM Patient P
    JOIN Symptom_Record SR ON P.Patient_ID = SR.Patient_ID
    WHERE SR.Severity_Score >= threshold
    ORDER BY SR.Severity_Score DESC;
END$$

DELIMITER ;

-- ============================================================
-- CURSOR - Loop through all patients and log their avg severity
-- (Cursor example stored in a procedure)
-- ============================================================

DELIMITER $$

CREATE PROCEDURE CursorPatientSummary()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_pid VARCHAR(10);
    DECLARE v_avg DECIMAL(5,2);

    DECLARE patient_cursor CURSOR FOR
        SELECT Patient_ID FROM Patient;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS TempSummary (
        Patient_ID VARCHAR(10),
        Avg_Severity DECIMAL(5,2)
    );

    OPEN patient_cursor;

    read_loop: LOOP
        FETCH patient_cursor INTO v_pid;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT AVG(Severity_Score) INTO v_avg
        FROM Symptom_Record
        WHERE Patient_ID = v_pid;

        INSERT INTO TempSummary VALUES (v_pid, IFNULL(v_avg, 0));
    END LOOP;

    CLOSE patient_cursor;

    SELECT * FROM TempSummary ORDER BY Avg_Severity DESC;

    DROP TEMPORARY TABLE IF EXISTS TempSummary;
END$$

DELIMITER ;

-- ============================================================
-- VIEW - Patient Summary
-- ============================================================

CREATE VIEW Patient_Summary AS
SELECT P.Patient_ID, P.Case_Category, P.Age_Range, P.Gender,
       COUNT(SR.Severity_Score) AS Total_Records,
       ROUND(AVG(SR.Severity_Score), 2) AS Avg_Severity
FROM Patient P
LEFT JOIN Symptom_Record SR ON P.Patient_ID = SR.Patient_ID
GROUP BY P.Patient_ID, P.Case_Category, P.Age_Range, P.Gender;

-- ============================================================
-- TCL - Transaction examples
-- ============================================================

-- Successful transaction
START TRANSACTION;
INSERT INTO Patient VALUES ('P031', '18-25', 'M', 'Stress', '2024-03-11');
COMMIT;

-- Rolled back transaction (test only)
START TRANSACTION;
INSERT INTO Patient VALUES ('P099', '18-25', 'F', 'Test', '2024-03-12');
ROLLBACK;
-- P099 will NOT exist after rollback

-- ============================================================
-- DQL - Sample SELECT queries
-- ============================================================

-- JOIN: Patient + Symptoms
SELECT P.Patient_ID, P.Case_Category, S.Symptom_Name, SR.Severity_Score, SR.Record_Date
FROM Patient P
JOIN Symptom_Record SR ON P.Patient_ID = SR.Patient_ID
JOIN Symptom_Type S ON SR.Symptom_Type_ID = S.Symptom_Type_ID;

-- GROUP BY + Aggregate
SELECT Patient_ID, AVG(Severity_Score) AS Avg_Severity
FROM Symptom_Record
GROUP BY Patient_ID
HAVING AVG(Severity_Score) > 6;

-- Nested query: Patients undergoing CBT
SELECT Patient_ID FROM Patient
WHERE Patient_ID IN (
    SELECT Patient_ID FROM Therapy_Session
    WHERE Therapy_Type = 'CBT'
);

-- Top 5 most severe records
SELECT * FROM Symptom_Record
ORDER BY Severity_Score DESC
LIMIT 5;

-- ============================================================
-- DCL - Grant privileges (run as root)
-- ============================================================

CREATE USER  'admin_user'@'localhost' IDENTIFIED BY 'AdminPass123';
CREATE USER  'analyst_user'@'localhost' IDENTIFIED BY 'AnalystPass123';

GRANT ALL PRIVILEGES ON MindVault.* TO 'admin_user'@'localhost';
GRANT SELECT ON MindVault.* TO 'analyst_user'@'localhost';

FLUSH PRIVILEGES;
commit;
