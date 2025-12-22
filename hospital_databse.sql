-- CREATE DATABASE 
CREATE DATABASE IF NOT EXISTS hospital;

-- use database
use hospital;

-- create tables

-- 1.create department table
CREATE TABLE departments(
departmentID INTEGER PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL
);

-- 2.create doctor table
CREATE TABLE doctors(
doctor_id INTEGER PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL,
specialization VARCHAR(100) NOT NULL,
role VARCHAR(100) NOT NULL,
departmentID INTEGER,
FOREIGN KEY(departmentID) REFERENCES departments(departmentID)
);

-- 3.create patients table
CREATE TABLE patients(
patient_id INTEGER PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL,
date_of_birth DATE,
gender VARCHAR(50) NOT NULL,
phone_number VARCHAR(50),
CHECK(gender in('M','F','O'))
);

-- 4.create appointment table
CREATE TABLE appointments(
appointment_id INTEGER PRIMARY KEY AUTO_INCREMENT,
patient_id INTEGER,
doctor_id INTEGER,
time DATETIME,
status VARCHAR(50),
FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
CHECK(status in('Scheduled','Completed','Cancelled'))
);

-- 5. prescription table
CREATE TABLE prescription(
prescriptio_id INTEGER PRIMARY KEY AUTO_INCREMENT,
appointment_id INTEGER,
medication VARCHAR(100),
dosage VARCHAR(50),
FOREIGN KEY(appointment_id) REFERENCES appointments(appointment_id)
);

-- 6.create bill tables
CREATE TABLE bill(
bill_id INTEGER PRIMARY KEY AUTO_INCREMENT,
appointment_id INTEGER,
amount DECIMAL(10,2),
date datetime DEFAULT CURRENT_TIMESTAMP,
paid TINYINT(1),
FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);

-- 7.create labreport table
CREATE TABLE labreports(
lab_id INTEGER PRIMARY KEY AUTO_INCREMENT,
appointment_id INTEGER,
report_data TEXT,
create_date DATETIME DEFAULT CURRENT_TIMESTAMP ,
FOREIGN KEY(appointment_id) REFERENCES appointments(appointment_id)
);

-- insretion of data

-- 1.Insert Into Department
INSERT INTO hospital.departments(departmentID,name)
select `Departments.DepartmentID`, `Departments.Name` from hospital_data
where `Departments.DepartmentID` <> '';

-- 2.Insert Into Doctors
INSERT INTO hospital.doctors(doctor_id,name,specialization,role,departmentID)
select `Doctors.DoctorID`, `Doctors.Name`,
`Doctors.Specialization`, 
`Doctors.Role`,`Doctors.DepartmentID`from hospital_data
where `Doctors.DepartmentID` <> '';

-- 3.Insert Into patients
INSERT INTO hospital.patients(patient_id,name,date_of_birth,gender,phone_number)
select `Patients.PatientID`,`Patients.Name`,STR_TO_DATE(`Patients.DateOfBirth`,'%d-%m-%Y'),
`Patients.Gender`,`Patients.Phone` from hospital_data
where `Patients.PatientID`<>'';

-- 4.Insert Into Appointments
INSERT INTO hospital.appointments(appointment_id,patient_id,doctor_id,time,status)
select `Appointments.AppointmentID`,`Appointments.PatientID`,`Appointments.DoctorID`,
STR_TO_DATE(`Appointments.AppointmentTime`,'%d-%m-%Y %H:%i'),
`Appointments.Status`from hospital_data;

-- 5.Insert Into Prescription
INSERT INTO hospital.prescription(prescriptio_id,appointment_id,medication,dosage)
select`Prescriptions.PrescriptionID`,
`Prescriptions.AppointmentID`,
`Prescriptions.Medication`,
`Prescriptions.Dosage`from hospital_data
where `Prescriptions.PrescriptionID` <> '';

-- 6.Inert Into bill 
INSERT INTO bill(bill_id,appointment_id,amount,date,paid)
select`Bills.BillID`,
`Bills.AppointmentID`,
`Bills.Amount`,
`Bills.BillDate`,`Bills.Paid`
from hospital_data
where `Bills.BillID`<>'';

-- 7.Insert Into labreports
INSERT INTO labreports(lab_id,appointment_id,report_data,create_date)
select`LabReports.ReportID`,`LabReports.AppointmentID`,
`LabReports.ReportData`,
`LabReports.CreatedAt`from hospital_data
where `LabReports.ReportID`<>'';



-- Create trigger for doctor appointment

DELIMITER $$
CREATE TRIGGER CHECK_APPOINTMENT
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
	IF NEW.time < NOW() THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Error:Appointment cannot be in the past.';
	END IF ;
    
    IF EXISTS
	  (
		SELECT * FROM appointments
        WHERE doctor_id=NEW.doctor_id
        AND time=NEW.time
        AND status in ('Schedule')
	  ) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT='Error:Doctor already has an appointment at this time.';
    END IF ;
END $$
DELIMITER ;

-- Access information for patients
DELIMITER $$
CREATE PROCEDURE veiw_doctor_data(IN input_username VARCHAR(100),IN input_password VARCHAR(100))
BEGIN 
	DECLARE doc_role VARCHAR(100);
    DECLARE doc_dept VARCHAR(100);
    DECLARE doc_id INTEGER;
    
    -- check doctor credentials
    SELECT doctor_id into doc_id FROM doctor_credentials
    WHERE user_name=input_username AND password=input_password;
    
    -- check role and department
    SELECT role,departmentID 
    into doc_role,doc_dept FROM doctors
    WHERE doctor_id=doc_id;
    
    -- show patient data
    IF doc_role='senior' THEN
		SELECT p.patient_id,p.name as 'patient_name',p.gender,
        a.time,p1.medication,l.report_data
		FROM patients p
		INNER JOIN appointments a
		on p.patient_id=a.patient_id
		LEFT JOIN prescription p1
		on p1.appointment_id=a.appointment_id
		LEFT JOIN labreports l
		on l.appointment_id=a.appointment_id
		LEFT JOIN doctors d
		on d.doctor_id=a.doctor_id
		WHERE departmentID=doc_dept;
	ELSE
		SELECT p.patient_id,p.name as 'patient_name',p.gender,
        a.time,p1.medication,l.report_data
		FROM patients p
		INNER JOIN appointments a
		on p.patient_id=a.patient_id
		LEFT JOIN prescription p1
		on p1.appointment_id=a.appointment_id
		LEFT JOIN labreports l
		on l.appointment_id=a.appointment_id
        WHERE a.doctor_id=doc_id;
	END IF ;
END $$
DELIMITER ;

-- Reporting for monthlY revenue of year
DELIMITER $$
CREATE PROCEDURE monthly_revenue(In input_year INT,IN input_month INT)
BEGIN
SELECT d1.name,sum(b.amount) as total_revenue FROM bill b
JOIN appointments a
on b.appointment_id=a.appointment_id
JOIN doctors d
on d.doctor_id=a.doctor_id
JOIN departments d1
on d1.departmentID=d.departmentID
WHERE MONTH(b.date)=input_month AND YEAR(b.date)=input_year
group by d1.name;
END $$
DELIMITER ;
