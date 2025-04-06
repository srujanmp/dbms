-- Drop the SRUJAN database if it exists and recreate it
DROP DATABASE IF EXISTS SRUJAN;
CREATE DATABASE SRUJAN;

-- Connect to the SRUJAN database
\c SRUJAN;

-- Doctors Table
CREATE TABLE Doctors (
    DoctorID SERIAL PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Specialization VARCHAR(255) NOT NULL
);

-- Patients Table
CREATE TABLE Patients (
    PatientID SERIAL PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR(10) NOT NULL CHECK (Gender IN ('Male', 'Female', 'Other'))
);

-- Appointments Table
CREATE TABLE Appointments (
    AppointmentID SERIAL PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate TIMESTAMP NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Scheduled' CHECK (Status IN ('Scheduled', 'Completed', 'Canceled')),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID) ON DELETE CASCADE
);

-- Prescriptions Table
CREATE TABLE Prescriptions (
    PrescriptionID SERIAL PRIMARY KEY,
    AppointmentID INT NOT NULL,
    Medication VARCHAR(255) NOT NULL,
    Dosage VARCHAR(50) NOT NULL,
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID) ON DELETE CASCADE
);

-- Billing Table
CREATE TABLE Billing (
    BillID SERIAL PRIMARY KEY,
    PatientID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentStatus VARCHAR(10) NOT NULL DEFAULT 'Pending' CHECK (PaymentStatus IN ('Pending', 'Paid')),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE
); 

-- Insert Sample Data

-- Doctors
INSERT INTO Doctors (FirstName, LastName, Specialization) VALUES
('Priya', 'Sharma', 'Cardiologist'),
('Ramesh', 'Kumar', 'Orthopedic'),
('Anjali', 'Verma', 'Pediatrician'),
('Suresh', 'Patel', 'Neurologist'),
('Deepika', 'Singh', 'Dermatologist');

-- Patients
INSERT INTO Patients (FirstName, LastName, DateOfBirth, Gender) VALUES
('Arjun', 'Reddy', '1990-05-15', 'Male'),
('Shalini', 'Gupta', '1985-11-22', 'Female'),
('Vikram', 'Menon', '2002-03-10', 'Male'),
('Pooja', 'Hegde', '1998-07-01', 'Female'),
('Kiran', 'Shetty', '1975-09-28', 'Male');

-- Appointments
INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status) VALUES
(1, 1, '2025-03-25 10:00:00', 'Completed'),
(2, 2, '2025-03-26 14:00:00', 'Completed'),
(3, 3, '2025-03-27 17:30:00', 'Scheduled'),
(4, 4, '2025-03-28 11:15:00', 'Scheduled'),
(5, 5, '2025-03-29 12:45:00', 'Canceled'),
(1, 2, '2025-04-01 09:30:00', 'Scheduled'),
(2, 3, '2025-04-02 15:15:00', 'Scheduled'),
(3, 4, '2025-04-03 11:00:00', 'Completed'),
(4, 5, '2025-04-04 16:45:00', 'Scheduled'),
(5, 1, '2025-04-05 10:30:00', 'Scheduled');

-- Prescriptions
INSERT INTO Prescriptions (AppointmentID, Medication, Dosage) VALUES
(1, 'Aspirin', '75mg'),
(2, 'PainRelief Gel', 'Apply liberally'),
(3, 'Paracetamol Syrup', '5ml'),
(4, 'Amitriptyline', '25mg'),
(5, 'Eczema Cream', 'Apply thin layer');

-- Billing
INSERT INTO Billing (PatientID, Amount, PaymentStatus) VALUES
(1, 1500.00, 'Paid'),
(2, 1800.00, 'Paid'),
(3, 1200.00, 'Pending'),
(4, 1100.00, 'Pending'),
(5, 950.00, 'Paid');

-- Queries

-- 1: Get all Cardiologists
SELECT * FROM Doctors WHERE Specialization = 'Cardiologist';

-- 2: Get patients born after 1995
SELECT * FROM Patients WHERE DateOfBirth > '1995-12-31';

-- 3: Get scheduled appointments
SELECT * FROM Appointments WHERE Status = 'Scheduled';

-- 4: Find patients who have completed appointments with a Neurologist
SELECT p.FirstName, p.LastName
FROM Patients p
JOIN Appointments a ON p.PatientID = a.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID
WHERE a.Status = 'Completed' AND d.Specialization = 'Neurologist';

-- 5: List doctors and the number of appointments they have
SELECT d.FirstName, d.LastName, COUNT(a.AppointmentID) AS TotalAppointments
FROM Doctors d
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorID;

-- 6: Get medication and dosage for completed appointments
SELECT pr.Medication, pr.Dosage
FROM Prescriptions pr
JOIN Appointments ap ON pr.AppointmentID = ap.AppointmentID
WHERE ap.Status = 'Completed';

-- 7: Find patients with pending bills who had an appointment with a Pediatrician
SELECT DISTINCT p.FirstName, p.LastName
FROM Patients p
JOIN Appointments a ON p.PatientID = a.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID
JOIN Billing b ON p.PatientID = b.PatientID
WHERE b.PaymentStatus = 'Pending' AND d.Specialization = 'Pediatrician';



-- Create the Trigger Function
CREATE OR REPLACE FUNCTION check_negative_bill()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Amount <= 0 THEN
        NEW.Amount := 100;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--  Create the Trigger on Billing
CREATE TRIGGER set_default_bill_amount
BEFORE INSERT ON Billing
FOR EACH ROW
EXECUTE FUNCTION check_negative_bill();

-- drop
DROP TRIGGER IF EXISTS set_default_bill_amount ON Billing;
DROP FUNCTION IF EXISTS check_negative_bill();
