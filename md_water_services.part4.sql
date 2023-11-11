-- Are there any specific provinces, or towns where some sources are more abundant?
 -- This view assembles data from different tables into one to simplify analysis
CREATE VIEW combined_analysis_table AS 
SELECT
            water_source.type_of_water_source AS source_type,
            location.town_name,
			location.province_name,
            location.location_type,
            water_source.number_of_people_served AS people_served,
            visits.time_in_queue,
            well_pollution.results
FROM visits
LEFT JOIN well_pollution -- Ensures that all records from the 'visits' table are included, even if there is no match in the 'well_pollution' table.
          ON well_pollution.source_id = visits.source_id
INNER JOIN location
          ON location.location_id = visits.location_id
INNER JOIN water_source
          ON water_source.source_id = visits.source_id
WHERE visits.visit_count = 1;

-- break down our data into provinces or towns and source types
WITH province_totals AS (-- This CTE calculates the population of each province
SELECT province_name,
       SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name)
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated

SELECT  ct.province_name,
        ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
		ROUND((SUM(CASE WHEN source_type = 'shared_tap'THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
        ROUND((SUM(CASE WHEN source_type = 'tap_in_home'THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
        ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
		ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN province_totals pt
     ON ct.province_name = pt.province_name
GROUP BY  ct.province_name
ORDER BY ct.province_name;

-- Let's aggregate the data per town now.
-- The CTE calculates the population of each town
-- Then create a temporary table
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (
SELECT province_name, 
       town_name, 
       SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name)

SELECT ct.province_name,
       ct.town_name,
       ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
       ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
       ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
       ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
       ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN town_totals tt -- Since the town names are not unique, we have to join on a composite key
     ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY ct.province_name, ct.town_name  -- We group by province first, then by town.
ORDER BY ct.town_name;

-- This query calculates  and rounds the percentage of broken taps in homes

SELECT  province_name,
        town_name,
        ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *100,0) AS Pct_broken_taps
FROM town_aggregated_water_access;

-- We have a plan to improve the water access in Maji Ndogo
-- create a table where our teams have the information they need to fix, upgrade and repair water sources.
CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
Address VARCHAR(50),
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50),
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
Date_of_completion DATE,
Comments TEXT
);
-- we build a query to add data into this table
DROP TABLE project_progress;
CREATE TABLE project_progress AS
SELECT
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    well_pollution.results,
    CASE
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV filter'
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
        WHEN water_source.type_of_water_source = 'shared_tap'THEN CONCAT("Install ", FLOOR(time_in_queue / 30), " taps nearby")
        WHEN type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
        ELSE NULL
    END AS Improvement
FROM water_source
LEFT JOIN well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN visits ON water_source.source_id = visits.source_id
INNER JOIN location ON location.location_id = visits.location_id
WHERE visits.visit_count = 1
      AND (
          results != 'Clean'
          OR type_of_water_source IN ('tap_in_home_broken', 'river')
          OR type_of_water_source='shared_tap' AND time_in_queue >=30);