select *
from unicorncompanies;

-- 1. standardizing the date column
-- 2. Checking for duplicate values
-- 3. checking for null values
-- 4. Deleting all unnecessary columns
-- 5. converting Valuation, and Total Raised to int
-- 6. Renaming the column


-- standardizing the date column

select str_to_date(`Date Joined`, '%m/%d/%Y')
from unicorncompanies;

update unicorncompanies
set `Date Joined` = str_to_date(`Date Joined`, '%m/%d/%Y');

alter table unicorncompanies
modify `Date Joined` date;


-- Checking for duplicate values

with cte as
(
	select *,
	row_number()over(
	partition by Company, Country, Industry) as row_num
	from unicorncompanies
	) select *
from cte
where row_num > 1;


select Company, count(Company)
from unicorncompanies
group by Company
having count(Company) > 1;

select *
from unicorncompanies
where Company = 'Cloudwalk';  -- No duplicate Values

-- Checking for null values

select *
from unicorncompanies
where Company is null or Company = '' ;

select *
from unicorncompanies
where Country is null or Country = '' ;

select *
from unicorncompanies
where `Founded Year` is null or `Founded Year` = '' ;  -- No null values

-- Converting Valuation, and Total Raised to int

-- part 1

select `Valuation ($B)`,  substring(`Valuation ($B)`, 2)
from unicorncompanies;

update unicorncompanies
set `Valuation ($B)` = substring(`Valuation ($B)`, 2);

alter table unicorncompanies
modify `Valuation ($B)` int;

-- part 2

select `Total Raised`,  substring(`Total Raised`, 2)
from unicorncompanies;

update unicorncompanies
set `Total Raised` = substring(`Total Raised`, 2);

-- Convert Total Raised ('$7.44B') into numeric (BigInt or Decimal)
 
update unicorncompanies
set `Total Raised` = CASE 
        WHEN `Total Raised` LIKE '%B' THEN 
            round(CAST(REPLACE(`Total Raised`,'B', '') AS FLOAT) * 1000000000, 2)
        WHEN `Total Raised` LIKE '%M' THEN 
            round(CAST(REPLACE(`Total Raised`, 'M', '') AS FLOAT) * 1000000, 2)
        WHEN `Total Raised` LIKE '%K' THEN 
            round(CAST(REPLACE(`Total Raised`, 'K', '') AS FLOAT) * 1000, 2)
        ELSE NULL
    END ;

alter table unicorncompanies
modify `Total Raised` float;


-- Changing column name

alter table unicorncompanies
change column `Select Inverstors` Investors  text;


