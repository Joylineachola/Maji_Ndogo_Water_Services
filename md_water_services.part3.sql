-- An independent auditor was hired and the following was his findings
-- we create a table of his findings and insert values via the Table Data Import wizard
DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);

-- compare the quality scores in the water_quality table to the auditor's scores.

SELECT ar.location_id,
       v.record_id,
       ar.true_water_source_score AS audit_score,
       wq.subjective_quality_score AS employee_score
FROM auditor_report ar -- Joining auditor_report and visits tables based on matching location_id
JOIN visits v 
    ON ar.location_id=v.location_id 
JOIN water_quality wq  -- Joining water_quality table with the result of the previous join based on matching record_id
    ON v.record_id=wq.record_id
WHERE  true_water_source_score != subjective_quality_score
      AND v.visit_count= 1 ;
-- I have found some inconsistencies , the next step is to find the causes of this inconsistencies     
/* I think there are two reasons this can happen.
1. These workers are all humans and make mistakes so this is expected.
2. Unfortunately, the alternative is that someone assigned scores incorrectly on purpose! */
-- This query is massive lets make it a CTE
WITH incorrect_records AS (SELECT ar.location_id,
       v.record_id,
       e.employee_name,
       ar.true_water_source_score AS audit_score,
       wq.subjective_quality_score AS employee_score
FROM auditor_report ar -- Joining auditor_report and visits tables based on matching location_id
JOIN visits v 
    ON ar.location_id=v.location_id 
JOIN water_quality wq  -- Joining water_quality table with the result of the previous join based on matching record_id
    ON v.record_id=wq.record_id
JOIN  employee e
     ON v.assigned_employee_id=e.assigned_employee_id 
WHERE  true_water_source_score != subjective_quality_score
      AND v.visit_count = 1),      
-- Let's calculate how many mistakes each employee made
error_count AS (SELECT employee_name,
       COUNT(*) AS number_of_mistakes
FROM incorrect_records
GROUP BY employee_name)
-- So let's try to find all of the employees who have an above-average number of mistakes.
-- step 1 find the average number of mistakes 
-- step 2 find the employees with above average mistakes usings the results  in step 1 as a subquery
SELECT employee_name,
       number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT 
							    AVG(number_of_mistakes) AS avg_error_count_per_empl
                           FROM error_count);
                           
-- let's clean up this code,we first convert  incorrect_records to a VIEW since we will be using it through out the whole analysis 
DROP VIEW incorrect_records;
CREATE VIEW incorrect_records AS (SELECT ar.location_id,
       v.record_id,
       e.employee_name,
       ar.true_water_source_score AS audit_score,
       wq.subjective_quality_score AS employee_score,
       ar.statements
FROM auditor_report ar -- Joining auditor_report and visits tables based on matching location_id
JOIN visits v 
    ON ar.location_id=v.location_id 
JOIN water_quality wq  -- Joining water_quality table with the result of the previous join based on matching record_id
    ON v.record_id=wq.record_id
JOIN  employee e
     ON v.assigned_employee_id=e.assigned_employee_id 
WHERE  true_water_source_score != subjective_quality_score
      AND v.visit_count = 1);    
-- Let's calculate how many mistakes each employee made
-- Convert error_count to CTE
 WITH error_count AS (SELECT employee_name,
       COUNT(*) AS number_of_mistakes
FROM incorrect_records
GROUP BY employee_name),
-- So let's try to find all of the employees who have an above-average number of mistakes.
-- step 1 find the average number of mistakes 
-- step 2 find the employees with above average mistakes usings the results  in step 1 as a subquery
-- Convert this into a CTE which SELECTS the employees with above−average mistakes
 suspects_list AS(SELECT employee_name,
       number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT 
							    AVG(number_of_mistakes) AS avg_error_count_per_empl
                           FROM error_count))                         
  -- This query filters all of the records where the "corrupt" employees gathered data.                         
SELECT employee_name,
       location_id,
       statements
FROM Incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspects_list)
       AND statements LIKE "%cash%";                  
                           

