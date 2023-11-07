Problem Statement:
A survey was been successfully completed, resulting in a database of 60,000 records related to water sources and quality. The goal is to make sense of this extensive dataset, extract meaningful insights, and address the water crisis in Maji Ndogo.
---

## Project Summary

This part 1 of the project will focus on analyzing data related to water sources, quality, and pollution to gain insights into various aspects of water services. Below is a summary of the SQL queries and tasks performed in the project:

1. **Listing Tables**:
   - Used `SHOW TABLES` to list all tables in the database.

2. **Exploratory Data Analysis**:
   - Examined the first 10 rows of the `location`, `visits`, and `water_source` tables to get a glimpse of the data.

3. **Analyzing Water Sources**:
   - Obtained distinct types of water sources using the `SELECT DISTINCT` statement to understand the variety of sources.

4. **Queue Time Analysis**:
   - Identified instances where residents had to queue for water for more than 500 minutes by filtering the `visits` table with `time_in_queue > 500`.

5. **Long Queue Water Sources**:
   - Investigated water sources where residents queued for a long time using specific source IDs.

6. **Water Quality Assessment**:
   - Explored the quality of water sources, focusing on records where a water source with a quality score of 10 (home taps) was visited a second time using the `water_quality` table.

7. **Well Pollution Analysis**:
   - Investigated well pollution issues by analyzing the `well_pollution` table. Checked for inconsistencies where 'results' indicate 'Clean' but 'biological' is greater than 0.01.

8. **Data Error Correction**:
   - Copied the `well_pollution` table to `well_pollution_copy` to perform data corrections.
   - Updated the descriptions and results in the copy to ensure data accuracy.
   - If confident in the changes, applied the updates to the original `well_pollution` table and dropped the copy.





