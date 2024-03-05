-- To avoid any errors, check missing value / null value 
-- Q1. Write a code to check NULL values

SELECT * FROM corona_dataset
WHERE Province IS NULL
	or Country_Region IS NULL
	or Latitude IS NULL
	or Longitude IS NULL
	or Date IS NULL
	or Confirmed IS NULL
	or Deaths IS NULL
	or Recovered IS NULL;
	
	OR

SELECT
    COUNT(*) FILTER (WHERE Province IS NULL) AS Null_Province,
    COUNT(*) FILTER (WHERE Country_Region IS NULL) AS Null_Country_Region,
    COUNT(*) FILTER (WHERE Latitude IS NULL) AS Null_Latitude,
    COUNT(*) FILTER (WHERE Longitude IS NULL) AS Null_Longitude,
    COUNT(*) FILTER (WHERE Date IS NULL) AS Null_Date,
    COUNT(*) FILTER (WHERE Confirmed IS NULL) AS Null_Confirmed,
    COUNT(*) FILTER (WHERE Deaths IS NULL) AS Null_Deaths,
    COUNT(*) FILTER (WHERE Recovered IS NULL) AS Null_Recovered
FROM
    corona_dataset;
--Q2. If NULL values are present, update them with zeros for all columns. 

UPDATE corona_dataset
SET 
    Province = COALESCE(Province, 'NOT AVAILABLE'),
    Country_Region = COALESCE(Country_Region, 'NOT AVAILABLE'),
    Latitude = COALESCE(Latitude, 0.0),
    Longitude = COALESCE(Longitude, 0.0),
    Date = COALESCE(Date, CURRENT_DATE),
    Confirmed = COALESCE(Confirmed, 0),
    Deaths = COALESCE(Deaths, 0),
    Recovered = COALESCE(Recovered, 0);

-- Q3. check total number of rows

SELECT count(*) as total_rows from corona_dataset

-- Q4. Check what is start_date and end_date

SELECT MIN(Date) AS start_date, MAX(Date) AS end_date
FROM corona_dataset;

-- Q5. Number of month present in dataset

SELECT EXTRACT(MONTH FROM date) AS month_order, COUNT(*) as month_occurance
FROM corona_dataset
GROUP BY month_order
ORDER BY month_order;

OR

SELECT COUNT(DISTINCT EXTRACT(MONTH FROM Date)) AS month_count FROM corona_dataset;

-- Q6. Find monthly average for confirmed, deaths, recovered

SELECT 
    EXTRACT(MONTH FROM Date) as month_no,
	EXTRACT(YEAR FROM Date) as Year,
    ROUND(AVG(Confirmed),2) AS avg_confirmed,
    ROUND(AVG(Deaths),2) AS avg_deaths,
    ROUND(AVG(Recovered),2) AS avg_recovered
FROM 
    corona_dataset
GROUP BY 
    Year, month_no
ORDER BY 
    Year, month_no;

-- Q7. Find most frequent value for confirmed, deaths, recovered each month 

WITH FrequentData AS (
    SELECT
        EXTRACT(MONTH FROM Date) as month_no,
        EXTRACT(YEAR FROM Date) as year,
        Confirmed,
        Deaths,
        Recovered,
        RANK() OVER (PARTITION BY  EXTRACT(MONTH FROM Date), EXTRACT(YEAR FROM Date) ORDER BY COUNT(*) DESC) as rank
    FROM
        corona_dataset
    GROUP BY
        EXTRACT(MONTH FROM Date), EXTRACT(YEAR FROM Date), Confirmed, Deaths, Recovered
)
SELECT
    month_no,
    year,
    Confirmed,
    Deaths,
    Recovered
FROM
    FrequentData
WHERE
    rank = 1
ORDER BY
    year, month_no;


-- Q8. Find minimum values for confirmed, deaths, recovered per year.

SELECT
	EXTRACT (Year from Date) as year,
	MIN(Confirmed) as min_confirmed_cases,
	MIN(Deaths) as min_death_reported,
	MIN(Recovered) as min_recover_data
FROM
	corona_dataset
GROUP BY 
	year
ORDER BY 
	year;

-- Q9. Find maximum values of confirmed, deaths, recovered per year.

SELECT
	EXTRACT (Year from Date) as year,
	MAX(Confirmed) as max_confirmed_cases,
	MAX(Deaths) as max_death_reported,
	MAX(Recovered) as max_recover_data
FROM
	corona_dataset
GROUP BY 
	year
ORDER BY 
	year;

-- Q10. The total number of case of confirmed, deaths, recovered each month

SELECT
	EXTRACT (MONTH from Date) as month_no,
	EXTRACT (YEAR from Date) as year,
	SUM(Confirmed) as total_confirmed_cases,
	SUM(Deaths) as total_death_reported,
	SUM(Recovered) as total_recover_data
FROM
	corona_dataset
GROUP BY 
	year, month_no
ORDER BY 
	year, month_no;
	
/** for further analysis to know which had the highest value
With values as (
SELECT
	EXTRACT (MONTH from Date) as month_no,
	EXTRACT (YEAR from Date) as year,
	SUM(Confirmed) as total_confirmed_cases,
	SUM(Deaths) as total_death_reported,
	SUM(Recovered) as total_recover_data
FROM
	corona_dataset
GROUP BY 
	year, month_no
ORDER BY 
	year, month_no)
Select MAX(total_confirmed_cases),MAX(total_death_reported), MAX(total_recover_data) from values
*/

-- Q11. Check how corona virus spread out with respect to confirmed case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )

SELECT 
	EXTRACT(MONTH from Date) as month_no,
	EXTRACT(YEAR from Date) as year,
	SUM(Confirmed) as total_confirmed_cases,
	ROUND(AVG(Confirmed),2) as avg_confirmed_cases,
	ROUND(VARIANCE(Confirmed),2) as var_confirmed_cases,
	ROUND(STDDEV(Confirmed),2) as std_confirmed_cases
FROM
	corona_dataset
GROUP BY
	year, month_no
Order by
	year, month_no;
	


-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total death cases, their average, variance & STDEV )

SELECT 
	EXTRACT(MONTH from Date) as month_no,
	EXTRACT(YEAR from Date) as year,
	SUM(Deaths) as total_death_reported,
	ROUND(AVG(Deaths),2) as avg_death_reported,
	ROUND(VARIANCE(Deaths),2) as var_death_reported,
	ROUND(STDDEV(Deaths),2) as std_death_reported
FROM
	corona_dataset
GROUP BY
	year, month_no
Order by
	year, month_no;


-- Q13. Check how corona virus spread out with respect to recovered case per month
--      (Eg.: total recovered cases, their average, variance & STDEV )

SELECT 
	EXTRACT(MONTH from Date) as month_no,
	EXTRACT(YEAR from Date) as year,
	SUM(Recovered) as total_recover_data,
	ROUND(AVG(Recovered),2) as avg_recover_data,
	ROUND(VARIANCE(Recovered),2) as var_recover_data,
	ROUND(STDDEV(Recovered),2) as std_recover_data
FROM
	corona_dataset
GROUP BY
	year, month_no
Order by
	year, month_no;


-- Q14. Find Country having highest number of the Confirmed case.

SELECT 
	country_region as Country,
	SUM(Confirmed) as total_confirmed_cases
FROM corona_dataset
GROUP BY Country
ORDER BY total_confirmed_cases DESC
LIMIT 1;

OR 

WITH rankingCountry as (
SELECT
	country_region as Country,
	SUM(Confirmed) as total_confirmed_cases,
	RANK() Over(ORDER by SUM(Confirmed) DESC) as rank_no
FROM
	corona_dataset
GROUP BY
	Country
)
SELECT 
	Country,
	total_confirmed_cases
from rankingCountry
where rank_no = 1;

-- Q15. Find Country having lowest number of the death cases.

WITH rankingCountry as (
    SELECT
        country_region as Country,
        SUM(Deaths) as total_death_reported,
        RANK() Over(ORDER by SUM(Deaths) ASC) as rank_no
    FROM
        corona_dataset
    GROUP BY
        Country
)
SELECT 
	Country,
	total_death_reported
FROM 
	rankingCountry
WHERE 
	rank_no = 1;

-- Q16. Find top 5 countries having highest recovered cases.

SELECT 
    country_region AS Country,
    SUM(Recovered) AS total_recovered_data
FROM
    corona_dataset
GROUP BY
    Country
ORDER BY total_recovered_data DESC
limit 5;		
