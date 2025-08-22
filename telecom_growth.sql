--create table in the schema
CREATE TABLE "Nexa_Sat" .nexa_sat(
	 Customer_id VARCHAR(50),
    gender VARCHAR(10),
    Partner VARCHAR(3),
    Dependents VARCHAR(3),
    Senior_Citizen INT,
    Call_Duration FLOAT,
    Data_Usage FLOAT,
    Plan_Type VARCHAR(20),
    Plan_Level VARCHAR(20),
    Monthly_Bill_Amount FLOAT,
    Tenure_Months INT,
    Multiple_Lines VARCHAR(3),
    Tech_Support VARCHAR(3),
    Churn INT);

--confirm current schema
SELECT current_schema();

--set path for queries
SET search_path TO "Nexa_Sat";

--view data
SELECT *
FROM nexa_sat;


-- DATA CLEANING
-- Check for duplicates

SELECT 
    customer_id, 
    gender, 
    partner, 
    dependents,
    senior_citizen, 
    call_duration, 
    data_usage,
    plan_type, 
    plan_level, 
    monthly_bill_amount,
    tenure_months, 
    multiple_lines, 
    tech_support,
    churn
FROM 
    nexa_sat
GROUP BY 
    customer_id, gender, partner, dependents,
    senior_citizen, call_duration, data_usage,
    plan_type, plan_level, monthly_bill_amount,
    tenure_months, multiple_lines, tech_support,
    churn
HAVING 
    COUNT(*) > 1;  -- this filters out rows that are duplicates

--check for null values
SELECT *
FROM nexa_sat
WHERE customer_id IS NULL
OR gender IS NULL
OR partner IS NULL
OR dependents IS NULL
OR senior_citizen IS NULL
OR call_duration IS NULL
OR data_usage IS NULL
OR plan_type IS NULL
OR plan_level IS NULL
OR monthly_bill_amount IS NULL
OR tenure_months IS NULL
OR multiple_lines IS NULL
OR tech_support IS NULL
OR churn IS NULL

-- EDA
-- total users
SELECT COUNT(customer_id) AS current_users
FROM nexa_sat
WHERE churn = 0;

-- total users by level
SELECT plan_level, COUNT(customer_id) AS total_users
FROM nexa_sat
WHERE churn = 0	
GROUP BY 1;

--total revenue
SELECT ROUND(SUM(monthly_bill_amount::numeric), 2) AS revenue
FROM nexa_sat;

-- revenue by plan level
SELECT plan_level, ROUND(SUM(monthly_bill_amount::numeric), 2) AS revenue
FROM nexa_sat
GROUP BY 1
ORDER BY 2;

-- churn count by plan type and plan level
SELECT 
    plan_level,
    plan_type,
    COUNT(*) AS total_customers,
    SUM(churn) AS churn_count
FROM nexa_sat
GROUP BY 1, 2
ORDER BY 1;

-- avg tenure by plan level
SELECT plan_level, ROUND(AVG(tenure_months), 2) AS avg_tenure
FROM nexa_sat
GROUP BY 1;

-- MARKETING SEGMENTS
-- Create table of existing users only
CREATE TABLE existing_users AS
SELECT *
FROM nexa_sat
WHERE churn = 0;

--view new table
SELECT *
FROM existing_users;

-- Calculate ARPU for existing users
SELECT ROUND(AVG(monthly_bill_amount::INT), 2) AS ARPU
FROM existing_users;

-- Calculate CLV and add column
ALTER TABLE existing_users
ADD COLUMN clv FLOAT;

UPDATE existing_users
SET clv = monthly_bill_amount * tenure_months;

-- View new CLV column
SELECT customer_id, clv
FROM existing_users;

-- CLV score
-- monthly_bill =40%, tenure =30%, call_duration =10%, data_usage =10%, premium =10% 
ALTER TABLE existing_users
ADD COLUMN clv_score NUMERIC(10,2);

UPDATE existing_users
SET clv_score = 
	(0.4 * monthly_bill_amount) +
    (0.3 * tenure_months) +
    (0.1 * call_duration) +
    (0.1 * data_usage) +
    (0.1 * CASE WHEN plan_level = 'Premium' THEN 1 ELSE 0 END);

--view new clv score column
SELECT customer_id, clv_score
FROM existing_users;

--group users into segments based on clv_scores
ALTER TABLE existing_users
ADD COLUMN clv_segments VARCHAR;

-- Start of CLV segments update
UPDATE existing_users
SET clv_segments = 
CASE WHEN clv_score > (
        SELECT percentile_cont(0.85)
        WITHIN GROUP (ORDER BY clv_score)
        FROM existing_users
    ) THEN 'High Value'
    
    WHEN clv_score >= (
        SELECT percentile_cont(0.50)
        WITHIN GROUP (ORDER BY clv_score)
        FROM existing_users
    ) THEN 'Moderate Value'
    
    WHEN clv_score >= (
        SELECT percentile_cont(0.25)
        WITHIN GROUP (ORDER BY clv_score)
        FROM existing_users
    ) THEN 'Low Value'

    ELSE 'Churn Risk'
END;

-- View segments
SELECT customer_id, clv, clv_score, clv_segments
FROM existing_users;

--Analyzing The Segments
-- Average bill and tenure per segment
SELECT 
    clv_segments,
    ROUND(AVG(monthly_bill_amount::INT), 2) AS avg_monthly_charges,
    ROUND(AVG(tenure_months::INT), 2) AS avg_tenure
FROM existing_users
GROUP BY 1;

-- Tech support and multiple lines percent
SELECT 
    clv_segments,
    ROUND(AVG(CASE WHEN tech_support = 'Yes' THEN 1 ELSE 0 END), 2) AS tech_support_pct,
    ROUND(AVG(CASE WHEN multiple_lines = 'Yes' THEN 1 ELSE 0 END), 2) AS multiple_line_pct
FROM existing_users
GROUP BY 1;

-- Revenue per segment
SELECT 
    clv_segments,
    COUNT(customer_id),
    CAST(SUM(monthly_bill_amount * tenure_months) AS NUMERIC(10,2)) AS total_revenue
FROM existing_users
GROUP BY 1;

-- CROSS-SELLING AND UP-SELLING

-- Cross-selling: tech support to senior citizens
SELECT customer_id
FROM existing_users
WHERE senior_citizen = 1              -- senior citizens
  AND dependents = 'No'               -- no children or tech-savvy helpers
  AND tech_support = 'No'             -- do not already have this service
  AND (clv_segments = 'Churn Risk' OR clv_segments = 'Low Value');

-- Cross-selling: multiple lines for partners and dependents
SELECT customer_id
FROM existing_users
WHERE multiple_lines = 'No'
  AND (dependents = 'Yes' OR partner = 'Yes')
  AND plan_level = 'Basic';

-- Up-selling: premium discount for basic users with churn risk
SELECT customer_id
FROM existing_users
WHERE clv_segments = 'Churn Risk'
  AND plan_level = 'Basic';

-- Up-selling: basic to premium for longer lock-in period and higher ARPU
SELECT 
    plan_level,
    ROUND(AVG(monthly_bill_amount::INT), 2) AS avg_bill,
    ROUND(AVG(tenure_months::INT), 2) AS avg_tenure
FROM existing_users
WHERE clv_segments = 'High Value'
   OR clv_segments = 'Moderate Value'
GROUP BY plan_level;

-- CREATE STORED PROCEDURE
-- Senior citizens who will be offered tech support
CREATE FUNCTION tech_support_snr_citizens()
RETURNS TABLE (customer_id VARCHAR(50))
AS $$
BEGIN
    RETURN QUERY
    SELECT eu.customer_id
    FROM existing_users eu
    WHERE eu.senior_citizen = 1           -- senior citizens
      AND eu.dependents = 'No'            -- no children or tech savvy helpers
      AND eu.tech_support = 'No'          -- do not already have this service
      AND (eu.clv_segments = 'Churn Risk' 
           OR eu.clv_segments = 'Low Value');
END;
$$ LANGUAGE plpgsql;

-- At-risk customers who will be offered premium discount
CREATE FUNCTION churn_risk_discount()
RETURNS TABLE (customer_id VARCHAR(50))
AS $$
BEGIN
    RETURN QUERY
    SELECT eu.customer_id
    FROM existing_users eu
    WHERE eu.clv_segments = 'Churn Risk'
      AND eu.plan_level = 'Basic';
END;
$$ LANGUAGE plpgsql;

--high usage customers who will be offered a premium upgrade
CREATE FUNCTION high_usage_basic() 
RETURNS TABLE (customer_id VARCHAR(50)) 
AS $$
BEGIN
    RETURN QUERY 
	SELECT ec.customer_id
	FROM existing_customers ec
	WHERE ec.plan_level = 'Basic'
	AND (ec.clv_segment = 'High Value' OR ec.clv_segment = 'Moderate Value')
	AND ec.monthly_bill_amount > 150;
END;
$$ LANGUAGE plpgsql;

-- USE PROCEDURES
SELECT * FROM tech_support_snr_citizens();
SELECT * FROM churn_risk_discount();
SELECT * FROM multiple_lines_offer();
SELECT * FROM high_usage_basic();

select *
from existing_customers




-- USE PROCEDURES
SELECT * FROM tech_support_snr_citizens();

SELECT * FROM churn_risk_discount();

SELECT * FROM multiple_lines_offer();

SELECT * FROM high_usage_basic();


select *
from existing_customers