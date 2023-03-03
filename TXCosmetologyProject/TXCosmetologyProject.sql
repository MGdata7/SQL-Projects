--Glimpse both tables

SELECT *
FROM Projects.dbo.TX_Cosm_Data$

SELECT *
FROM Projects.dbo.TX_Census_Data$

--Removing top two rows

DELETE TOP(2)  
FROM [Projects].[dbo].[TX_Census_Data$]  

--Creating new county column with just county name

ALTER TABLE Projects.dbo.TX_Census_Data$
ADD County VARCHAR(255)

UPDATE Projects.dbo.TX_Census_Data$
SET County = 
    CASE 
        WHEN CHARINDEX(' County', CountyName) > 0 
        THEN SUBSTRING(CountyName, 1, CHARINDEX(' County', CountyName) - 1) 
        ELSE CountyName 
    END 

	SELECT * 
	FROM Projects.dbo.TX_Census_Data$

--Glimpse Texas licensure data

SELECT TOP 1000 *
FROM Projects.dbo.TX_Cosm_Data$

-- Update the values in the new column to lowercase and capitalize the first letter
UPDATE Projects.dbo.TX_Cosm_Data$
SET COUNTY = UPPER(LEFT(COUNTY, 1)) + LOWER(SUBSTRING(COUNTY, 2, LEN(COUNTY)))

--Join tables, create new table with certain columns, rename data
--Columns selected: County, income, ID, and license detail data

SELECT cen.County AS CensusCounty, cos.County AS CosmCounty, cen.[GEO_ID], cen.[COUNTY] AS CountyJoin, cen.[DP03_0063E], cos.[LICENSE TYPE], cos.[LICENSE NUMBER]
INTO cencos
FROM Projects.dbo.TX_Census_Data$ AS cen
INNER JOIN Projects.dbo.TX_Cosm_Data$ AS cos
ON cen.County = cos.COUNTY

SELECT TOP 1000 *
FROM cencos

--Drop duplicate columns

ALTER TABLE cencos
DROP COLUMN [CensusCounty], [CosmCounty]

--Rename DP03_0063E column
EXEC sp_rename 'cencos.DP03_0063E', 'MedianIncome', 'COLUMN';

--Rename other columns for consistency
EXEC sp_rename 'cencos.CountyJoin', 'COUNTYJOIN', 'COLUMN';
EXEC sp_rename 'cencos.MedianIncome', 'MEDIANINCOME', 'COLUMN';

SELECT TOP 100 *
FROM cencos




