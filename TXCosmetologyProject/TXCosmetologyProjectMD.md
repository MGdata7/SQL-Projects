# Texas Cosmetology Project
## Data Cleaning Project in SQL

![image](https://user-images.githubusercontent.com/14934475/222164529-72b351e1-65a6-46b6-814d-674b5a45a2e1.png)

In today's project, I'm examining cosmetology license data from the state of Texas and comparing it to U.S. Census Bureau data filtered by Texas. A stakeholder is asking me
whether aesthetician licenses are more densely occurring in higher-income areas. They also invite me to share other insights around geographical characteristics and aesthetician licensure.

Aesthetic services are typically expensive so this may seem intuitive. But this insight might drive business choices - like how to approach marketing salon products to aestheticians, for example - so it's worth asking a data analyst to run the numbers and make sure.
Additionally, an unexpected insight that aestheticians are equally common in lower income areas might point to a new area of the market. It's time to see what the data can tell us.

Before any analysis can happen, the data has to be formatted in a way that makes it easy to analyse. It needs to be cleaned. We'll clean the data and then see what we can find in the next episode of this project (analysis).

This project prompt was designed by David Langer, though the approach is all mine. First I'll download the datasets.

### Viewing the Data

![image](https://user-images.githubusercontent.com/14934475/222166369-5cef278a-e327-4333-b0bd-d0d001f3877d.png)

![image](https://user-images.githubusercontent.com/14934475/222166583-52ee8345-d554-4f61-843d-2e937df7958f.png)

![image](https://user-images.githubusercontent.com/14934475/222166948-bf637ea0-b928-46f0-9bb7-1f221ab3df29.png)

The DP03 is the U.S. Census' dataset on economic characteristics of the US population, derived from the American Community Survey. I used 2021 data and only selected Texas counties there.

![image](https://user-images.githubusercontent.com/14934475/222791085-72e4bc30-590a-4842-b98c-78b7ed2b1f8e.png)

I can make this joke, I'm from Texas. :D

Let's have a look at the data in Excel. Looking at the census data, right away I can see something that needs tweaking. The county information is tied in with state information. I'll need to change that to merge it with the Texas cosmetology data.

![image](https://user-images.githubusercontent.com/14934475/222171185-c31d107f-c667-42c2-bf4a-83417ee35850.png)

The columns are also named by coding for which the Census provided a dictionary spreadsheet. I'll likely rename the columns I'm working most with.

In the Texas cosmetology info, it looks like the counties are isolated, though the capitalisation is different so I will fix that later. I'm happy to see some of the data has been sanitised and addresses have been removed, that saves me a step.

![image](https://user-images.githubusercontent.com/14934475/222790929-34e33819-23ac-4dbe-9bc6-f6941221e785.png)

![image](https://user-images.githubusercontent.com/14934475/222172158-24392289-063b-4075-935e-f6e5d6631e4b.png)

### Cleaning in SQL Server

Next I'll import the two spreadsheets into SQL Server and create databases like so:

![image](https://user-images.githubusercontent.com/14934475/222178390-bd3262eb-c72f-4c5e-8d45-968872351ba1.png)

```
SELECT TOP 1000 *
FROM Projects.dbo.TX_Cosm_Data$
```

![image](https://user-images.githubusercontent.com/14934475/222183115-229afb5c-1c20-4157-970a-5739e59c308d.png)


```
SELECT *
FROM Projects.dbo.TX_Census_Data$
```

![image](https://user-images.githubusercontent.com/14934475/222183319-38418804-18cb-42ea-b3d9-2d37632c9b0c.png)


Ok, time to transform the County column to remove " " , "County", and "Texas". I could just cut off all characters following the first space in that column, but I have to be careful because some county names have two words:

![image](https://user-images.githubusercontent.com/14934475/222183930-59c31b3f-35c2-4e40-b077-173594aca986.png)

So instead, I'll tell SQL to keep all characters before " County". I'll create a new column as well.

```

ALTER TABLE Projects.dbo.TX_Census_Data$
ADD NewCounty VARCHAR(255)

UPDATE Projects.dbo.TX_Census_Data$
SET NewCounty = 
    CASE 
        WHEN CHARINDEX(' County', CountyName) > 0 
        THEN SUBSTRING(CountyName, 1, CHARINDEX(' County', CountyName) - 1) 
        ELSE CountyName 
    END 

SELECT * 
FROM Projects.dbo.TX_Census_Data$

```
Great, we're all set with a new properly named column.

![image](https://user-images.githubusercontent.com/14934475/222192555-74c9ff3f-b224-4788-8ce8-7e5bd5f01e33.png)

Next I'll pull up the other table and clean THAT county column.

```
SELECT TOP 1000 *
FROM Projects.dbo.TX_Cosm_Data$
UPDATE Projects.dbo.TX_Cosm_Data$
SET COUNTY = UPPER(LEFT(COUNTY, 1)) + LOWER(SUBSTRING(COUNTY, 2, LEN(COUNTY)))
```
![image](https://user-images.githubusercontent.com/14934475/222196228-ebe8d114-27da-46e7-bb7b-417feaeb27a1.png)

Great, now the county names in the Texas Cosmetology Licensure table are capitalised properly. It just looks better.

Since I've picked county data to use as a basis for analysis, the two tables needed to be joined at the county level.

```
SELECT cen.County AS CensusCounty, cos.County AS CosmCounty, cen.[GEO_ID], cen.[COUNTY] AS CensusCounty2, cen.[DP03_0063E], cos.[LICENSE TYPE], cos.[LICENSE NUMBER], cos.[COUNTY]
INTO cencos
FROM Projects.dbo.TX_Census_Data$ AS cen
INNER JOIN Projects.dbo.TX_Cosm_Data$ AS cos
ON cen.County = cos.COUNTY

Select TOP 100 *
FROM cencos
```

Hooray! Both tables have been joined, a new table has been created, the names are more manageable and we have just the right number of columns. We have excluded null columns and ones not pertinent to the research question -- this helps make the workspace clearer to the next person as well.

I have a couple of extra columns and I've already validated the data by looking through it. I'll drop those extra county data columns.

![image](https://user-images.githubusercontent.com/14934475/222790615-0a2a8187-2b99-4b85-9bc1-3f8ffd0f9a3c.png)

```
ALTER TABLE cencos
DROP COLUMN [CensusCounty], [CosmCounty]
```
I think now actually, I'm going to make the titles of the columns all uppercase. I'm allowed to change my mind, and so are you!

```
EXEC sp_rename 'cencos.CountyJoin', 'COUNTYJOIN', 'COLUMN';
EXEC sp_rename 'cencos.MedianIncome', 'MEDIANINCOME', 'COLUMN';
```

![image](https://user-images.githubusercontent.com/14934475/222790113-1c908bf0-f346-4042-a99f-161a3478ab7f.png)

![image](https://user-images.githubusercontent.com/14934475/222790438-293c34ea-1737-4d47-827c-9594323531a5.png)

### Incorporating Feedback

I ran this project by my data scientist friend, and he pointed out some duplicates I'd missed:

![image](https://user-images.githubusercontent.com/14934475/222806429-dcdc2ae6-5ac5-44f0-bd83-c40c777f002b.png)

Great catch Lenny, I'll go in and fix that.

First I'll query a list of unique combinations of values in columns:

```
SELECT ROW_NUMBER() OVER (PARTITION BY GEO_ID, COUNTYJOIN, MEDIANINCOME, [LICENSE TYPE], [LICENSE NUMBER] ORDER BY (SELECT NULL)) as row_num, GEO_ID, COUNTYJOIN, MEDIANINCOME, [LICENSE TYPE], [LICENSE NUMBER]
FROM cencos
```

Next I'll assign a unique number to each row:

```
SELECT ROW_NUMBER() OVER (PARTITION BY GEO_ID, COUNTYJOIN, MEDIANINCOME, [LICENSE TYPE], [LICENSE NUMBER] ORDER BY (SELECT NULL)) as row_num, *
FROM cencos
```

I'll create an ID column and delete duplicates:

```
ALTER TABLE cencos ADD id INT IDENTITY(1,1)

DELETE FROM cencos
WHERE id IN (
    SELECT id
    FROM (
        SELECT ROW_NUMBER() OVER (PARTITION BY GEO_ID, COUNTYJOIN, MEDIANINCOME, [LICENSE TYPE], [LICENSE NUMBER] ORDER BY (SELECT NULL)) as row_num, id
        FROM cencos
    ) t
 WHERE row_num > 1)
 ```
 
![image](https://user-images.githubusercontent.com/14934475/222807022-88cf79cf-46cf-49df-8c93-92d1158417b2.png)

Excellent! We've made the license values distinct. The other recurring values make sense: county data aligns with the GEO_ID, which is likely to align with median income.

I've now done one of the most important parts of data science, data cleaning. We went from over a thousand columns of poorly labeled data of different lengths separated into two tables, and brought it down to five neatly labeled columns, the same length, of exactly what we wanted.

It's no wonder data cleaning is the thing data scientists spend the most time on. The analysis part will be simple. It's not 'til the next project, though!

Let's revisit the prompt to advise next steps. This is the question we'll answer in the next project.

> A stakeholder is asking me whether aesthetician licenses are more densely occurring in higher-income areas. They also invite me to share other insights around geographical characteristics and aesthetician licensure.

![image](https://user-images.githubusercontent.com/14934475/222792371-5597b9e3-627e-4798-83c9-33142fa5ceab.png)






