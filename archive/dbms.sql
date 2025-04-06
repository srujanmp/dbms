-- Create the SRUJAN database
CREATE DATABASE SRUJAN;
GO
ALTER DATABASE SRUJAN SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE SRUJAN
USE master;

-- Use the SRUJAN database
USE SRUJAN;
GO

-- Doctors Table
CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(255) NOT NULL,
    LastName NVARCHAR(255) NOT NULL,
    Specialization NVARCHAR(255) NOT NULL
);

-- Patients Table
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(255) NOT NULL,
    LastName NVARCHAR(255) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender NVARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')) NOT NULL
);

-- Appointments Table
CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATETIME NOT NULL,
    Status NVARCHAR(20) CHECK (Status IN ('Scheduled', 'Completed', 'Canceled')) NOT NULL DEFAULT 'Scheduled',
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID) ON DELETE CASCADE
);

-- Prescriptions Table
CREATE TABLE Prescriptions (
    PrescriptionID INT PRIMARY KEY IDENTITY(1,1),
    AppointmentID INT NOT NULL,
    Medication NVARCHAR(255) NOT NULL,
    Dosage NVARCHAR(50) NOT NULL,
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID) ON DELETE CASCADE
);

-- Billing Table
CREATE TABLE Billing (
    BillID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentStatus NVARCHAR(10) CHECK (PaymentStatus IN ('Pending', 'Paid')) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE
);
GO

-- Insert Sample Data

-- Doctors (5 total)
INSERT INTO Doctors (FirstName, LastName, Specialization) VALUES
('Priya', 'Sharma', 'Cardiologist'),
('Ramesh', 'Kumar', 'Orthopedic'),
('Anjali', 'Verma', 'Pediatrician'),
('Suresh', 'Patel', 'Neurologist'),
('Deepika', 'Singh', 'Dermatologist');

-- Patients (5 total)
INSERT INTO Patients (FirstName, LastName, DateOfBirth, Gender) VALUES
('Arjun', 'Reddy', '1990-05-15', 'Male'),
('Shalini', 'Gupta', '1985-11-22', 'Female'),
('Vikram', 'Menon', '2002-03-10', 'Male'),
('Pooja', 'Hegde', '1998-07-01', 'Female'),
('Kiran', 'Shetty', '1975-09-28', 'Male');

-- Appointments (10 total)
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

-- Prescriptions (5 total - aligning with some appointments)
INSERT INTO Prescriptions (AppointmentID, Medication, Dosage) VALUES
(1, 'Aspirin', '75mg'),
(2, 'PainRelief Gel', 'Apply liberally'),
(3, 'Paracetamol Syrup', '5ml'),
(4, 'Amitriptyline', '25mg'),
(5, 'Eczema Cream', 'Apply thin layer');

-- Billing (Some paid, some pending)
INSERT INTO Billing (PatientID, Amount, PaymentStatus) VALUES
(1, 1500.00, 'Paid'),
(2, 1800.00, 'Paid'),
(3, 1200.00, 'Pending'),
(4, 1100.00, 'Pending'),
(5, 950.00, 'Paid');
GO

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

-- 5: List doctors and the number of appointments they have (both scheduled and completed)
SELECT d.FirstName, d.LastName, COUNT(a.AppointmentID) AS TotalAppointments
FROM Doctors d
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
GROUP BY d.FirstName, d.LastName;

-- 6: Get the medication and dosage for completed appointments
SELECT p.Medication, p.Dosage
FROM Prescriptions p
JOIN Appointments a ON p.AppointmentID = a.AppointmentID
WHERE a.Status = 'Completed';

-- 7: Find patients with pending bills who had an appointment with a Pediatrician
SELECT DISTINCT pat.FirstName, pat.LastName
FROM Patients pat
JOIN Appointments app ON pat.PatientID = app.PatientID
JOIN Doctors doc ON app.DoctorID = doc.DoctorID
JOIN Billing bill ON pat.PatientID = bill.PatientID
WHERE bill.PaymentStatus = 'Pending' AND doc.Specialization = 'Pediatrician';