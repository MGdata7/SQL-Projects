--Explore 2018 Hotel Revenue data

SELECT *
FROM dbo.hotel2018
UNION
SELECT *
FROM dbo.hotel2019
UNION
SELECT *
FROM dbo.hotel2020

--Create table of three years

SELECT *
INTO dbo.hotelstable
FROM 
(SELECT *
FROM dbo.hotel2018
UNION
SELECT *
FROM dbo.hotel2019
UNION
SELECT *
FROM dbo.hotel2020)
t

SELECT * 
FROM hotelstable

--Selecting stay nights columns

SELECT stays_in_week_nights + stays_in_weekend_nights
FROM hotelstable

--Multiplying aggregated column by average daily rate

SELECT (stays_in_week_nights+stays_in_weekend_nights)*adr AS revenue
FROM hotelstable

--Grouping and ordering revenue by year

SELECT arrival_date_year,
hotel,
ROUND(SUM((stays_in_week_nights+stays_in_weekend_nights)*adr),2) AS revenue
FROM hotelstable
GROUP BY arrival_date_year, hotel
ORDER BY hotel, arrival_date_year ASC

--Join other tables to greater table

SELECT *
FROM dbo.hotelmarketsegment

SELECT * 
FROM hotelstable
JOIN hotelmarketsegment
ON hotelstable.market_segment = hotelmarketsegment.market_segment
LEFT JOIN dbo.hotelmealcost
ON hotelmealcost.meal = hotelstable.meal
