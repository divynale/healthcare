SELECT * FROM healthcare.masterdata;
use healthcare;

-- Total Discharge
CREATE TABLE total_discharge AS 
SELECT DISTINCT(YEAR),
CONCAT(FORMAT(SUM(DIS_TOT)/1000,0),"K")AS TotalDischarge,
CONCAT(FORMAT(SUM(DIS_OTH)/1000,0),"K")AS OtherPayers,
CONCAT(FORMAT(SUM(DIS_INDGNT)/1000,0),"K")AS OtherIndigent,
CONCAT(FORMAT(SUM(DIS_THRD_MC)/1000,0),"K")AS "OtherThirdParties-ManagedCare",
CONCAT(FORMAT(SUM(DIS_THRD)/1000,0),"K")AS "OtherThirdParties-Taditional",
CONCAT(FORMAT(SUM(DIS_CNTY_MC)/1000,0),"K")AS "CountyIndigentPrograms-ManagedCare",
CONCAT(FORMAT(SUM(DIS_CNTY)/1000,0),"K")AS "CountyIndigentPrograms-Traditional",
CONCAT(FORMAT(SUM(DIS_MCAL_MC)/1000,0),"K")AS "Medi-cal-ManagedCare",
CONCAT(FORMAT(SUM(DIS_MCAL)/1000,0),"K")AS "Medi-Cal-Traditional",
CONCAT(FORMAT(SUM(DIS_MCAR_MC)/1000,0),"K")AS "Medicare-ManagedCare",
CONCAT(FORMAT(SUM(DIS_MCAR)/1000,0),"K")AS "Medicare-Traditional"
FROM masterdata
GROUP BY YEAR
ORDER BY YEAR;

-- Patient Days
CREATE TABLE Patientdays AS
SELECT DISTINCT(YEAR),
CONCAT(FORMAT(SUM(DAY_TOT)/1000,0),"K") AS Patient_Days
FROM masterdata
GROUP BY YEAR
ORDER BY YEAR;

-- Net Patient Revenue 
CREATE TABLE net_patient_rev AS
SELECT DISTINCT(YEAR),
CONCAT(FORMAT(SUM(NET_TOT)/1000000,0),"M") AS Net_Patient_Revenue
FROM masterdata
GROUP BY YEAR
ORDER BY YEAR;

-- Revenue Trend
CREATE TABLE Rev_trend AS
SELECT DISTINCT(YEAR),
concat(format(SUM(NET_TOT)/1000000,0),"M") AS Revenue,
CONCAT(ROUND(
	   ((COUNT(NET_TOT)-LAG(COUNT(NET_TOT),1) OVER())/
	   LAG(COUNT(NET_TOT),1)OVER())*100
       ), "%")AS "TREND (%YOY Change)"
FROM masterdata
GROUP BY YEAR
ORDER BY YEAR;

-- State Wise No of hospital /Revenue 
CREATE TABLE Statewise_hosp_rev AS
SELECT 
    COUNTY_NAME, 
    COUNT( FAC_NAME) AS No_of_hospitals, 
    CONCAT(FORMAT(SUM(NET_TOT)/1000000,0),"M") AS Total_Revenue
FROM masterdata
WHERE TYPE_HOSP IN
(SELECT TYPE_HOSP FROM masterdata WHERE TYPE_HOSP='State hospitals')
GROUP BY COUNTY_NAME
ORDER BY COUNTY_NAME;
    
-- Type Of hospital Revenue
CREATE TABLE Type_of_hosp_rev AS
SELECT DISTINCT(YEAR) ,
    CONCAT(FORMAT(SUM(GRIP_TOT)/1000000,0),"M")AS Gross_Inpatient_Revenue,
    CONCAT(FORMAT(SUM(GROP_TOT)/1000000,0),"M")AS Gross_Outpatient_Revenue,
    CONCAT(FORMAT(SUM(CAP_TOT)/1000000,0),"M")AS Capitation_Premium_Revenue,
    CONCAT(FORMAT(SUM(NONOP_REV)/1000000,0),"M")AS Non_Operating_Revenue,
	CONCAT(FORMAT(SUM(OTH_OP_REV)/1000000,0),"M")AS Other_Operating_Revenue,
    CONCAT(FORMAT(SUM(NET_TOT)/1000000,0),"M")AS Net_Patient_Revenue
FROM masterdata
GROUP BY YEAR
ORDER BY YEAR;

-- Total Patients and HOSPITALS
CREATE TABLE total_pat_hosp AS 
SELECT CONCAT(FORMAT(SUM(DIS_TOT + VIS_TOT)/1000000,0),"M") AS Total_patients,
    COUNT(DISTINCT FAC_NAME) AS Total_Hospitals
    FROM masterdata;

-- YTD 
CREATE TABLE YTD AS 
SELECT DISTINCT(YEAR),
    CONCAT(FORMAT(SUM(NET_TOT)/1000000,0),"M") AS YTD
FROM masterdata
GROUP BY YEAR
ORDER BY YEAR;

CREATE TABLE QTD AS 
SELECT DISTINCT(QTR), 
     CONCAT(FORMAT(SUM(NET_TOT)/1000000,0),"M") AS QTD
 FROM masterdata
 GROUP BY QTR
 ORDER BY QTR;

-- custom KPI
-- TOP 3 facilities by Revenue
CREATE TABLE Top3Facility AS 
SELECT FAC_NAME AS 'Facility',
    SUM(NET_TOT) AS 'Revenue' 
 FROM
     masterdata
 GROUP BY Facility
 ORDER BY Revenue DESC
 LIMIT 3;

-- RURAL AND TEACHING HOSPITALS BY REVENUE 
 CREATE TABLE Rural_Teaching_hosp_by_Rev AS 
 SELECT TEACH_RURL AS 'Type',
     COUNT(FAC_NAME) AS 'Hospitals',
     CONCAT(FORMAT(SUM(NET_TOT)/1000000,0),"M") AS 'Revenue' 
 FROM
     masterdata
 GROUP BY Type
 HAVING TEACH_RURL IN("Rural","Teaching");