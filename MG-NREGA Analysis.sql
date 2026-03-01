/* ============================================================
   DATABASE & TABLE SETUP
   ============================================================ */

CREATE DATABASE NAREGA_DB;
GO

USE NAREGA_DB;
GO

CREATE TABLE mgnrega_data (

    state_name NVARCHAR(100),
    district_name NVARCHAR(100),

    total_jobcards_issued INT,
    total_workers INT,
    total_active_jobcards INT,
    total_active_workers INT,

    sc_active_workers INT,
    st_active_workers INT,

    approved_labour_budget BIGINT,
    persondays_central_liability BIGINT,
    sc_persondays BIGINT,
    st_persondays BIGINT,
    women_persondays BIGINT,

    avg_days_employment_per_household DECIMAL(10,2),
    avg_wage_per_day DECIMAL(10,2),

    households_completed_100_days INT,
    total_households_worked INT,
    total_individuals_worked INT,
    differently_abled_persons_worked INT,

    gps_with_nil_expenditure INT,

    total_works_taken_up INT,
    ongoing_works INT,
    completed_works INT,

    pct_nrm_expenditure DECIMAL(5,2),
    pct_category_b_works DECIMAL(5,2),
    pct_agri_allied_expenditure DECIMAL(5,2),

    total_expenditure_lakhs DECIMAL(18,2),
    wages_expenditure_lakhs DECIMAL(18,2),
    material_skilled_wages_lakhs DECIMAL(18,2),
    admin_expenditure_lakhs DECIMAL(18,2)
);

BULK INSERT mgnrega_data
FROM 'C:/Users/Appa/Downloads/NREGA.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);


/* ============================================================
   JOB CARD ANALYSIS
   ============================================================ */

-- Total Job Cards Issued by Each State
SELECT
    state_name AS State_Name,
    SUM(total_jobcards_issued) AS Total_Job_Cards_Issued
FROM mgnrega_data
GROUP BY state_name
ORDER BY Total_Job_Cards_Issued DESC;


/* ============================================================
   WORKER PARTICIPATION ANALYSIS
   ============================================================ */

-- Active Workers vs Total Workers by State
SELECT
    state_name,
    SUM(total_workers) AS total_workers,
    SUM(total_active_workers) AS total_active_workers,
    CEILING(
        (SUM(total_active_workers) * 1.0 / SUM(total_workers)) * 100
    ) AS percentage_of_active_workers
FROM mgnrega_data
GROUP BY state_name
ORDER BY state_name;

-- SC/ST Distribution Among Active Workers
SELECT
    state_name,
    CAST(ROUND((SUM(sc_active_workers) * 100.0) /
        SUM(total_active_workers), 2) AS FLOAT)
        AS percentage_of_sc_active_workers,
    CAST(ROUND((SUM(st_active_workers) * 100.0) /
        SUM(total_active_workers), 2) AS FLOAT)
        AS percentage_of_st_active_workers
FROM mgnrega_data
GROUP BY state_name
ORDER BY state_name DESC;

-- States Employing Most Differently Abled Workers
SELECT
    state_name,
    SUM(differently_abled_persons_worked)
        AS total_differently_abled_workers
FROM mgnrega_data
GROUP BY state_name
ORDER BY total_differently_abled_workers DESC;


/* ============================================================
   EMPLOYMENT & WAGE ANALYSIS
   ============================================================ */

-- Average Wage Rate per Day (Overall)
SELECT
    CAST(ROUND(AVG(avg_wage_per_day), 2) AS FLOAT)
        AS average_wage_rate_per_day
FROM mgnrega_data;

-- Average Employment Days per Household by State
SELECT
    state_name,
    CEILING(AVG(avg_days_employment_per_household))
        AS avg_days_employment_per_household_per_state
FROM mgnrega_data
GROUP BY state_name
ORDER BY avg_days_employment_per_household_per_state DESC;

-- Households Completing 100 Days of Employment
SELECT
    state_name,
    SUM(households_completed_100_days)
        AS households_completed_100_days
FROM mgnrega_data
GROUP BY state_name
ORDER BY households_completed_100_days DESC;


/* ============================================================
   WORK COMPLETION ANALYSIS
   ============================================================ */

-- Overall Work Status Summary
SELECT
    SUM(total_works_taken_up) AS total_works_taken_up,
    SUM(ongoing_works) AS total_ongoing_works,
    SUM(completed_works) AS total_completed_works
FROM mgnrega_data;

-- States with Highest Completed Works
SELECT
    state_name,
    SUM(completed_works) AS total_completed_works
FROM mgnrega_data
GROUP BY state_name
ORDER BY total_completed_works DESC;

-- Top 5 States with Highest Ongoing Works
SELECT TOP 5
    state_name,
    SUM(ongoing_works) AS total_ongoing_works
FROM mgnrega_data
GROUP BY state_name
ORDER BY total_ongoing_works DESC;

-- Top 5 States by Total Works Taken Up
SELECT TOP 5
    state_name,
    SUM(total_works_taken_up) AS total_works_taken_up
FROM mgnrega_data
GROUP BY state_name
ORDER BY total_works_taken_up DESC;


/* ============================================================
   PERSONDAYS ANALYSIS
   ============================================================ */

-- Overall Social Group Workdays
SELECT
    SUM(sc_persondays) AS sc_workdays,
    SUM(st_persondays) AS st_workdays,
    SUM(women_persondays) AS women_workdays
FROM mgnrega_data;

-- Women Persondays by State
SELECT
    state_name,
    SUM(women_persondays) AS total_women_persondays
FROM mgnrega_data
GROUP BY state_name
ORDER BY total_women_persondays DESC;

-- SC Persondays by State
SELECT
    state_name,
    SUM(sc_persondays) AS total_sc_persondays
FROM mgnrega_data
GROUP BY state_name
ORDER BY total_sc_persondays DESC;

-- ST Persondays by State
SELECT
    state_name,
    SUM(st_persondays) AS total_st_persondays
FROM mgnrega_data
GROUP BY state_name
ORDER BY total_st_persondays DESC;


/* ============================================================
   EXPENDITURE ANALYSIS
   ============================================================ */

-- Top 5 States by Total Expenditure
SELECT TOP 5
    state_name,
    SUM(total_expenditure_lakhs) AS total_expenditure_lakhs
FROM mgnrega_data
GROUP BY state_name
ORDER BY total_expenditure_lakhs DESC;

-- Overall Expenditure Breakdown
SELECT
    SUM(wages_expenditure_lakhs) AS total_wages_expenditure,
    SUM(material_skilled_wages_lakhs) AS total_material_skilled_wages,
    SUM(admin_expenditure_lakhs) AS total_admin_expenditure
FROM mgnrega_data;

-- Expenditure Breakdown by State
SELECT
    state_name,
    SUM(wages_expenditure_lakhs) AS total_wages_expenditure,
    SUM(material_skilled_wages_lakhs) AS total_material_skilled_wages,
    SUM(admin_expenditure_lakhs) AS total_admin_expenditure
FROM mgnrega_data
GROUP BY state_name;


/* ============================================================
   BUDGET & GOVERNANCE ANALYSIS
   ============================================================ */

-- Top 5 States by Approved Labour Budget
SELECT TOP 5
    state_name,
    SUM(approved_labour_budget) AS total_approved_labour_budget
FROM mgnrega_data
GROUP BY state_name
ORDER BY total_approved_labour_budget DESC;

-- Active Job Cards vs Total Expenditure
SELECT
    state_name,
    SUM(total_active_jobcards) AS total_active_jobcards,
    SUM(total_expenditure_lakhs) AS total_expenditure_lakhs
FROM mgnrega_data
GROUP BY state_name;

-- States with Most Gram Panchayats with NIL Expenditure
SELECT
    state_name,
    SUM(gps_with_nil_expenditure) AS total_gps_with_nil_expenditure
FROM mgnrega_data
GROUP BY state_name
ORDER BY total_gps_with_nil_expenditure DESC;

select 
	state_name, 
	cast(round(avg(pct_agri_allied_expenditure),2 ) as float) avg_pct_agri_allied_expenditure 
from mgnrega_data 
group by state_name 
order by avg_pct_agri_allied_expenditure desc;