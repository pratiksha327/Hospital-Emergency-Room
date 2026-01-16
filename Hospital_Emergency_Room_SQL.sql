 
SELECT * FROM Hospital_Emergency_Room 
ALTER TABLE Hospital_Emergency_Room 
DROP COLUMN Patient_Admission_Flag2;

--1. How many patients visit the Emergency Room each day?
SELECT CAST(Patient_Admission_Date AS DATE) as Patient_Admission_date
      ,COUNT(PATIENT_ID) AS Total_Patient
FROM Hospital_Emergency_Room
GROUP BY CAST(Patient_Admission_Date AS DATE)
ORDER BY Patient_Admission_date

--2.What is the average wait time per day?
SELECT CAST(Patient_Admission_Date AS DATE) as Patient_Admission_Date
      ,AVG(Patient_Waittime) as Avg_Wait_Time
FROM Hospital_Emergency_Room
GROUP BY CAST(Patient_Admission_Date AS DATE) 
ORDER BY Patient_Admission_Date

--3.How satisfied are patients on average each day?
SELECT CAST(Patient_Admission_Date AS DATE) as Patient_Admission_Date
      ,AVG(Patient_Satisfaction_Score) as Avg_Patient_Satisfaction_Score
FROM Hospital_Emergency_Room
WHERE Patient_Satisfaction_Score IS NOT NULL
GROUP BY CAST(Patient_Admission_Date AS DATE)
ORDER BY Patient_Admission_Date

--4.How many patients were admitted vs not admitted?
SELECT Patient_Admission_Flag
,COUNT(Patient_Id) as Number_Of_Patient     
FROM Hospital_Emergency_Room
GROUP BY Patient_Admission_Flag

--5.What is the distribution of patients by age group?
SELECT
    CASE 
        WHEN Patient_Age BETWEEN 70 AND 79 THEN '70-79'
        WHEN Patient_Age BETWEEN 60 AND 69 THEN '60-69'
        WHEN Patient_Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Patient_Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Patient_Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Patient_Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN Patient_Age BETWEEN 10 AND 19 THEN '10-19'
        ELSE '0-09'
    END AS Age_Group,
    COUNT(Patient_Id) AS Patient_Count
FROM Hospital_Emergency_Room
GROUP BY
    CASE 
        WHEN Patient_Age BETWEEN 70 AND 79 THEN '70-79'
        WHEN Patient_Age BETWEEN 60 AND 69 THEN '60-69'
        WHEN Patient_Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Patient_Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Patient_Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Patient_Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN Patient_Age BETWEEN 10 AND 19 THEN '10-19'
        ELSE '0-09'
    END
ORDER BY Age_Group;

--6.What percentage of patients were seen within 30 minutes?
SELECT 
    COUNT(Patient_Id) AS Total_Patients,
    SUM(CASE WHEN Patient_Waittime <= 30 THEN 1 ELSE 0 END) AS Seen_Within_30,
    ROUND(
        SUM(CASE WHEN Patient_Waittime <= 30 THEN 1 ELSE 0 END) * 100.0 
        / COUNT(Patient_Id), 2
    ) AS Timeliness_Percentage
FROM Hospital_Emergency_Room

--7.How many patients visited by gender?
  UPDATE Hospital_Emergency_Room
  SET Patient_Gender = 'Female' WHERE Patient_Gender = 'F'

  UPDATE Hospital_Emergency_Room
  SET Patient_Gender = 'Male' WHERE Patient_Gender = 'M'

  SELECT * FROM Hospital_Emergency_Room
  SELECT Patient_Gender
  ,COUNT(Patient_Id) as Number_Of_Patient
  FROM Hospital_Emergency_Room
  GROUP BY Patient_Gender

--8.Which departments receive the most referrals?
WITH CTE AS(
SELECT Department_Referral
,COUNT(Department_Referral) AS Count_Of_Department_Referral
FROM Hospital_Emergency_Room
WHERE  Department_Referral <> 'None'
GROUP BY Department_Referral
)
SELECT Department_Referral,Count_Of_Department_Referral FROM(
                         SELECT Department_Referral , Count_Of_Department_Referral
                        ,ROW_NUMBER() OVER(ORDER BY Count_Of_Department_Referral DESC) AS RN
                         FROM CTE
                         ) X
WHERE X.RN = 1;

--9.What is the racial distribution of ER patients?
SELECT Patient_Race
,COUNT(Patient_Race) as Count_Of_Patient_Race
FROM Hospital_Emergency_Room
GROUP BY Patient_Race
ORDER BY Count_Of_Patient_Race DESC

--10.Are there missing or invalid values?(Data Quality Check)
SELECT
    SUM(CASE WHEN Patient_Waittime IS NULL THEN 1 ELSE 0 END) AS Misiing_Waittime
	,SUM(CASE WHEN Patient_Satisfaction_Score IS NULL THEN 1 ELSE 0 END) AS Misiing_Satisfaction_Score
	,SUM(CASE WHEN Patient_Age < 0 OR Patient_Age > 120 THEN 1 ELSE 0 END) AS Invalid_Age
FROM Hospital_Emergency_Room;

