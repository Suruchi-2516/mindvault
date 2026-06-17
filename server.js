// ============================================================
// MindVault - Backend Server (server.js)
// Tech: Node.js + Express + MySQL
// ============================================================

const express    = require('express');
const mysql      = require('mysql2');
const cors       = require('cors');
const bodyParser = require('body-parser');
const path       = require('path');

const app  = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname)));  // Serves index.html from same folder

// ============================================================
// DATABASE CONNECTION
// ============================================================

const db = mysql.createConnection({
  host     : 'localhost',
  user     : 'root',         // Change if your MySQL user is different
  password : 'Shri@1234',             // Change to your MySQL root password
  database : 'MindVault'
});

db.connect(err => {
  if (err) {
    console.error('❌ Database connection failed:', err.message);
    process.exit(1);
  }
  console.log('✅ Connected to MindVault database');
});

// ============================================================
// HELPER
// ============================================================

function runQuery(sql, params, res, overrideQueryDisplay) {
  db.query(sql, params || [], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({
      query : overrideQueryDisplay || sql,
      data  : results
    });
  });
}

// ============================================================
// AUTH - POST /login
// Uses: User, Assigned_Role, Role tables
// ============================================================

app.post('/login', (req, res) => {
  const { username, password } = req.body;

  if (!username || !password)
    return res.status(400).json({ error: 'Username and password are required.' });

  const sql = `
    SELECT U.User_ID, U.Username, R.Role_Name
    FROM User U
    JOIN Assigned_Role AR ON U.User_ID = AR.User_ID
    JOIN Role R           ON AR.Role_ID = R.Role_ID
    WHERE U.Username       = ?
      AND U.Password_Hash  = ?
      AND U.Account_Status = 'Active'
  `;

  db.query(sql, [username, password], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0)
      return res.status(401).json({ error: 'Invalid credentials or inactive account.' });

    res.json({ success: true, user: results[0] });
  });
});

// ============================================================
// PATIENTS - GET /patients
// DQL: Simple SELECT with ORDER BY
// ============================================================

app.get('/patients', (req, res) => {
  const sql = `SELECT * FROM Patient ORDER BY Profile_Creation_Date DESC`;
  runQuery(sql, [], res);
});

// ============================================================
// ADD PATIENT - POST /add-patient   (Admin only enforced on frontend)
// DML: INSERT + TCL: Transaction
// ============================================================

app.post('/add-patient', (req, res) => {
  const { Patient_ID, Age_Range, Gender, Case_Category, Profile_Creation_Date } = req.body;

  if (!Patient_ID || !Case_Category)
    return res.status(400).json({ error: 'Patient_ID and Case_Category are required.' });

  const sql = `
    INSERT INTO Patient (Patient_ID, Age_Range, Gender, Case_Category, Profile_Creation_Date)
    VALUES (?, ?, ?, ?, ?)
  `;
  const displaySQL = `START TRANSACTION;\nINSERT INTO Patient VALUES ('${Patient_ID}','${Age_Range}','${Gender}','${Case_Category}','${Profile_Creation_Date}');\nCOMMIT;`;

  db.beginTransaction(err => {
    if (err) return res.status(500).json({ error: err.message });

    db.query(sql, [Patient_ID, Age_Range, Gender, Case_Category, Profile_Creation_Date], (err2, result) => {
      if (err2) {
        return db.rollback(() => {
          res.status(500).json({ error: err2.message });
        });
      }

      db.commit(err3 => {
        if (err3) {
          return db.rollback(() => {
            res.status(500).json({ error: err3.message });
          });
        }

        res.json({
          query   : displaySQL,
          data    : [{ message: `Patient ${Patient_ID} added successfully.`, affectedRows: result.affectedRows }]
        });
      });
    });
  });
});

// ============================================================
// DELETE PATIENT - DELETE /delete-patient/:id   (Admin only)
// DML: DELETE with ON DELETE CASCADE
// ============================================================

app.delete('/delete-patient/:id', (req, res) => {
  const id  = req.params.id;
  const sql = `DELETE FROM Patient WHERE Patient_ID = ?`;
  const displaySQL = `DELETE FROM Patient WHERE Patient_ID = '${id}';\n-- (Cascades to Symptom_Record, Therapy_Session, Treatment_Outcome)`;

  db.query(sql, [id], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    if (result.affectedRows === 0)
      return res.status(404).json({ error: `Patient ${id} not found.` });

    res.json({
      query : displaySQL,
      data  : [{ message: `Patient ${id} deleted successfully.`, affectedRows: result.affectedRows }]
    });
  });
});

// ============================================================
// SYMPTOMS - GET /symptoms
// DQL: 3-table JOIN
// ============================================================

app.get('/symptoms', (req, res) => {
  const sql = `
    SELECT
        P.Patient_ID,
        P.Case_Category,
        P.Age_Range,
        P.Gender,
        ST.Symptom_Name,
        SR.Severity_Score,
        SR.Record_Date,
        SR.Notes
    FROM Patient P
    JOIN Symptom_Record SR ON P.Patient_ID   = SR.Patient_ID
    JOIN Symptom_Type   ST ON SR.Symptom_Type_ID = ST.Symptom_Type_ID
    ORDER BY SR.Severity_Score DESC
  `;
  runQuery(sql, [], res);
});

// ============================================================
// ANALYSIS - GET /analysis
// DQL: GROUP BY + AVG, MAX, MIN + Nested query
// ============================================================

app.get('/analysis', (req, res) => {
  const sql = `
    SELECT
        P.Patient_ID,
        P.Case_Category,
        P.Age_Range,
        P.Gender,
        COUNT(SR.Severity_Score)        AS Total_Records,
        ROUND(AVG(SR.Severity_Score),2) AS Avg_Severity,
        MAX(SR.Severity_Score)          AS Max_Severity,
        MIN(SR.Severity_Score)          AS Min_Severity,
        CASE
            WHEN AVG(SR.Severity_Score) >= 8 THEN 'Critical'
            WHEN AVG(SR.Severity_Score) >= 6 THEN 'Moderate'
            ELSE 'Stable'
        END AS Risk_Level
    FROM Patient P
    LEFT JOIN Symptom_Record SR ON P.Patient_ID = SR.Patient_ID
    GROUP BY P.Patient_ID, P.Case_Category, P.Age_Range, P.Gender
    HAVING Total_Records > 0
    ORDER BY Avg_Severity DESC
  `;
  runQuery(sql, [], res);
});

// ============================================================
// THERAPY SESSIONS - GET /therapy
// DQL: JOIN with therapy data
// ============================================================

app.get('/therapy', (req, res) => {
  const sql = `
    SELECT
        T.Session_ID,
        T.Patient_ID,
        P.Case_Category,
        T.Therapy_Type,
        T.Duration_Minutes,
        T.Frequency_Per_Week,
        T.Session_Date
    FROM Therapy_Session T
    JOIN Patient P ON T.Patient_ID = P.Patient_ID
    ORDER BY T.Session_Date DESC
  `;
  runQuery(sql, [], res);
});

// ============================================================
// NESTED QUERY - GET /nested
// DQL: Patients with above-average severity (nested subquery)
// ============================================================

app.get('/nested', (req, res) => {
  const sql = `
    SELECT
        P.Patient_ID,
        P.Case_Category,
        P.Age_Range,
        SR.Severity_Score
    FROM Patient P
    JOIN Symptom_Record SR ON P.Patient_ID = SR.Patient_ID
    WHERE SR.Severity_Score > (
        SELECT AVG(Severity_Score)
        FROM Symptom_Record
    )
    ORDER BY SR.Severity_Score DESC
  `;
  runQuery(sql, [], res);
});

// ============================================================
// SQL CONSOLE - POST /run-query   (Admin only)
// Only SELECT queries allowed for safety
// ============================================================

app.post('/run-query', (req, res) => {
  const { query } = req.body;

  if (!query || query.trim() === '')
    return res.status(400).json({ error: 'Query cannot be empty.' });

  const trimmed = query.trim().toUpperCase();

  // Security: Allow only SELECT statements
  if (!trimmed.startsWith('SELECT') && !trimmed.startsWith('SHOW') && !trimmed.startsWith('DESCRIBE') && !trimmed.startsWith('DESC')) {
    return res.status(403).json({
      error: '🔒 Only SELECT, SHOW, and DESCRIBE queries are allowed in the console.'
    });
  }

  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ query, data: results });
  });
});

// ============================================================
// DB FEATURES INFO - GET /db-features
// Returns sample SQL for Trigger, Procedure, Cursor, TCL, DCL
// ============================================================

app.get('/db-features', (req, res) => {
  const features = {
    query: '-- Advanced Database Features Reference',
    data: [
      {
        Feature    : 'TRIGGER',
        Name       : 'trg_check_severity',
        Description: 'Clamps Severity_Score between 1 and 10 before every INSERT on Symptom_Record',
        SQL        : `DELIMITER $$\nCREATE TRIGGER trg_check_severity\nBEFORE INSERT ON Symptom_Record\nFOR EACH ROW\nBEGIN\n  IF NEW.Severity_Score > 10 THEN SET NEW.Severity_Score = 10; END IF;\n  IF NEW.Severity_Score < 1  THEN SET NEW.Severity_Score = 1;  END IF;\nEND$$\nDELIMITER ;`
      },
      {
        Feature    : 'STORED PROCEDURE',
        Name       : 'GetPatientData(pid)',
        Description: 'Returns all symptom records for a given Patient_ID with symptom names via JOIN',
        SQL        : `CALL GetPatientData('P001');`
      },
      {
        Feature    : 'STORED PROCEDURE',
        Name       : 'GetHighSeverityPatients(threshold)',
        Description: 'Returns all patients whose severity score >= given threshold',
        SQL        : `CALL GetHighSeverityPatients(8);`
      },
      {
        Feature    : 'CURSOR',
        Name       : 'CursorPatientSummary()',
        Description: 'Iterates over every patient and computes average severity into a temp table',
        SQL        : `CALL CursorPatientSummary();`
      },
      {
        Feature    : 'TCL',
        Name       : 'COMMIT / ROLLBACK',
        Description: 'All INSERT operations use BEGIN TRANSACTION + COMMIT. A failed insert triggers ROLLBACK.',
        SQL        : `START TRANSACTION;\nINSERT INTO Patient VALUES (...);\nCOMMIT; -- or ROLLBACK on error`
      },
      {
        Feature    : 'DCL',
        Name       : 'GRANT / REVOKE',
        Description: 'Admin gets ALL PRIVILEGES; Analyst gets SELECT only on MindVault schema',
        SQL        : `GRANT ALL PRIVILEGES ON MindVault.* TO 'admin_user'@'localhost';\nGRANT SELECT ON MindVault.* TO 'analyst_user'@'localhost';`
      },
      {
        Feature    : 'VIEW',
        Name       : 'Patient_Summary',
        Description: 'Pre-built view with patient count of records and average severity',
        SQL        : `SELECT * FROM Patient_Summary;`
      },
      {
        Feature    : 'INDEX',
        Name       : 'idx_patient',
        Description: 'Index on Symptom_Record(Patient_ID) for faster JOIN lookups',
        SQL        : `CREATE INDEX idx_patient ON Symptom_Record(Patient_ID);`
      }
    ]
  };

  res.json(features);
});

// ============================================================
// START SERVER
// ============================================================

app.listen(PORT, () => {
  console.log(`🚀 MindVault running at http://localhost:${PORT}`);
  console.log(`   Admin login  : admin / admin123`);
  console.log(`   Analyst login: analyst / analyst123`);
});
