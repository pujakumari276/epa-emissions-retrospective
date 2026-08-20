-- ============================================================
-- EPA GHGRP Emissions Analysis SQL Queries
-- Dataset: 94,378 facility-year records (2010-2023)
-- ============================================================

-- QUERY 1: National Emissions Trend (2010-2023)
SELECT 
    reporting_year,
    ROUND(SUM(total_emissions) / 1000000, 1) AS total_emissions_mmt,
    COUNT(DISTINCT facility_id) AS num_facilities
FROM emissions
GROUP BY reporting_year
ORDER BY reporting_year;

-- QUERY 2: Top 10 Emitting Sectors (2023)
SELECT 
    industry_sector,
    ROUND(SUM(total_emissions) / 1000000, 1) AS emissions_mmt,
    COUNT(DISTINCT facility_id) AS facilities
FROM emissions
WHERE reporting_year = 2023
GROUP BY industry_sector
ORDER BY emissions_mmt DESC
LIMIT 10;

-- QUERY 3: Top 20 Emitting Facilities (2023)
SELECT 
    facility_name,
    state,
    industry_sector,
    ROUND(total_emissions / 1000000, 2) AS emissions_mmt
FROM emissions
WHERE reporting_year = 2023
ORDER BY total_emissions DESC
LIMIT 20;

-- QUERY 4: State Rankings (2023)
SELECT 
    state,
    ROUND(SUM(total_emissions) / 1000000, 1) AS emissions_mmt,
    COUNT(DISTINCT facility_id) AS facilities
FROM emissions
WHERE reporting_year = 2023
GROUP BY state
ORDER BY emissions_mmt DESC
LIMIT 15;

-- QUERY 5: Year-over-Year Change — Top 5 Sectors
WITH sector_yearly AS (
    SELECT 
        industry_sector,
        reporting_year,
        SUM(total_emissions) AS total
    FROM emissions
    WHERE industry_sector IN ('Power Plants', 'Chemicals', 'Petroleum and Natural Gas Systems', 'Minerals', 'Waste')
    GROUP BY industry_sector, reporting_year
)
SELECT 
    industry_sector,
    reporting_year,
    ROUND(total / 1000000, 1) AS emissions_mmt,
    ROUND(
        (total - LAG(total) OVER (PARTITION BY industry_sector ORDER BY reporting_year)) 
        / LAG(total) OVER (PARTITION BY industry_sector ORDER BY reporting_year) * 100,
        1
    ) AS yoy_change_pct
FROM sector_yearly
WHERE reporting_year >= 2020
ORDER BY industry_sector, reporting_year;
