-- 📌 Doctors Table
CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Specialization VARCHAR(255) NOT NULL,
    ContactNumber VARCHAR(20) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL
);

-- 📌 Patients Table
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    ContactNumber VARCHAR(20),
    Address TEXT NOT NULL
);

-- 📌 Appointments Table
CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATETIME NOT NULL,
    Status ENUM('Scheduled', 'Completed', 'Canceled') NOT NULL DEFAULT 'Scheduled',
    Notes TEXT,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID) ON DELETE CASCADE
);

-- 📌 Prescriptions Table
CREATE TABLE Prescriptions (
    PrescriptionID INT PRIMARY KEY AUTO_INCREMENT,
    AppointmentID INT NOT NULL,
    Medication VARCHAR(255) NOT NULL,
    Dosage VARCHAR(50) NOT NULL,
    Instructions TEXT NOT NULL,
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID) ON DELETE CASCADE
);

-- 📌 Medical Records Table
CREATE TABLE MedicalRecords (
    RecordID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT NOT NULL,
    Diagnosis TEXT NOT NULL,
    TreatmentPlan TEXT NOT NULL,
    RecordDate DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE
);

-- 📌 Billing Table
CREATE TABLE Billing (
    BillID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentStatus ENUM('Pending', 'Paid') NOT NULL DEFAULT 'Pending',
    PaymentDate DATETIME,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE
);

-- 📌 Nurses Table
CREATE TABLE Nurses (
    NurseID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    ContactNumber VARCHAR(20),
    AssignedWard VARCHAR(255) NOT NULL
);

-- 📌 Sample Data for Doctors
INSERT INTO Doctors (FirstName, LastName, Specialization, ContactNumber, Email) VALUES
('John', 'Smith', 'Cardiologist', '9876543210', 'john.smith@hospital.com'),
('Emma', 'Johnson', 'Neurologist', '9876543211', 'emma.johnson@hospital.com'),
('Liam', 'Brown', 'Orthopedic', '9876543212', 'liam.brown@hospital.com'),
('Sophia', 'Davis', 'Pediatrician', '9876543213', 'sophia.davis@hospital.com'),
('Noah', 'Martinez', 'Dermatologist', '9876543214', 'noah.martinez@hospital.com');

-- 📌 Sample Data for Patients
INSERT INTO Patients (FirstName, LastName, DateOfBirth, Gender, ContactNumber, Address) VALUES
('Alice', 'Brown', '1990-05-14', 'Female', '9876543215', '123 Main St, City'),
('David', 'Johnson', '1985-09-22', 'Male', '9876543216', '456 Elm St, City'),
('Emily', 'Davis', '2000-03-10', 'Female', '9876543217', '789 Maple St, City'),
('Daniel', 'Clark', '1975-07-18', 'Male', '9876543218', '101 Pine St, City'),
('Sophia', 'Lewis', '1995-11-25', 'Female', '9876543219', '202 Oak St, City');

-- 📌 Sample Appointments
INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status, Notes) VALUES
(1, 1, '2024-03-15 10:00:00', 'Scheduled', 'Routine checkup'),
(2, 2, '2024-03-16 11:00:00', 'Completed', 'Migraine treatment'),
(3, 3, '2024-03-17 09:30:00', 'Canceled', 'Follow-up for knee pain'),
(4, 4, '2024-03-18 14:00:00', 'Scheduled', 'Pediatric consultation'),
(5, 5, '2024-03-19 15:45:00', 'Scheduled', 'Skin allergy treatment');

-- 📌 Sample Prescriptions
INSERT INTO Prescriptions (AppointmentID, Medication, Dosage, Instructions) VALUES
(1, 'Aspirin', '100mg', 'Take one tablet daily after breakfast'),
(2, 'Ibuprofen', '200mg', 'Take one tablet every 6 hours as needed'),
(3, 'Amoxicillin', '500mg', 'Take one capsule twice a day for 7 days'),
(4, 'Paracetamol', '500mg', 'Take one tablet every 4 hours for fever'),
(5, 'Cetirizine', '10mg', 'Take one tablet before bed for allergies');

-- 📌 Sample Medical Records
INSERT INTO MedicalRecords (PatientID, Diagnosis, TreatmentPlan, RecordDate) VALUES
(1, 'Hypertension', 'Prescribed medication and lifestyle changes', '2024-03-15 11:00:00'),
(2, 'Migraine', 'Pain management and stress reduction therapy', '2024-03-16 12:30:00'),
(3, 'Knee Arthritis', 'Physiotherapy and pain relief medication', '2024-03-17 10:30:00'),
(4, 'Common Cold', 'Rest and hydration', '2024-03-18 15:00:00'),
(5, 'Skin Allergy', 'Antihistamines and avoiding allergens', '2024-03-19 16:00:00');

-- 📌 Advanced Queries

-- 1️⃣ Find all doctors with more than 2 scheduled appointments
SELECT d.FirstName, d.LastName, COUNT(a.AppointmentID) AS TotalAppointments
FROM Doctors d
JOIN Appointments a ON d.DoctorID = a.DoctorID
WHERE a.Status = 'Scheduled'
GROUP BY d.DoctorID, d.FirstName, d.LastName
HAVING COUNT(a.AppointmentID) > 2;

-- 2️⃣ Find all patients who have unpaid bills
SELECT p.FirstName, p.LastName, b.Amount, b.PaymentStatus
FROM Patients p
JOIN Billing b ON p.PatientID = b.PatientID
WHERE b.PaymentStatus = 'Pending';

-- 3️⃣ Get all completed appointments along with doctor and patient names
SELECT a.AppointmentID, p.FirstName AS PatientName, d.FirstName AS DoctorName, a.AppointmentDate
FROM Appointments a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID
WHERE a.Status = 'Completed';

-- 4️⃣ Find the most prescribed medication
SELECT Medication, COUNT(*) AS PrescriptionCount
FROM Prescriptions
GROUP BY Medication
ORDER BY PrescriptionCount DESC
LIMIT 1;

-- 📌 Stored Procedure: Count Scheduled Appointments for a Doctor
DELIMITER //
CREATE PROCEDURE CountScheduledAppointments(IN doctorID INT)
BEGIN
    SELECT COUNT(*) AS TotalScheduled
    FROM Appointments
    WHERE DoctorID = doctorID AND Status = 'Scheduled';
END //
DELIMITER ;

-- Call the stored procedure to count appointments for a specific doctor
CALL CountScheduledAppointments(1);
