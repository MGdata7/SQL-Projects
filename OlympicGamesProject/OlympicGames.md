# Data Cleaning and Visualisation Project with Olympic Games Data
## SQL and Power BI

![image](https://user-images.githubusercontent.com/14934475/221599107-e5c6283a-a4cc-44c1-9550-a3af032f6d2c.png)

In this project I will clean dirty data from a dataset to make it ready for use, then create a dashboard visualisation to clearly communicate data insights to stakeholders. This project was designed by Ali Ahmad on YouTube.

### The Business Problem

For the purposes of this exercise, let's say I've been tasked with showing trends and findings on how various countries have historically performed in the summer Olympic Games.

Stakeholders are curious about athlete details and wish me to share any other trends I might find. Primarily the interest is with country performance, with the user having the option to select their own country.

While this may not seem like a typical tech industry prompt, it is quite similar to business problems that I came across working as a research analyst at Morgan McKinley's FDI Research Team.

Sometimes it's helpful to take historical public data - like CSO statistics in Ireland - and visualise it for comparison to analysis of more privatised data. And you can't do that properly until the data is clean.

So let's get started in SQL cleaning the data.

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

I won't make any changes to the ID column, but I'll rename the 'Name' column as 'Athlete Name'. I'll also rename M and F as 'Male' and 'Female' using a CASE statement. I'll include age as a column in this query and create bins for the ages with labels.
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

I'll create two donut charts for the gender breakdowns of athletes and medals. I'll adjust the formatting to pick a dark colour for women and a light colour for men (just using yin and yang gender coding logic for convenience. Gender may be a construct but Olympics athlete data is still hashing that out). I'll add percentage data callouts. It looks like women are overrepresenting ever so slightly in the medals category. It's narrow enough that I can't read too far into it.

![image](https://user-images.githubusercontent.com/14934475/221711191-864bc7ff-9aa2-4dcb-900f-2f2537f84605.png)

I'd like to add more visualisations to this dashboard to illustrate the number of medals and how it relates to sport type and level of medal received. I'll do a bar chart for clarity and variety. I'll add the "sport" variable and "# of medals" calculation as axes and convert the chart to a stacked bar chart, which will automatically sort from greatest to least. Next I will add the "medals" variable. Now, automatically a large number of not-registered rows are muddying up our visualisation. We're not really interested in those data points because we can't derive much insight from them.

![image](https://user-images.githubusercontent.com/14934475/221715979-6bf30cdf-0ee1-46a5-9f25-dc76779596a7.png)

![image](https://user-images.githubusercontent.com/14934475/221716146-644d6bda-49c6-449c-b268-450d50396859.png)

The solution I will use here is to create a new measure which excludes "not registered" medal rows. The new measure will only include bronze, silver, and gold medals.

![image](https://user-images.githubusercontent.com/14934475/221716458-1fc93b0d-5229-4311-ac0b-159f5893632d.png)

```
# of Medals (Registered) = CALCULATE( [# of Medals] , FILTER ( 'Olympic Games Data' , 'Olympic Games Data'[Medal] = "Bronze" || 'Olympic Games Data'[Medal] = "Silver" || 'Olympic Games Data'[Medal] = "Gold"))
```

I'll add this new calculation (# of Medals (Registered)) in the X-axis field, and we're in business. Our unnecessary data has been excluded with the use of filtering in a calculation.

![image](https://user-images.githubusercontent.com/14934475/221717735-2f5914d7-dd06-4e9a-8403-5b7d9de45952.png)

While I'm at it, I'll use that new calculation to update my KPI box on the left. I want data to be consistent.

![image](https://user-images.githubusercontent.com/14934475/221717958-56ce6474-c74b-4b7b-85f2-0ce08d44fd98.png)

I'll update the medals donut chart as well. The stacked bar chart could use some formatting, I'll take care of that too. I'll add data labels, remove the legend, add a border, change the font size and add colour coding.

![image](https://user-images.githubusercontent.com/14934475/221718948-82144af2-0ba8-4ce9-8ddd-2a064074c615.png)

In order to protect the formatting standards, I'll copy and paste this chart to create its sibling. The key change in the second bar chart, other than the shape, is that it now shows the medal earnings of the top ranking athletes in Olympic history.

![image](https://user-images.githubusercontent.com/14934475/221720837-b0b072cd-2d73-4573-ad27-09076c4c144f.png)

Once again, I'll copy that first bar chart and bring it lower, then transform it into a line graph. The benefit of copying is that I save time by not having to redo the colors and other style choices.

I'll sort this line chart by year, ascending. Now we have this nice timeline.

![image](https://user-images.githubusercontent.com/14934475/221721059-f66cf6a6-d18c-49c2-9171-ffb3dfaa7b81.png)

I'll rename this view of the project:

![image](https://user-images.githubusercontent.com/14934475/221721167-64491ffe-dd88-4d6f-8b1d-d08f114bc77e.png)

### Final Dashboard: Main View

And we're done. The monster reveal:

![image](https://user-images.githubusercontent.com/14934475/221722068-65b577cc-a0aa-4d69-a944-2b3e39685f95.png)

Just kidding. The reveal:

![image](https://user-images.githubusercontent.com/14934475/221721301-631f6fa7-3dff-4ead-a9ad-2eae58e65290.png)

I flew too close to the sun with that "burnt mustard", let me lighten it up a bit.

![image](https://user-images.githubusercontent.com/14934475/221721783-50190e01-84ce-4f5c-9978-7dea17d2cde9.png)

Ahhh.

### Insights

Some quick insights we can draw from the dashboard with all data:

- Over 100,000 athletes and over 34,000 medals are on record for the summer Olympics between 1896 and 2016.
- People coded as women make up around 24% of the athletes and around 27% of the medals. The rest are coded as men.
- Medals of all kinds have been on the rise in terms of quantity since 1896. They had a noticeable peak in summer of 1920 followed by a decline in 1924.
- Michael Phelps leads dramatically with 23 gold medals, 2 silver and 2 bronze. The next most medal-adorned athlete is Larysa Latynina, with 9 gold, 5 silver, and 4 bronze. Nikolay Andrianov is thirdmost Olympic-medal-decorated in history: 7/5/3, although Mark Spitz has more gold medals than Andrianov (9) as does Sawao Kato (8).
- Athletics, Swimming, and Boxing have the most medals in quantity, or perhaps the most participants, or both.

Let's focus in on Ireland.

![image](https://user-images.githubusercontent.com/14934475/221723536-9a8b49f2-06a2-4334-b72b-0590e788d90d.png)

- Ireland historically has a stronger male gender makeup than the global average.
- Michelle Smith is the most decorated Irish Olympic athlete with 3 gold medals and 1 bronze. Pat O'Callaghan follows with 2 gold medals.
- For medals overall by sport, Ireland has claimed the most awards in Boxing. It has claimed the most *gold* medals in Athletics.

If we focus in on just boxing in Ireland using the slicers on the left, we can see that while the women's representation in this sport category diminishes to nearly nothing, Katie Taylor still comes out swinging with one of two total gold medals.

![image](https://user-images.githubusercontent.com/14934475/221724451-133ecc5a-afb3-4414-8d65-50132bc42d52.png)

To the surprise of none of her fans, Katie is, statistically, punching well above her weight.

![image](https://user-images.githubusercontent.com/14934475/221725016-97fdfa1e-3f04-4854-bdd0-0ffad2a9051f.png)

















