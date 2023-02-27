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

Now it's time to move on to dashboard creation in Power BI.

### Power BI Dashboard Creation

I'll add my SQL query to Power BI.

![image](https://user-images.githubusercontent.com/14934475/221694990-5781a5b4-b717-499f-a297-404c4406cd06.png)

Next I'll rename the table from the default to make it more workable. I'll select the Classic theme ahead of time so it won't alter my later creations undesireably.
I'll create a textbox for the label, pick a background colour (say mustard with high transparency for a pale goldenrod colour) and add some slicers. We know the stakeholders are interested in country results especially, so it'll be key to include that. I'll put country at the top for the user's convenience. These slicers are what will empower the user to quickly interact with data insights.

![image](https://user-images.githubusercontent.com/14934475/221699110-ab1d4e91-9e42-4f26-bc4f-6b8fa26c3a83.png)

I want to bring more insights to the rest of the dashboard. First I'll create a new table for additional calculations.

![image](https://user-images.githubusercontent.com/14934475/221699560-7e6edcb1-811b-4af3-9c9b-ae58d557b953.png)

Now I'll create a new measure. I want to use this measure to count how many athletes are in the dataset. I'll create this formula:

```
# of Athletes = DISTINCTCOUNT('Olympic Games Data'[ID])
```
The unique identifying factor in this dataset is actually medals, though, so I'll create another formula:

```
# of Medals = COUNTROWS( 'Olympic Games Data')
```

I will then convert this table into Calculation format by hiding the unused column (which contains no calculations). 

![image](https://user-images.githubusercontent.com/14934475/221701089-3db37f7f-42f5-4be3-bbce-744b36235011.png)

Apologies that I don't have the "before" screenshot for context - I had just saved and erased any easy shot at the reliable ctrl + z.

![image](https://user-images.githubusercontent.com/14934475/221702341-8f613c59-844d-4769-8af5-2d3737b24a0f.png)

> I'll add that project creation, for me, is an exercise in quality vs. completion. You could say that portfolio projects are an opportunity for me to demonstrate that I have attention to detail. But this week (27/2/2023) I have a goal of one SQL project per day. Will I meet that goal if I get meticulous about screenshots? Not easily. Will I go back and polish them? Probably not for all projects. Perfect is the enemy of done. 

Back to the dashboard creation process. I'll add a card to the canvas.

![image](https://user-images.githubusercontent.com/14934475/221704665-30b5e03c-94a4-478c-8a90-8b0540011bc5.png)

![image](https://user-images.githubusercontent.com/14934475/221705317-7799e082-bc62-40ea-9414-31c755bbe28e.png)

I'll update the display unites to include the full number of athletes:

![image](https://user-images.githubusercontent.com/14934475/221706447-ba16ccf6-ca89-46b4-b3fc-3ad9c18369ba.png)

And format the KPI with a comma. Then I'll do the same for the full number of medals.

![image](https://user-images.githubusercontent.com/14934475/221709227-344a1bc8-750a-4662-9fc2-1ebb9d67cbf4.png)

I'll create two donut charts for the gender breakdowns of athletes and medals. I'll adjust the formatting to pick a dark colour for women and a light colour for men (just using yin and yang gender coding logic for convenience. Gender may be a construct but Olympics athlete data is still hashing that out). I'll add percentage data callouts. It looks like women are overrepresenting ever so slightly in the medals category. 

![image](https://user-images.githubusercontent.com/14934475/221711191-864bc7ff-9aa2-4dcb-900f-2f2537f84605.png)












