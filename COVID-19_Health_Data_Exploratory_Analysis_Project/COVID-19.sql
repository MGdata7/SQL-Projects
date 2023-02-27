--In this project, I will extract and analyse COVID-19 vaccination, case, and death data using SQL. The data source is updated daily at https://ourworldindata.org/covid-deaths.

SELECT * 
FROM CovidDeaths$
ORDER BY 3,4

--SELECT * 
--FROM CovidVaccinations$
--ORDER BY 3,4

--First, I will select the data which I will use for this project.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2

--Now I will compare the total amount of COVID cases with the total amount of COVID deaths per country. 
--From this query we can gather the likelihood of dying from COVID within each country.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
ORDER BY 1,2

--The next query hones in on Ireland data and the likelihood of dying from COVID within Ireland.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE location = 'Ireland'
AND continent IS NOT NULL
ORDER BY 1,2

--This next query will calculate the total percentage of population infected with COVID-19 in Ireland.

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths$
--WHERE location = 'Ireland'
ORDER BY 1,2

--Next, let's write a query to compare the countries with the highest infection rate compared to population.

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
--Where location = 'Ireland'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Our next query will calculate the highest death count by country.

SELECT LOCATION, MAX(cast(Total_deaths as int)) AS TotalDeathCount
From CovidDeaths$
--Where location = 'Ireland'
WHERE continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Next, let's do an analytic breakdown of the COVID infection and death data by continent.

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
--Where location = 'Ireland'
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Now let's run a query to look at the global COVID-19 infection death data, as well as the death percentage globally.

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDeaths$
--Where location = 'Ireland'
WHERE continent is not null 
--Group By date
ORDER BY 1,2

--Moving on, we also have vaccination data to explore and analyse. Let's explore the number of new vaccinations by continent, country, and population. 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
Join CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3;

--Let's next use a Common Table Expression (CTE) to perform a calculation on PARTITION BY in our previous query.

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Nearly done--we'll use a temp table to perform a calculation on PARTITION BY in our last query.

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated;

--Finally, I will create a View so I can store this data for a later visualisation in Tableau.
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
