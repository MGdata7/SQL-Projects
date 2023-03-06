# Hotel Data SQL Project

![image](https://user-images.githubusercontent.com/14934475/221428004-d752b885-80b3-439d-b6d8-74bd699f4050.png)

In this project, I will analyse hotel business data using SQL. In this scenario the stakeholder has presented me with business data and has several questions they want answered:
 
> "Is our hotel revenue growing by year?"
- There are two hotel types so they are recommending segmenting revenue by hotel type.

> "Should we increase our parking lot size?"
- Stakeholders want to understand any possible trends in guests with personal cars.

> "What trends can we see in the data?"
- Stakeholders want me to focus on the average daily rate.

To analyse the hotel data at hand, I will build a database and use queries in SQL Server.

### Creating the database

My first step - a relatively quick one but important - was to create a database in SQL Server. I did that by using SQL Server Import and Export Data and migrating the five tabs of the source data Excel sheet into the SQL Server Management Studio environment. 

![image](https://user-images.githubusercontent.com/14934475/221427516-9c19b80a-140c-4fe8-8f70-1a65d6e48b35.png)

### Viewing data

First I'll pull up the 2018 data table to have a look at its contents.

``` 
SELECT *
FROM dbo.hotel2018
``` 
The 2018 data has about 21,000 rows.

![image](https://user-images.githubusercontent.com/14934475/221429004-77c5ba87-b78a-49f6-b42f-c87c194a4320.png)

Here's some of the columns. 

![image](https://user-images.githubusercontent.com/14934475/221428265-a776ce45-fcf5-479e-bc45-cc51667d44d1.png)
![image](https://user-images.githubusercontent.com/14934475/221428279-eb355a24-f9f3-4c81-a873-12558b2daeed.png)
![image](https://user-images.githubusercontent.com/14934475/221428311-55eb6684-4f3b-4d68-9877-7059ef1f218c.png)

Plenty there - our next step is to organise this data, using SQL, into a form that will be easy to plug into Power BI.

Next let's view 2018 - 2020 data.

``` 
SELECT *
FROM dbo.hotel2018

SELECT *
FROM dbo.hotel2019

SELECT *
FROM dbo.hotel2020
``` 
I'd like to create a unified table, so I'll add "union" to the select statements.

``` 
SELECT *
FROM dbo.hotel2018
UNION
SELECT *
FROM dbo.hotel2019
UNION
SELECT *
FROM dbo.hotel2020
``` 
Now all three are queried. I can check and see the rows have more than tripled, over 100,000:

![image](https://user-images.githubusercontent.com/14934475/221429107-8c414553-b39b-4f37-a328-0c41faf6e74c.png)

### Exploratory Data Analysis

Now that I have the aggregated data, I can try to answer a stakeholder question.

> "Is our hotel revenue growing by year?"

I'll create a table with our three years.

``` 
SELECT *
INTO dbo.hotelstable
FROM (
SELECT *
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

``` 

When examining the data I can see that there is no revenue column. But there is a column for number of weekend night stays, one for weekday night stays, and a column for the average daily rate (ADR).

It will be helpful to aggregate the weekend and weekday nights into one column. 

``` 
SELECT stays_in_week_nights + stays_in_weekend_nights
FROM hotelstable
``` 
![image](https://user-images.githubusercontent.com/14934475/221430366-8deab107-2075-4aed-884a-a0394a850e4d.png)

We can multiple the aggregated values in this column by the ADR, or average hotel daily rate.

``` 
SELECT (stays_in_week_nights + stays_in_weekend_nights)*ADR AS revenue
FROM hotelstable

``` 
Here's the result we get from that calculation, including the renaming of the column.

![image](https://user-images.githubusercontent.com/14934475/221430599-cdb18f11-1d14-461b-befa-c62058b2d568.png)

Next I'll explore the revenue by year.

``` 
SELECT arrival_date_year,
SUM((stays_in_week_nights+stays_in_weekend_nights)*adr) AS revenue
FROM hotelstable
GROUP BY arrival_date_year
ORDER BY arrival_date_year ASC
``` 
![image](https://user-images.githubusercontent.com/14934475/221433417-f0a6d5e9-56d0-4759-a149-21e8b1f5432f.png)

> "Is our hotel revenue growing by year?"

I can tell by a quick glance at this data that revenue has grown overall between 2018 and 2020, though it peaked in 2019 and declined somewhat in 2020. I will create a data visualisation for this soon.

I want to examine hotel type as recommended by the stakeholders, so next I'll add a hotel type column and group by that. I'll round the decimal places as well.

``` 
SELECT arrival_date_year,
hotel,
ROUND(SUM((stays_in_week_nights+stays_in_weekend_nights)*adr),2) AS revenue
FROM hotelstable
GROUP BY arrival_date_year, hotel
ORDER BY hotel, arrival_date_year ASC
``` 
![image](https://user-images.githubusercontent.com/14934475/221433869-b8e36d9d-5f4f-45df-87dc-ae0415cda4f1.png)

At a glance we can see that City Hotel revenue increased in 2020 while Resort Hotel revenue in 2020 decreased year-over-year.

### Combining tables for visualisation

I'll move on to join the remaining tables, market segment and meals, to the greater table. I'll then import it into Power BI for visualisations.

``` 
SELECT * 
FROM hotelstable
JOIN hotelmarketsegment
ON hotelstable.market_segment = hotelmarketsegment.market_segment
LEFT JOIN dbo.hotelmealcost
ON hotelmealcost.meal = hotelstable.meal
``` 

### Setting up Power BI environment

I'll import the SQL Server data into Power BI on my desktop.

![image](https://user-images.githubusercontent.com/14934475/221434701-b0d711e3-663e-4c9d-8510-cab82f440b32.png)

I'm copying in a query.

![image](https://user-images.githubusercontent.com/14934475/221435107-ab4144c1-8bd2-4e2f-941a-e706b919c6d6.png)

Next I'm loading the table into Power BI.

![image](https://user-images.githubusercontent.com/14934475/221435537-04b5de4c-6c99-44e6-8e9c-24cec5554cd5.png)

### Revisiting stakeholder questions

Before I get started with building the visualisation, I'm going to take a moment to return to what is being asked of me. 

> "Is our hotel revenue growing by year?"
- There are two hotel types so they are recommending segmenting revenue by hotel type.

> "Should we increase our parking lot size?"
- Stakeholders want to understand any possible trends in guests with personal cars.

> "What trends can we see in the data?"
- Stakeholders want me to focus on average daily rate and guests to explore seasonal patterns.

### Building the Power BI Dashboard

I need to factor in the discounts as part of the revenue analysis. I'll add a custom column called Revenue and create a formula.

![image](https://user-images.githubusercontent.com/14934475/221435845-6c92e5e1-e5cc-4fe3-9da9-6be1c762f6f8.png)

I convert the Revenue column to decimal format and click "Close and Apply". Next I want to break up the space a little. I navigate to insert -> shape -> line, stretch the line across the workspace, and duplicate it. The most important information for the viewer will go in the top third. The trends will be in the centre and the supporting information will be in the bottom third.

![image](https://user-images.githubusercontent.com/14934475/221436288-295b25d7-fcb8-47bf-a42d-39da609ee375.png)

I'll bring in the Revenue column and convert it to number format. I'll also bring in the ADR column, format it as a number, and convert it from the default sum to the preferred average format. I'll duplicate the average ADR then create a new measure for nights stayed in the hotels:

![image](https://user-images.githubusercontent.com/14934475/221436757-a21a4f50-2402-4013-a7d4-d47b5806383c.png)

I'll use the Visualisations menu to replace the duplicated average ADR element with the Total Nights measure. Then I'll convert the Revenue and average ADR components to currency format. It was originally in USD but because it's a theoretical project, I'll use euro for audience-tailored aesthetics. I'll add the average discount as a number element and convert it to a percentage. I'll then use the Reservation Date and Revenue columns to create a line chart.

![image](https://user-images.githubusercontent.com/14934475/221437336-2f45234f-90df-4c19-a67a-3ea9328b1bcc.png)

Once I apply a filter by date, I can remove uninteresting/null data points.

![image](https://user-images.githubusercontent.com/14934475/221437681-5269d7f0-122a-40fb-9d9f-0edcab7a0362.png)

Next I'll add two filters: one for country for the user's convenience, and another for hotel type, since the latter was of interest to the stakeholders.

![image](https://user-images.githubusercontent.com/14934475/221437901-533f3db2-041b-4179-aceb-1a22fc01c3b8.png)

Next I'll create sparklines for the data at the top and adjust the filters, values, and aesthetics accordingly. At the base of the dashboard I'll create visuals for the additional insights suggested in the use case. I'll re-examine the questions. The stakeholders were curious about hotel type. I'll create a donut chart at the bottom for the breakdown of resort vs. city hotels.

![image](https://user-images.githubusercontent.com/14934475/221439729-3fe2817c-45a4-4d70-b8af-e65d85b89e26.png)

> "Should we increase our parking lot size?"
- Stakeholders want to understand any possible trends in guests with personal cars.

I'll create a measure of Parking Percentage to calculate what percentage of people require parking spaces year over year. I'll make this into a table for a quick view and then convert to a matrix for interactivity.

![image](https://user-images.githubusercontent.com/14934475/221439686-059009dc-dea0-4f37-a9dc-2a20b2e865e5.png)

![image](https://user-images.githubusercontent.com/14934475/221440365-af17ee12-9be3-42b2-8e62-64f32b173882.png)

The user can now see that most car space use is occurring in **resort hotels** while relatively little is occurring in city hotels. This is a key insight to the stakeholder's interests. But it doesn't look like the demand is growing much year over year, so I lack evidence about whether or not it's time to build a parking lot.

As a closing component to this Power BI dashboard I will add a date slicer.

![image](https://user-images.githubusercontent.com/14934475/221441129-3307f266-fb98-4721-861a-4b24260a55f8.png)

![image](https://user-images.githubusercontent.com/14934475/221441064-a3afcca5-1512-4749-94d5-80500b3e9d75.png)








