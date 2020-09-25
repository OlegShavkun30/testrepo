-- 1)  Obtain the names of all physicians that have performed a medical  procedure they have never  been certified to perform.
USE Hospital
GO

DECLARE @v_check  VARCHAR(100)
SET @v_check = (
SELECT phy.Name
FROM Physician phy
WHERE phy.EmployeeID IN
(
SELECT  DISTINCT und.Physician
FROM Undergoes und LEFT JOIN Trained_In tra ON und.Physician = tra.Physician
AND tra.Treatment = und.or_procedure
LEFT JOIN Physician phy ON und.Physician  = phy.EmployeeID
WHERE CertificationDate IS NULL
))
PRINT 'Physician that performed in medical procedure without certification is;' +' ' + @v_check

-- 2) Obtain the names of all physicians that have performed a medical procedure that they are  certified to perform, but such that
-- the procedure was done at a date (Undergoes.Date) after the physician's certification expired (Trained_In.CertificationExpires).
USE Hospital
GO

SELECT phy.Name, phy.EmployeeID
FROM Physician phy
WHERE phy.EmployeeID IN
 (
SELECT  DISTINCT und.Physician
FROM Undergoes und LEFT JOIN Trained_In tra ON und.Physician = tra.Physician
AND tra.Treatment = und.or_procedure
LEFT JOIN Physician phy ON und.Physician  = phy.EmployeeID
WHERE und.DateUndergoes > tra.CertificationExpires
)

-- 3) Obtain the information for appointments where a patient met with a physician other than his/her primary care physician. 
-- Show the following information: Patient name, physician name, nurse name (if any), start and end time of appointment,   
-- examination room  and the name of the patient's primary care physician. 
USE Hospital
GO

SELECT pat.Name AS Pat_Name,phy.Name AS Phy_Name,nur.Name AS Nur_Name,app.Start_time,app.End_time,app.ExaminationRoom,pat.PCP
FROM Appointment app
Full JOIN Patient pat ON app.Patient = pat.SSN
FULL JOIN Physician phy ON  phy.EmployeeID = app.Physician
FULL JOIN Nurse nur ON nur.EmployeeID = app.PrepNurse
WHERE pat.PCP != app.Physician

-- 4) The Patient field in Undergoes is redundant, since we can obtain it from the Stay table. There are no constraints in force
-- to prevent inconsistencies between these two tables. More specifically - the Undergoes table may include a row where the patient
-- ID does not match the one we would obtain from the Stay table. Select all rows from Undergoes that exhibit this inconsistency.

USE Hospital
GO

SELECT sta.StayID ,und.Stay AS Und_Stay_ID, und.Patient AS Und_Patient, sta.Patient AS Stay_Patient
FROM  Undergoes und
LEFT JOIN Stay sta ON und.Stay = sta.StayID
WHERE sta.Patient != und.Patient

-- 5) Obtain the names of all the nurses who have ever been on call for room 123.

USE Hospital
GO

SELECT nur.Name
FROM Nurse nur
WHERE nur.EmployeeID IN
(
SELECT Nurse
FROM On_Call onca
FULL JOIN Room roo ON onca.BlockCode = roo.BlockCode
WHERE roo.RoomNumber = 123
)


-- 6) The hospital has several examination rooms where appointments take place. 
-- Obtain the number of appointments that have taken place in each examination room.

USE Hospital
GO

SELECT ExaminationRoom, COUNT(AppointmentID) AS 'Count'
FROM Appointment
GROUP BY ExaminationRoom

-- 7) Obtain the names of all patients who have been prescribed some medication by their primary care physician.

USE Hospital
GO

SELECT pat.Name
FROM Prescribes pre
FULL JOIN Patient pat ON pre.Patient = pat.SSN
WHERE pre.Physician = pat.PCP

-- 8) Obtain the names of all patients who have been undergone a procedure with a cost larger that $5,000.
 
 USE Hospital
GO

SELECT pat.Name
FROM Patient pat
JOIN Undergoes und ON pat.SSN = und.Patient
WHERE und.or_procedure IN
(
SELECT orpr.Code
FROM or_procedure orpr
WHERE orpr.Cost > 5000
)

-- 9) Obtain the names of all patients who have had at least two appointments. 

USE Hospital
GO

SELECT pat.Name, COUNT(app.AppointmentID) Appointments_CNT 
FROM Appointment app JOIN Patient pat 
ON pat.SSN = app.Patient
GROUP BY Pat.Name
HAVING COUNT(app.AppointmentID) >= 2

-- 10) Obtain the names of all patients which their care physician is not the head of any department. 
USE Hospital
GO

SELECT pat.Name
FROM Patient pat
WHERE pat.PCP NOT IN
(
SELECT dep.Head
FROM Department dep
)
ORDER BY pat.Name