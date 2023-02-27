# Data Cleaning and Visualisation Project with Olympic Games Data
## SQL and Power BI

![image](https://user-images.githubusercontent.com/14934475/221599107-e5c6283a-a4cc-44c1-9550-a3af032f6d2c.png)

In this project I will clean dirty data from a dataset to make it ready for use, then create a dashboard visualisation to clearly communicate data insights to stakeholders.

### The Business Problem

For the purposes of this exercise, let's say I've been tasked with showing trends and findings on how various countries have historically performed in the summer Olympic Games.
Stakeholders are curious about competitor details and wish me to share any other trends I might find. Primarily the interest is with country performance, with the user having the option to select their own country.

While this may not seem like a typical tech industry prompt, it is quite similar to business problems that I came across working as a research analyst at Morgan McKinley's FDI Research Team.
Sometimes it's helpful to take historical public data - like CSO statistics in Ireland - and visualise it for comparison to analysis of more privatised data. And you can't do that properly until the data is clean.
So let's get started in SQL.

### Data Cleaning in SQL Server

First I'll view the top 1000 rows of key data from the Athletes Events Results database.

```
SELECT TOP (1000) [ID]
		,[Name]	
		,[Sex]
		,[Age]
		,[Height]
		,[Weight]
		,[NOC]
		,[Games]
		,[City]
		,[Sport]
		,[Event]
		,[Medal]
FROM olympic_games.dbo.athletes_event_results
```

![image](https://user-images.githubusercontent.com/14934475/221684629-60a7f94e-3330-4c95-aa8e-71d2617bb153.png)

Next I'll recategorise and relabel some of this data so that it's easier to work with and understand. This will help me later when visualising the data in Power BI.

I won't make any changes to the ID column, but I'll rename the 'Name' column as 'Competitor Name'. I'll also rename M and F as 'Male' and 'Female' using a CASE statement. I'll include age as a column in this query and create bins for the ages with labels.
Now, I know the question is about specifically summer Olympic games, but the summer and winter games are all combined here along with the year. I will separate the year from the season using CHARINDEX so I can break down the analysis by season - the WHERE clause at the end completes this.
I'll also relabel the "NA" column for clarity.

```
SELECT 
	[ID]
	,[Name] AS 'Athlete Name' -- Renamed column
	,CASE WHEN Sex = 'M' THEN 'Male' ELSE 'Female' END AS Sex --Relabeling binary sex column
	,[Age] --Including age
	,CASE	WHEN [Age] < 18 THEN 'Under 18'
			WHEN [Age] BETWEEN 18 AND 25 THEN '18-25'
			WHEN [Age] BETWEEN 25 AND 30 THEN '25-30'
			WHEN [Age] > 30 THEN 'Over 30' 
	END AS [Age Grouping] --Creating bins for ages
	,[Height] --Including height
	,[Weight] --Including weight
	,[NOC] AS 'Nation Code'--Renamed column
	,LEFT(Games, CHARINDEX(' ',Games)-1) AS 'Year'--Split column to isolate year
	,RIGHT(Games,CHARINDEX(' ',REVERSE(Games))-1) AS 'Season'--Split column to isolate season
	,[Sport]
	,[Event]
	,CASE WHEN Medal = 'NA' THEN 'Not registered' ELSE Medal END AS Medal --Clarify labeling of NA column
	FROM dbo.athletes_event_results
	WHERE RIGHT(Games,CHARINDEX(' ', REVERSE(Games))-1) = 'Summer'--Where clause to isolate summer season
```
Here are our lovely new columns, relabeled and reorganised.

![image](https://user-images.githubusercontent.com/14934475/221690193-3ed68d10-563f-4a61-a96a-c3aa112a10b4.png)







