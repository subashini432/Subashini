-- ================================================
-- UK ROAD SAFETY 2024 — DATA ANALYSIS
-- Analyst: Subashini 
-- Date: May 2026
-- Data Source: UK Department for Transport
-- Website: data.gov.uk
-- ================================================

create database road_safety;
use road_safety;

-- ================================================
-- SECTION 1: DATA VERIFICATION
-- Confirm all 3 tables imported correctly
-- ================================================
SELECT COUNT(*) as total_collisions FROM collisions;
SELECT COUNT(*) as total_casualties FROM casualties;
SELECT COUNT(*) as total_vehicles FROM vehicles;

-- ================================================
-- SECTION 2: DATA EXPLORATION
-- First look at each table
-- ================================================
-- See first 5 rows of collisions
SELECT * FROM collisions LIMIT 5;

-- See first 5 rows of casualties
SELECT * FROM casualties LIMIT 5;

-- See first 5 rows of vehicles
SELECT * FROM vehicles LIMIT 5;

-- ================================================
-- SECTION 3: DATA CLEANING & VALIDATION
-- Check data quality before analysis
-- ================================================
 
-- Check for NULL values in important columns
SELECT
    SUM(CASE WHEN collision_severity IS NULL THEN 1 ELSE 0 END) as null_severity,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) as null_date,
    SUM(CASE WHEN time IS NULL THEN 1 ELSE 0 END) as null_time,
    SUM(CASE WHEN road_type IS NULL THEN 1 ELSE 0 END) as null_road_type,
    SUM(CASE WHEN speed_limit IS NULL THEN 1 ELSE 0 END) as null_speed_limit,
    SUM(CASE WHEN urban_or_rural_area IS NULL THEN 1 ELSE 0 END) as null_urban_rural
FROM collisions;
-- Result: All zeros — no NULL values found in key columns
-- Data quality confirmed as complete for these fields
 
-- Check for invalid speed limits
-- Valid UK speed limits: 20, 30, 40, 50, 60, 70 mph only
SELECT speed_limit, COUNT(*) as total
FROM collisions
GROUP BY speed_limit
ORDER BY speed_limit;
-- Finding: 3 records have speed limit = -1 (invalid)
-- Action: These 3 records excluded from speed limit analysis only
 
-- Check age of casualties for invalid values
SELECT
    MIN(age_of_casualty) as min_age,
    MAX(age_of_casualty) as max_age,
    SUM(CASE WHEN age_of_casualty < 0 THEN 1 ELSE 0 END) as negative_ages,
    SUM(CASE WHEN age_of_casualty > 100 THEN 1 ELSE 0 END) as over_100
FROM casualties;
-- Finding: 2,552 records have age = -1 (not recorded at scene)
-- Finding: No casualties over 100 years — no extreme outliers
-- Action: Records with age = -1 excluded from age-based analysis only
 
-- Confirm invalid age count vs valid age count
SELECT
    SUM(CASE WHEN age_of_casualty = -1 THEN 1 ELSE 0 END) as invalid_ages,
    SUM(CASE WHEN age_of_casualty >= 0 THEN 1 ELSE 0 END) as valid_ages,
    COUNT(*) as total
FROM casualties;
-- Invalid ages = 2,552 (2% of total) — acceptable for real world data
 
-- Check for duplicate collision records
SELECT collision_index, COUNT(*) as duplicate_count
FROM collisions
GROUP BY collision_index
HAVING COUNT(*) > 1;
-- Expected: No results = no duplicates found
 
 
-- ================================================
-- SECTION 4: OVERALL KPI SUMMARY
-- Key numbers for executive dashboard
-- ================================================
 
SELECT
    COUNT(*) as total_accidents,
    SUM(number_of_casualties) as total_casualties,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) as total_fatal,
    SUM(CASE WHEN collision_severity = 2 THEN 1 ELSE 0 END) as total_serious,
    SUM(CASE WHEN collision_severity = 3 THEN 1 ELSE 0 END) as total_slight,
    ROUND(SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as fatal_percentage,
    ROUND(SUM(CASE WHEN collision_severity = 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as serious_percentage,
    ROUND(SUM(CASE WHEN collision_severity = 3 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as slight_percentage
FROM collisions;
 
 
-- ================================================
-- SECTION 5: BUSINESS QUESTION 1
-- What is the breakdown of accident severity?
-- ================================================
 
SELECT
    CASE collision_severity
        WHEN 1 THEN 'Fatal'
        WHEN 2 THEN 'Serious'
        WHEN 3 THEN 'Slight'
    END as severity_type,
    COUNT(*) as total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM collisions), 2) as percentage
FROM collisions
GROUP BY collision_severity
ORDER BY total DESC;
 
 
-- ================================================
-- SECTION 6: BUSINESS QUESTION 2
-- Which day of week has the most accidents?
-- ================================================
 
SELECT
    CASE day_of_week
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END as day_name,
    COUNT(*) as total_accidents,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) as fatal,
    SUM(CASE WHEN collision_severity = 2 THEN 1 ELSE 0 END) as serious,
    SUM(CASE WHEN collision_severity = 3 THEN 1 ELSE 0 END) as slight
FROM collisions
GROUP BY day_of_week
ORDER BY total_accidents DESC;
 
 
-- ================================================
-- SECTION 7: BUSINESS QUESTION 3
-- Urban vs Rural — where are accidents more severe?
-- ================================================
 
SELECT
    CASE urban_or_rural_area
        WHEN 1 THEN 'Urban'
        WHEN 2 THEN 'Rural'
        WHEN 3 THEN 'Urban or Rural'
    END as area_type,
    COUNT(*) as total_accidents,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) as fatal,
    SUM(CASE WHEN collision_severity = 2 THEN 1 ELSE 0 END) as serious,
    SUM(CASE WHEN collision_severity = 3 THEN 1 ELSE 0 END) as slight,
    ROUND(SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as fatal_percentage
FROM collisions
GROUP BY urban_or_rural_area
ORDER BY total_accidents DESC;
-- Note: 3 records with area code 3 labelled as Urban or Rural
-- These represent unclassified locations = 0.003% of total data
 
 
-- ================================================
-- SECTION 8: BUSINESS QUESTION 4
-- Which road type causes the most accidents and casualties?
-- ================================================
 
SELECT
    CASE road_type
        WHEN 1 THEN 'Roundabout'
        WHEN 2 THEN 'One way street'
        WHEN 3 THEN 'Dual carriageway'
        WHEN 6 THEN 'Single carriageway'
        WHEN 7 THEN 'Slip road'
        WHEN 9 THEN 'Unknown'
        WHEN 12 THEN 'One way street'
        ELSE 'Other'
    END as road_type_name,
    COUNT(*) as total_accidents,
    SUM(number_of_casualties) as total_casualties,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) as fatal_accidents,
    ROUND(AVG(number_of_casualties), 2) as avg_casualties_per_accident
FROM collisions
GROUP BY road_type
ORDER BY total_accidents DESC;
 
 
-- ================================================
-- SECTION 9: BUSINESS QUESTION 5
-- What time of day is most dangerous?
-- ================================================
 
SELECT
    CASE HOUR(time)
        WHEN 0 THEN '12 AM'
        WHEN 1 THEN '1 AM'
        WHEN 2 THEN '2 AM'
        WHEN 3 THEN '3 AM'
        WHEN 4 THEN '4 AM'
        WHEN 5 THEN '5 AM'
        WHEN 6 THEN '6 AM'
        WHEN 7 THEN '7 AM'
        WHEN 8 THEN '8 AM'
        WHEN 9 THEN '9 AM'
        WHEN 10 THEN '10 AM'
        WHEN 11 THEN '11 AM'
        WHEN 12 THEN '12 PM'
        WHEN 13 THEN '1 PM'
        WHEN 14 THEN '2 PM'
        WHEN 15 THEN '3 PM'
        WHEN 16 THEN '4 PM'
        WHEN 17 THEN '5 PM'
        WHEN 18 THEN '6 PM'
        WHEN 19 THEN '7 PM'
        WHEN 20 THEN '8 PM'
        WHEN 21 THEN '9 PM'
        WHEN 22 THEN '10 PM'
        WHEN 23 THEN '11 PM'
    END as time_of_day,
    COUNT(*) as total_accidents,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) as fatal,
    SUM(CASE WHEN collision_severity = 2 THEN 1 ELSE 0 END) as serious
FROM collisions
WHERE time IS NOT NULL
AND time != '00:00'
GROUP BY HOUR(time), time_of_day
ORDER BY HOUR(time);
 
 
-- ================================================
-- SECTION 10: BUSINESS QUESTION 6
-- Which age group is most involved in road accidents as a driver?
-- Note: UK minimum driving age is 17
-- Age bands 1,2,3 (ages 0-15) excluded as invalid for drivers
-- ================================================
 
SELECT
    CASE v.age_band_of_driver
        WHEN 4 THEN '16 to 20'
        WHEN 5 THEN '21 to 25'
        WHEN 6 THEN '26 to 35'
        WHEN 7 THEN '36 to 45'
        WHEN 8 THEN '46 to 55'
        WHEN 9 THEN '56 to 65'
        WHEN 10 THEN '66 to 75'
        WHEN 11 THEN 'Over 75'
        ELSE 'Unknown'
    END as age_group,
    COUNT(*) as total_drivers_involved,
    SUM(CASE WHEN c.collision_severity = 1 THEN 1 ELSE 0 END) as in_fatal_accidents
FROM vehicles v
JOIN collisions c ON v.collision_index = c.collision_index
WHERE v.age_band_of_driver >= 4
GROUP BY v.age_band_of_driver
ORDER BY total_drivers_involved DESC;
 
 
-- ================================================
-- SECTION 11: BUSINESS QUESTION 7
-- Which age group had the most deaths? (all road users)
-- Note: All ages valid here — includes passengers,
-- pedestrians, cyclists, children
-- ================================================
 
-- Fatal casualties by age group
SELECT
    CASE cas.age_band_of_casualty
        WHEN 1 THEN '0 to 5'
        WHEN 2 THEN '6 to 10'
        WHEN 3 THEN '11 to 15'
        WHEN 4 THEN '16 to 20'
        WHEN 5 THEN '21 to 25'
        WHEN 6 THEN '26 to 35'
        WHEN 7 THEN '36 to 45'
        WHEN 8 THEN '46 to 55'
        WHEN 9 THEN '56 to 65'
        WHEN 10 THEN '66 to 75'
        WHEN 11 THEN 'Over 75'
        ELSE 'Unknown'
    END as age_group,
    COUNT(*) as total_deaths
FROM casualties cas
JOIN collisions col ON cas.collision_index = col.collision_index
WHERE cas.casualty_severity = 1
AND cas.age_band_of_casualty > 0
GROUP BY cas.age_band_of_casualty
ORDER BY total_deaths DESC;
 
-- Fatal casualties by exact age
SELECT
    cas.age_of_casualty as age,
    COUNT(*) as total_deaths
FROM casualties cas
JOIN collisions col ON cas.collision_index = col.collision_index
WHERE col.collision_severity = 1
AND cas.age_of_casualty >= 0
AND cas.casualty_severity = 1
GROUP BY cas.age_of_casualty
ORDER BY total_deaths DESC;
 
 
-- ================================================
-- SECTION 12: BUSINESS QUESTION 8
-- How do weather conditions affect accident severity?
-- ================================================
 
SELECT
    CASE weather_conditions
        WHEN 1 THEN 'Fine - No wind'
        WHEN 2 THEN 'Raining - No wind'
        WHEN 3 THEN 'Snowing - No wind'
        WHEN 4 THEN 'Fine - High wind'
        WHEN 5 THEN 'Raining - High wind'
        WHEN 6 THEN 'Snowing - High wind'
        WHEN 7 THEN 'Fog or mist'
        WHEN 8 THEN 'Other'
        WHEN 9 THEN 'Unknown'
        ELSE 'Unknown'
    END as weather,
    COUNT(*) as total_accidents,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) as fatal,
    SUM(CASE WHEN collision_severity = 2 THEN 1 ELSE 0 END) as serious,
    SUM(CASE WHEN collision_severity = 3 THEN 1 ELSE 0 END) as slight,
    ROUND(SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as fatal_percentage
FROM collisions
GROUP BY weather_conditions
ORDER BY total_accidents DESC;
 
 
-- ================================================
-- SECTION 13: BUSINESS QUESTION 9
-- How does light condition affect accident severity?
-- ================================================
 
SELECT
    CASE light_conditions
        WHEN 1 THEN 'Daylight'
        WHEN 4 THEN 'Darkness - Lights lit'
        WHEN 5 THEN 'Darkness - Lights unlit'
        WHEN 6 THEN 'Darkness - No lighting'
        WHEN 7 THEN 'Darkness - Lighting unknown'
        ELSE 'Unknown'
    END as light_condition,
    COUNT(*) as total_accidents,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) as fatal,
    SUM(CASE WHEN collision_severity = 2 THEN 1 ELSE 0 END) as serious,
    SUM(CASE WHEN collision_severity = 3 THEN 1 ELSE 0 END) as slight,
    ROUND(SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as fatal_percentage
FROM collisions
GROUP BY light_conditions
ORDER BY total_accidents DESC;
 
 
-- ================================================
-- END OF ANALYSIS
-- UK Road Safety 2024 — Subashini 
-- All queries completed successfully
-- Next step: Power BI Dashboard
-- ================================================