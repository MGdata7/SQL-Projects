--Glimpse Olympic Games Data

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

--Clean data and prepare it for analysis

SELECT 
	[ID]
	,[Name] AS 'Athlete Name' -- Renamed column
	,CASE WHEN Sex = 'M' THEN 'Male' ELSE 'Female' END AS S --Relabeling binary sex column
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
	--,[Games]
	--,[City]
	,[Sport]
	,[Event]
	,CASE WHEN Medal = 'NA' THEN 'Not registered' ELSE Medal END AS Medal --Clarify labeling of NA column
	FROM dbo.athletes_event_results
	WHERE RIGHT(Games,CHARINDEX(' ', REVERSE(Games))-1) = 'Summer'--Where clause to isolate summer season



