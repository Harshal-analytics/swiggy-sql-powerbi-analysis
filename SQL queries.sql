use Swiggy_Database
SELECT * FROM swiggy_data
 

-- Data Validation and Cleaning 
--Null Check

Select 
SUM (CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
SUM (CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
SUM (CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
SUM (CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant,
SUM (CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
SUM (CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
SUM (CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish,
SUM (CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price,
SUM (CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
SUM (CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
From swiggy_data;

-- Check Empty data (Strings)
select * from swiggy_data
where state= '' OR City= '' OR Location= ''
OR Category= '' OR Dish_Name= '';

-- Check Duplicate Values

select State, City, Order_date, Restaurant_Name, Location,
Category, Dish_Name, Price_INR, Rating, Rating_Count,
COUNT (*) as CNT from swiggy_data
GROUP BY 
State, City, Order_date, Restaurant_Name, Location,
Category, Dish_Name, Price_INR, Rating, Rating_Count
Having count(*)>1;                                          --(29 rows are duplicate)

-- Delete Duplication 

WITH CTE AS(
SELECT *, ROW_NUMBER () Over(
  PARTITION BY State, City, Order_date, Restaurant_Name, Location,
Category, Dish_Name, Price_INR, Rating, Rating_Count
ORDER BY (SELECT NULL)
) AS rn
from swiggy_data
)
DELETE FROM CTE WHERE rn>1


-- CREATING SCHEMA 
-- DIMENSION TABLE 

-- 1 -- DATE TABLE

IF OBJECT_ID('dim_date', 'U') IS NOT NULL
    DROP TABLE dim_date;

CREATE TABLE dim_date (
    date_id INT IDENTITY (1,1) PRIMARY KEY,
    Full_Date DATE,
    Year INT,
    Month INT,
    Month_name VARCHAR(20),
    Quarter INT,
    Week INT
);
-- 2 -- dim location table

IF OBJECT_ID('dim_location', 'U') IS NOT NULL
    DROP TABLE dim_location;

CREATE TABLE dim_location (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    State VARCHAR(100),
    City VARCHAR(100),
    Location VARCHAR(200)
);

select * from dim_location

-- 3 -- dim_restaurant 

IF OBJECT_ID('dim_restaurant', 'U') IS NOT NULL
    DROP TABLE dim_restaurant;

CREATE TABLE dim_restaurant (
    restaurant_id INT IDENTITY (1,1) PRIMARY KEY,
    Restaurant_Name VARCHAR(200)
);

-- 4 -- dim_category

IF OBJECT_ID('dim_category', 'U') IS NOT NULL
    DROP TABLE dim_category;

CREATE TABLE dim_category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    Category VARCHAR(200)
);

-- 5 -- dim_dish

IF OBJECT_ID('dim_dish', 'U') IS NOT NULL
    DROP TABLE dim_dish;

CREATE TABLE dim_dish (
    dish_id INT IDENTITY (1,1) PRIMARY KEY,
    Dish_Name VARCHAR(200)
);

-- Fact Table 
IF OBJECT_ID('fact_swiggy_orders', 'U') IS NOT NULL
    DROP TABLE fact_swiggy_orders;
GO

CREATE TABLE fact_swiggy_orders (
    order_id INT IDENTITY (1,1) PRIMARY KEY,

    date_id INT NOT NULL,
    location_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    category_id INT NOT NULL,
    dish_id INT NOT NULL,

    Price_INR DECIMAL(10,2),
    Rating DECIMAL(4,2),
    Rating_Count INT,

    CONSTRAINT FK_fact_date
        FOREIGN KEY (date_id) REFERENCES dim_date(date_id),

    CONSTRAINT FK_fact_location
        FOREIGN KEY (location_id) REFERENCES dim_location(location_id),

    CONSTRAINT FK_fact_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),

    CONSTRAINT FK_fact_category
        FOREIGN KEY (category_id) REFERENCES dim_category(category_id),

    CONSTRAINT FK_fact_dish
        FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);

 
-- INSERT DATA IN TABLES 
-- dim_date
INSERT INTO dim_date (Full_Date, Year, Month, Month_Name, Quarter, Week)
Select distinct 
   Order_Date,
   YEAR(Order_Date),
   MONTH(Order_Date),
   DATENAME(MONTH, Order_Date),
   DATEPART(QUARTER, Order_Date),
   DATEPART(WEEK, Order_Date)

   from swiggy_data
   Where Order_Date IS NOT NULL;

   select * from dim_date;

   -- dim_location

INSERT INTO dim_location (State, City, Location)
select distinct 
 State,
 City,
 Location
 from swiggy_data;

 select * from dim_Location

 -- dim_restaurant 
 INSERT INTO dim_restaurant (Restaurant_Name)
 select distinct 
 Restaurant_Name 
 from swiggy_data

 select * from dim_restaurant;

 -- dim_category
INSERT INTO dim_category (Category)
select distinct 
Category from swiggy_data

select * from dim_category;

-- dim_dish
INSERT INTO dim_dish (Dish_Name)
select distinct 
Dish_Name from swiggy_data;

select * from dim_dish

-- fact_table 
INSERT INTO fact_swiggy_orders
(
    date_id,
    Price_INR,
    Rating,
    Rating_Count,
    location_id,
    restaurant_id,
    category_id,
    dish_id
)
SELECT
    dd.date_id,
    s.Price_INR,
    s.Rating,
    s.Rating_Count,

    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id
FROM swiggy_data s

-- JOIN date dimension
JOIN dim_date dd
    ON dd.Full_Date = s.Order_Date

-- JOIN location dimension
JOIN dim_location dl
    ON dl.State = s.State
   AND dl.City = s.City
   AND dl.Location = s.Location

-- JOIN restaurant dimension
JOIN dim_restaurant dr
    ON dr.Restaurant_Name = s.Restaurant_Name

-- JOIN category dimension
JOIN dim_category dc
    ON dc.Category = s.Category

-- JOIN dish dimension
JOIN dim_dish dsh
    ON dsh.Dish_Name = s.Dish_Name;

select * from fact_swiggy_orders;


select * from fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
JOIN dim_category c ON f.category_id = c.category_id
JOIN dim_dish di ON f.dish_id = di.dish_id;


-- KPIs
-- 1 -- Total Orders 
SELECT COUNT(*) AS Total_Orders 
  FROM fact_swiggy_orders;

-- 2 -- Total Revenue
SELECT
    CAST(SUM(price_INR) / 1000000.0 AS DECIMAL(18,2)) AS Total_Revenue_Million
FROM fact_swiggy_orders;

-- 3 -- Average Dish Price
SELECT
    CAST(AVG(price_INR) AS DECIMAL(10,2)) AS Avg_Dish_Price_INR
FROM fact_swiggy_orders;

-- 4 -- Average Rating
SELECT
    CAST(AVG(Rating) AS DECIMAL(5,2)) AS Avg_Rating
FROM fact_swiggy_orders;

-- In-Depth Analysis 

-- 1--  Monthly Order Trends
select 
d.year,
d.month,
d.month_name,
count(*) AS Total_Orders
from fact_swiggy_orders f 
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year,
d.month,
d.month_name
Order by count(*) desc;

-- 2 -- Quarterly trend
select 
d.year,
d.quarter,
count(*) AS Total_Orders
from fact_swiggy_orders f 
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year,
d.quarter
Order by count(*) desc;

-- 3 -- Yearly Trend (2025)
select 
d.year,
count(*) AS Total_Orders
from fact_swiggy_orders f 
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year;

-- 4 -- Weekly Orders 
select datename (Weekday, d.full_date) AS Day_name,
count(*) AS Total_orders
from fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
Group by datename (Weekday, d.full_date), datepart (weekday, d.full_date)
order by datepart (Weekday, d.full_date);

-- Location Based analysis

-- 5 -- Top 10 cities by order volume 
select top 10 l.city, count(*) AS Total_Orders
from fact_swiggy_orders f
JOIN dim_location l
ON l.location_id = f.location_id 
GROUP by l.city 
ORDER BY count(*) desc;

-- 6 -- Revenue by states
select l.state,
sum(f.price_INR) AS Total_Revenue_INR
from fact_swiggy_orders f
JOIN dim_location l
ON l.location_id = f.location_id 
GROUP by l.state
ORDER BY SUM(f.Price_INR) desc;

-- 7 --  TOP 10 Restaurants by Orders
select top 10 r.restaurant_name,
sum(f.price_INR) AS Total_Revenue_INR
from fact_swiggy_orders f
JOIN dim_restaurant r
ON r.restaurant_id = f.restaurant_id 
GROUP by r.restaurant_name
ORDER BY sum(f.price_INR) desc;

-- 8 -- Top categories by Order Volume
select 
c.category, count(*) AS Total_orders
from fact_swiggy_orders f 
JOIN dim_category c ON f.category_id = c.category_id
GROUP BY c.Category
ORDER BY total_orders desc;

-- 9 -- Most Ordered dish
select top 10 d.dish_name, count(*) AS order_count
from fact_swiggy_orders f 
JOIN dim_dish d ON f.dish_id = d.dish_id
GROUP BY d.dish_name
ORDER BY order_count desc;

 -- 10 --  Cuisine Performance 
 select c.category, count(*) AS Total_orders,
cast(avg(f.Rating) AS decimal(4,1)) AS Avg_Rating
 from fact_swiggy_orders f 
 JOIN dim_category c ON f.category_id = c.category_id
 group by c.Category
 order by total_orders desc;

 -- Customer spending insights
 
 -- Under 100, 100-199, 200-299,
 --       300-499, 500+

 SELECT
    price_range,
    COUNT(*) AS Total_Orders
FROM (
   SELECT
     CASE
     WHEN price_inr < 100 THEN 'Under 100'
     WHEN price_inr BETWEEN 100 AND 199 THEN '100 - 199'
     WHEN price_inr BETWEEN 200 AND 299 THEN '200 - 299'
     WHEN price_inr BETWEEN 300 AND 499 THEN '300 - 499'
     ELSE '500+'
        END AS price_range
    FROM fact_swiggy_orders
) t
GROUP BY price_range
ORDER BY Total_Orders DESC;
  
 -- Rating Count (1-5)
 select cast(rating AS decimal(3,1)) AS Rating,
 count(*) AS Rating_Count
 from fact_swiggy_orders
 group by rating
 order by count(*) desc;


