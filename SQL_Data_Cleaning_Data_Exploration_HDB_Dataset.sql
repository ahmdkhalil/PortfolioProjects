Select * 
From [Portfolio Project].[dbo].[HDBResale2014_2016]

Select * 
From [Portfolio Project].[dbo].[HDBResale2017]

--Data Type Inspection

Select Column_name, Data_type
From INFORMATION_SCHEMA.Columns
Where TABLE_NAME = 'HDBResale2014_2016'

-- Data Cleaning:

-- 1. Rename 'month' column to 'sale_date'
Exec sp_rename 'HDBResale2014_2016.month', 'sale_date', 'COLUMN'

-- 2. Create new columns for split

Alter Table [Portfolio Project].[dbo].[HDBResale2014_2016]
Add sale_year nvarchar(50), sale_month nvarchar(50)

-- 3. Split 'sale date' to month and year columns

Update [Portfolio Project].[dbo].[HDBResale2014_2016]
SET	sale_year = REVERSE(Parsename(Replace(Reverse(sale_date), '-', '.'), 1)),
	sale_month = REVERSE(Parsename(Replace(Reverse(sale_date), '-', '.'), 2))

--Data Type Inspection

Select Column_name, Data_type
From INFORMATION_SCHEMA.Columns
Where TABLE_NAME = 'HDBResale2017'
	

-- Data Cleaning:

-- 1. Rename 'month' column to 'sale_date'
Exec sp_rename 'HDBResale2017.month', 'sale_date', 'COLUMN'


-- 2. Create new columns for split

Alter Table [Portfolio Project].[dbo].[HDBResale2017]
Add sale_year nvarchar(50), sale_month nvarchar(50)

-- 3. Split 'sale date' to month and year columns

Update [Portfolio Project].[dbo].[HDBResale2017]
SET	sale_year = REVERSE(Parsename(Replace(Reverse(sale_date), '-', '.'), 1)),
	sale_month = REVERSE(Parsename(Replace(Reverse(sale_date), '-', '.'), 2))


-- 4. Rename 'remaining_lease' column to 'remaining_lease_ori'
Exec sp_rename 'HDBResale2017.remaining_lease', 'remaining_lease_ori', 'COLUMN'

-- 5. Add new column 'remaining lease' and set datatype to float
Alter Table HDBResale2017
Add remaining_lease float(30)

-- 6. Add values to new column but only include year values without month values
Update HDBResale2017
SET	remaining_lease = REVERSE(Parsename(Replace(Reverse(remaining_lease_ori), ' ', '.'), 1))

-- 7. Drop sale date and remaining_lease_ori
ALTER TABLE HDBResale2017
Drop Column sale_date, column_to_delete

----------------------------------------------------------------------------
-- Data Exploration:


-- Join two tables horizontally into new table with CTE

With HDBTable as

(Select * From [Portfolio Project].[dbo].[HDBResale2017]
Union All
Select * From [Portfolio Project].[dbo].[HDBResale2014_2016])

-- 1. Analysis: Total Unit Sold vs Average Price from Highest Average to Lowest per lease year

With HDBTable as

(Select * From [Portfolio Project].[dbo].[HDBResale2017]
Union All
Select * From [Portfolio Project].[dbo].[HDBResale2014_2016])

Select lease_commence_date, count(lease_commence_date) unit_count, round(avg(resale_price), 0) avg_price
From HDBTable
Group by lease_commence_date
order by avg_price desc

-- 2. Analysis: Total Unit Sold vs Average Price from Highest Average to Lowest per year

With HDBTable as

(Select * From [Portfolio Project].[dbo].[HDBResale2017]
Union All
Select * From [Portfolio Project].[dbo].[HDBResale2014_2016])

Select sale_year, count(sale_year) unit_count, round(avg(resale_price), 0) avg_price
From HDBTable
Group by sale_year
order by avg_price desc

-- 3. Analysis: Flat Model Distribution vs Average Price

With HDBTable as

(Select * From [Portfolio Project].[dbo].[HDBResale2017]
Union All
Select * From [Portfolio Project].[dbo].[HDBResale2014_2016])

Select flat_model, count(flat_model) as count, round(avg(resale_price),0) avg_price
From HDBTable
group by flat_model
order by avg_price 

-- 4. Analysis: Lowest average price based on sale year, remaining lease, town, floor area

With HDBTable as

(Select * From [Portfolio Project].[dbo].[HDBResale2017]
Union All
Select * From [Portfolio Project].[dbo].[HDBResale2014_2016])

Select street_name, storey_range, floor_area_sqm, round(avg(resale_price),0) avg_price, remaining_lease, sale_year 
From HDBTable
where sale_year = 2019 and remaining_lease >= 80
group by sale_year, storey_range, remaining_lease, street_name, floor_area_sqm 
order by avg_price, remaining_lease 