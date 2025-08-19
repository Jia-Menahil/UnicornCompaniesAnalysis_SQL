-- 1. Valuation Trend

select *
from unicorncompanies;

-- Which companies have the highest valuations?

select Company, sum(`Valuation ($B)`) as `Total Valuation ($B)`
from unicorncompanies
group by Company
order by `Total Valuation ($B)` desc; -- ByteDance has highest valuation of 140B$

-- What is the average valuation of unicorns per country/industry?

select Country, avg(`Valuation ($B)`) as `Average Valuation ($B)`
from unicorncompanies
group by Country
order by `Average Valuation ($B)` desc;

select Industry, avg(`Valuation ($B)`) as `Average Valuation ($B)`
from unicorncompanies
group by Industry
order by `Average Valuation ($B)` desc;

-- Which year saw the most unicorns joining the list?

select year(`Date Joined`) as years, count(Distinct Company) as unicorns
from unicorncompanies
group by years
order by unicorns desc;  -- In 2021, 483 companies joined the unicorn list


-- 2. Country & City Analysis

-- Which countries have the most unicorns?

select Country, count(Company) as unicorns
from unicorncompanies
group by Country
order by unicorns desc; -- US stands on first number with 507 unicorns

-- Which cities dominate in producing unicorns?

select City, count(Company) as unicorns
from unicorncompanies
group by City
order by unicorns desc;  -- San Francisco is producing 132 unicorns

-- What’s the total valuation by country? (e.g., USA vs China vs India)

select Country, sum(`Valuation ($B)`) as `Total Valuation ($B)`
from unicorncompanies
group by Country
order by `Total Valuation ($B)` desc;  -- USA Stands on first with total valuation of 1770 billions dollars


-- 3. Industry Insights

-- Which industries have the largest number of unicorns?

select Industry, count(Company) as Unicorns
from unicorncompanies
group by Industry
order by Unicorns desc;   -- Fintech has highest number of unicorns (189 unicorns)

-- Which industry has the fastest-growing unicorns (based on date joined vs founded year)?

SELECT Industry,
       round(AVG(YEAR(`Date Joined`) - `Founded Year`), 0) AS fastest_growth_years
FROM unicorncompanies
WHERE `Founded Year` IS NOT NULL
  AND `Date Joined` IS NOT NULL
GROUP BY Industry
ORDER BY fastest_growth_years ASC;  -- 'Andreessen Horowitz, DST Global, IDG Capital' is the industry with companies that converted to unicorn fast


-- 4. Investor Insights

-- Which investors are the most common backers of unicorns?

WITH RECURSIVE investor_split AS (
    SELECT Company,
           trim(SUBSTRING_INDEX(Investors, ',', 1)) AS Investor,
           SUBSTRING(Investors, LENGTH(SUBSTRING_INDEX(Investors, ',', 1)) + 2) AS remaining
    FROM unicorncompanies

    UNION ALL

    SELECT Company,
           TRIM(SUBSTRING_INDEX(remaining, ',', 1)),
           SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM investor_split
    WHERE remaining != ''
)
SELECT Investor,
       COUNT(DISTINCT Company) AS Unicorn_Count
FROM investor_split
WHERE Investor != '' AND Investor IS NOT NULL
GROUP BY Investor
ORDER BY Unicorn_Count DESC
LIMIT 10;


-- Which investors have backed the highest-valued companies?

WITH RECURSIVE investor_split AS (
    SELECT Company, `Valuation ($B)`,
           trim(SUBSTRING_INDEX(Investors, ',', 1)) AS Investor,
           SUBSTRING(Investors, LENGTH(SUBSTRING_INDEX(Investors, ',', 1)) + 2) AS remaining
    FROM unicorncompanies

    UNION ALL

    SELECT Company, `Valuation ($B)`,
           TRIM(SUBSTRING_INDEX(remaining, ',', 1)),
           SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM investor_split
    WHERE remaining != ''
)
SELECT Investor,
	  GROUP_CONCAT(DISTINCT Company ORDER BY `Valuation ($B)` DESC SEPARATOR ', ') AS Companies,
      sum(`Valuation ($B)`) AS `Total_Valuation_Backings($B)`
FROM investor_split
WHERE Investor != '' AND Investor IS NOT NULL
GROUP BY Investor
ORDER BY `Total_Valuation_Backings($B)` DESC;


-- Who has the highest investor count across companies?

WITH RECURSIVE investor_split AS (
    SELECT Company,
           trim(SUBSTRING_INDEX(Investors, ',', 1)) AS Investor,
           SUBSTRING(Investors, LENGTH(SUBSTRING_INDEX(Investors, ',', 1)) + 2) AS remaining
    FROM unicorncompanies

    UNION ALL

    SELECT Company,
           TRIM(SUBSTRING_INDEX(remaining, ',', 1)),
           SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM investor_split
    WHERE remaining != ''
)
SELECT Company,
		count(distinct Investor) as Investor_count
FROM investor_split
WHERE Investor != '' AND Investor IS NOT NULL
GROUP BY Company
ORDER BY Investor_count DESC;


-- 5. Growth & Fundraising

-- What’s the average funding raised before becoming a unicorn?

select round(avg(`Total Raised`) ,2) as avg_funding_raised
from unicorncompanies;  --  588 Million dollars is the average amount of fund raised to become unicorn

-- Which companies achieved unicorn status in the shortest time after founding?

select 
	Company,
	year(`Date Joined`) - `Founded Year` as `Year to achieve unicornStatus`
from unicorncompanies
WHERE `Founded Year` IS NOT NULL
  AND `Date Joined` IS NOT NULL
order by `Year to achieve unicornStatus` 
limit 10;

-- 6. Exits & Stages

-- Which FInancial stage is more common in unicorns?

select 
	`Financial Stage`,
	count(Company) as count
from unicorncompanies
where `Financial Stage` != 'None'
group by `Financial Stage`
order by count desc;


-- How many unicorns have had portfolio exits?

select count(Company) as unicorn_with_exits
from unicorncompanies
where `Portfolio Exits` != 'None';  -- 48 unicorns had portfolio exits
