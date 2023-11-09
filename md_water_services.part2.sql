-- employees emails have not been added in employees table,lets update this 
-- Step 1: Selecting the employee_name column

SELECT employee_name
FROM employee;

-- Step 2: Replace the space with a full stop and making it lowercase then concat "@ndogowater.gov"
SELECT 
     CONCAT(
           LOWER(REPLACE(employee_name,' ','.')),'@ndogowater.gov')
FROM md_water_services.employee;

-- Step 3: Update the database with the new email addresses

UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),'@ndogowater.gov');

-- The phone numbers should be 12 characters long consisting of the plus sign, area code (99), and the phone number digits.
SELECT  LENGTH(phone_number)
FROM employee;

-- It returns 13 characters, indicating there's an extra character,lets remove the leading or trailing spaces and then update the table
SELECT  TRIM(phone_number)
FROM employee;

UPDATE employee
SET phone_number=TRIM(phone_number);

-- count number of employees in each town
SELECT town_name ,
       COUNT(*) AS  employees_per_town      
FROM employee
GROUP BY town_name ;

-- Let's first look at the number of records each employee collected.

SELECT assigned_employee_id,
	    COUNT(*) AS number_of_records
FROM md_water_services.visits
GROUP BY assigned_employee_id
ORDER BY number_of_records DESC;

-- This query counts the number of records per town
SELECT town_name,
       COUNT(*) AS records_per_town       
FROM md_water_services.location
GROUP BY town_name;

-- This query counts the number of records per province

SELECT province_name,
       COUNT(*) AS records_per_province      
FROM md_water_services.location
GROUP BY province_name ;

-- This query counts the number of records per province per town
SELECT 
   province_name,
   town_name,
   COUNT(*) AS records_per_town
FROM location
GROUP BY province_name, town_name
ORDER BY province_name, records_per_town DESC;

-- the number of records for each location type
SELECT location_type,
       COUNT(*) AS number_of_records
FROM location
GROUP BY location_type;

-- This query finds the total number of people surveyed
SELECT  SUM(number_of_people_served) AS total_number_surveyed
FROM md_water_services.water_source;

-- This query finds the total number of each water source surveyed
SELECT  type_of_water_source,
		COUNT(*) AS number_of_sources
FROM md_water_services.water_source
GROUP BY type_of_water_source;

-- This query find the rounded average number of people served by each water source surveyed
SELECT  type_of_water_source,
		ROUND(AVG(number_of_people_served)) AS avg_people_per_source
FROM md_water_services.water_source
GROUP BY type_of_water_source;

-- This query finds the total number of people served by each source type and orders it in descending order
SELECT  type_of_water_source,
		SUM(number_of_people_served) AS sum_people_per_source
FROM md_water_services.water_source
GROUP BY type_of_water_source
ORDER BY  sum_people_per_source DESC;

-- let us now find the percentage of people served per source type and order the results 
SELECT  type_of_water_source,
		ROUND((SUM(number_of_people_served)/27628140)*100,0) AS sum_people_per_source
FROM md_water_services.water_source
GROUP BY type_of_water_source
ORDER BY  sum_people_per_source DESC;

-- now we rank each type of source based on how many people in total use it
SELECT  type_of_water_source,
		SUM(number_of_people_served) AS sum_people_per_source,
        RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS rank_by_population_served
FROM md_water_services.water_source
GROUP BY type_of_water_source
ORDER BY  sum_people_per_source DESC;

-- This query ranks the sources depending on the number of people served

SELECT  source_id,
         type_of_water_source,
         number_of_people_served,
         RANK () OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_rank
FROM md_water_services.water_source;

-- Lets find out how long the survey took in days

SELECT 
      TIMESTAMPDIFF(DAY,"2021-01-01 09:10:00","2023-07-14 13:53:00") AS survey_duration
FROM md_water_services.visits;

-- This query calculates the average  time  that one waits in queue for water and replaces zeros with null
SELECT 
      ROUND(AVG(NULLIF(time_in_queue,0)),0) AS avg_time_in_queue
FROM md_water_services.visits;

-- Finding the average queue time on different days
-- Select the day of the week and calculate the average queue time in minutes then Group the results by day of the week
SELECT 
    DAYNAME(time_of_record) AS day_of_week,
    ROUND(AVG(NULLIF(time_in_queue, 0))) AS average_queue_time_minutes
FROM md_water_services.visits
GROUP BY day_of_week;

-- We can also look at what time during the day people collect water.
SELECT TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
       ROUND(AVG(NULLIF(time_in_queue,0))) AS average_queue_time_minutes
FROM md_water_services.visits
GROUP BY hour_of_day
ORDER BY hour_of_day ;

-- We now break down the queue times for each hour of each day
SELECT 
     TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    ROUND(AVG(CASE
         WHEN DAYNAME(time_of_record) ="Sunday" THEN time_in_queue
         ELSE NULL
   END),0)AS sunday,
   
ROUND(AVG(CASE
         WHEN DAYNAME(time_of_record) ="Monday" THEN time_in_queue
         ELSE NULL
END),0)AS Monday,

ROUND(AVG(CASE
         WHEN DAYNAME(time_of_record) ="Tuesday" THEN time_in_queue
         ELSE NULL
END),0)AS Tuesday,

ROUND(AVG(CASE
         WHEN DAYNAME(time_of_record) ="Wednesday" THEN time_in_queue
         ELSE NULL
END),0)AS Wednesday,

ROUND(AVG(CASE
         WHEN DAYNAME(time_of_record) ="Thursday" THEN time_in_queue
         ELSE NULL
END),0)AS Thursday,

ROUND(AVG(CASE
         WHEN DAYNAME(time_of_record) ="Friday" THEN time_in_queue
         ELSE NULL
END),0)AS Friday,

ROUND(AVG(CASE
     WHEN DAYNAME(time_of_record)='saturday' THEN time_in_queue
     ELSE NULL 
     END),0) AS saturday
  
FROM md_water_services.visits
WHERE time_in_queue !=0  
GROUP BY hour_of_day
ORDER BY hour_of_day;   


