-- Active: 1699367294742@@127.0.0.1@3306@md_water_services
-- List all tables in the database
SHOW TABLES;

-- Get a glimpse of the location data (first 10 rows)

SELECT *
FROM location
LIMIT 10;
-- Get a glimpse of the visits data (first 10 rows)
SELECT *
FROM visits
LIMIT 10;

-- Get a glimpse of the water_source data (first 10 rows)

SELECT *
FROM water_source
LIMIT 10;

-- List distinct types of water sources to understand the variety

SELECT distinct type_of_water_source
FROM water_source;

-- Check residents' queue time for water exceeding 500 minutes
SELECT *
FROM visits 
WHERE time_in_queue>500;

-- Identify the water sources where residents queue for a long time

SELECT*
FROM water_source
WHERE source_id IN ('AkKi00881224' ,
                     'AkLu01628224',
                     'AkRu05234224',
                     'HaRu19601224',
                     'HaZa21742224',
                     'SoRu36096224',
                     'SoRu37635224',
                     'SoRu38776224');
                     
-- Assess the quality of water sources:
/*We have quality scores assigned by surveyors ranging from 1 (terrible) to 10 (excellent) for different water sources, 
with home taps rated higher.We want to investigate if there are any records where a water source with a quality score of 10 (home taps)
was visited a second time.*/

SELECT*
FROM water_quality
WHERE subjective_quality_score= 10 -- Looking for home taps with a quality score of 10
       AND visit_count = 2; -- Find records where the water source was visited a second time.

-- The results are expected to provide insights into whether there are any unexpected multiple visits to good water sources,
-- and if so, this might indicate data quality issues that need further investigation.


-- Investigate well pollution issues
SELECT*
FROM well_pollution;

/*The water quality of all wells is categorized  as Clean, Contaminated: Biological,or Contaminated: Chemical,based on the presence of biological contaminants or chemical pollutants.
 This information is crucial for assessing the safety of these wells for drinking water.*/

-- This query checks if there are records where the 'results' indicate 'Clean' but the 'biological' column is greater than 0.01.
-- 0.01 indicate that the source is clean anything above that is contaminated
SELECT *
FROM well_pollution
WHERE results = 'Clean' AND biological > 0.01;

-- Retrieve rows where the "description" column contains the word "Clean" anywhere within the text and biological is greater than one
SELECT*
FROM well_pollution
WHERE description LIKE "%Clean%"
     AND biological > 0.01;
     
-- we need to make changes to this error , we start by making a copy of well_populatin
CREATE TABLE well_pollution_copy(
SELECT*
FROM well_pollution);

-- update the columns in the copy first to ensure it works correctly
UPDATE
well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description= 'Clean Bacteria: E. coli';

UPDATE
well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description= 'Clean Bacteria: Giardia Lamblia';

UPDATE
well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01 AND results = 'Clean';

-- if we're sure it works as intended, we change the table back to the well_pollution and delete the well_pollution_copy table.

UPDATE
well_pollution
SET description = 'Bacteria: E. coli'
WHERE description= 'Clean Bacteria: E. coli';

UPDATE
well_pollution
SET description = 'Bacteria: Giardia Lamblia'
WHERE description= 'Clean Bacteria: Giardia Lamblia';

UPDATE
well_pollution
SET results = 'Contaminated: Biological'
WHERE biological > 0.01 AND results = 'Clean';


DROP TABLE
md_water_services.well_pollution_copy;


                     