const express = require('express');
const { Pool } = require('pg');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;

// EJS setup
app.set('view engine', 'ejs');

// Middleware
app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static('public'));
app.use(express.urlencoded({ extended: true }));

// PostgreSQL config
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'srujan',
    password: 'postgres',
    port: 5432
});

app.get('/', (req, res) => {
    res.render('index');
});

// Query form
app.get('/query-form', (req, res) => {
    res.render('query-form');
});

// Show tables
app.get('/tables', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';
        `);
        res.render('tables', { tables: result.rows });
    } catch (err) {
        res.send(`Error: ${err.message}`);
    }
});

// Show table content
app.post('/show-table', async (req, res) => {
    const { tableName } = req.body;
    try {
        const result = await pool.query(`SELECT * FROM ${tableName}`);
        res.render('result', { rows: result.rows });
    } catch (err) {
        res.send(`Error: ${err.message}`);
    }
});

// Insert form
app.get('/insert', (req, res) => {
    res.render('insert_form');
});

// Insert data (example for 'patients' table)
app.post('/insert', async (req, res) => {
    const { name, age, disease } = req.body;
    try {
        await pool.query('INSERT INTO patients (name, age, disease) VALUES ($1, $2, $3)', [name, age, disease]);
        res.send('Patient data inserted successfully!');
    } catch (err) {
        res.send(`Error: ${err.message}`);
    }
});

app.get('/query-demo', (req, res) => {
    res.render('query-demo');
});

app.post('/run-query', async (req, res) => {
    const sql = req.body.sqlQuery || req.body.query;
  
    if (!sql) {
      return res.send('Error: No SQL query provided');
    }
  
    try {
      const result = await pool.query(sql);
      res.render('result', { rows: result.rows });
    } catch (err) {
      res.send(`Error: ${err.message}`);
    }
  });
  
// Insert into Doctors
app.post('/insert-doctor', async (req, res) => {
    const { firstName, lastName, specialization } = req.body;
    try {
        await pool.query(
            'INSERT INTO Doctors (FirstName, LastName, Specialization) VALUES ($1, $2, $3)',
            [firstName, lastName, specialization]
        );
        const result = await pool.query('SELECT * FROM Doctors ORDER BY DoctorID DESC LIMIT 10');
        res.render('result', { rows: result.rows });
    } catch (err) {
        res.send(`Error inserting doctor: ${err.message}`);
    }
});

// Insert into Patients
app.post('/insert-patient', async (req, res) => {
    const { firstName, lastName, dateOfBirth, gender } = req.body;
    try {
        await pool.query(
            'INSERT INTO Patients (FirstName, LastName, DateOfBirth, Gender) VALUES ($1, $2, $3, $4)',
            [firstName, lastName, dateOfBirth, gender]
        );
        const result = await pool.query('SELECT * FROM Patients ORDER BY PatientID DESC LIMIT 10');
        res.render('result', { rows: result.rows });
    } catch (err) {
        res.send(`Error inserting patient: ${err.message}`);
    }
});

// Insert into Appointments
app.post('/insert-appointment', async (req, res) => {
    const { patientId, doctorId, appointmentDate, status } = req.body;
    try {
        await pool.query(
            'INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status) VALUES ($1, $2, $3, $4)',
            [patientId, doctorId, appointmentDate, status]
        );
        const result = await pool.query('SELECT * FROM Appointments ORDER BY AppointmentID DESC LIMIT 10');
        res.render('result', { rows: result.rows });
    } catch (err) {
        res.send(`Error inserting appointment: ${err.message}`);
    }
});

// Insert into Prescriptions
app.post('/insert-prescription', async (req, res) => {
    const { appointmentId, medication, dosage } = req.body;
    try {
        await pool.query(
            'INSERT INTO Prescriptions (AppointmentID, Medication, Dosage) VALUES ($1, $2, $3)',
            [appointmentId, medication, dosage]
        );
        const result = await pool.query('SELECT * FROM Prescriptions ORDER BY PrescriptionID DESC LIMIT 10');
        res.render('result', { rows: result.rows });
    } catch (err) {
        res.send(`Error inserting prescription: ${err.message}`);
    }
});

// Insert into Billing
app.post('/insert-bill', async (req, res) => {
    const { patientId, amount, paymentStatus } = req.body;
    try {
        await pool.query(
            'INSERT INTO Billing (PatientID, Amount, PaymentStatus) VALUES ($1, $2, $3)',
            [patientId, amount, paymentStatus]
        );
        const result = await pool.query('SELECT * FROM Billing ORDER BY BillID DESC LIMIT 10');
        res.render('result', { rows: result.rows });
    } catch (err) {
        res.send(`Error inserting bill: ${err.message}`);
    }
});


app.listen(3000);