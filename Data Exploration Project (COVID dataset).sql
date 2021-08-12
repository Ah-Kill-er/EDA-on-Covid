/* 
COVID-19 Data Exploration

SKILLS USED: JOINS, CTE, TEMP TABLES, WINDOW FUNCTIONS, Aggregate Functions, Creating Views, Converting Data Types

*/

create database EDAonCOVID

SELECT * FROM coviddeaths
ORDER BY location,date

SELECT* FROM covidvaccinations
ORDER BY location,date

-- Selecting data that we are going to be using.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2;

-- Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS [Percentage of Death] 
FROM coviddeaths
WHERE location = 'India'


-- Total Cases vs Total Populaiton.
-- Shows what percentage of Population got infected by COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS [Percentage of Infected Population]
FROM coviddeaths
--WHERE location = 'India'
WHERE continent is not null
ORDER BY 1,2

-- Countries with Highest Infection rate compared to Population

SELECT location, population, ISNULL(MAX(total_cases),0) AS [Highest Infection Count], ISNULL(MAX((total_cases/population)*100),0) AS [Percentage of Infected Population] 
FROM coviddeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY [Percentage of Infected Population] DESC

-- Countries with Highest Death count per Population

SELECT location, ISNULL(MAX(CAST(total_deaths AS int)),0) AS [Total Death Count]
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY [Total Death Count] DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continent with the highest Infection rate.

SELECT continent, MAX(total_cases) AS [Highest Infection Count], MAX((total_cases/population)*100) AS [Percentage of Infected Population] 
FROM coviddeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY [Percentage of Infected Population] DESC  

-- Showing continent with the highest death count.

SELECT continent, MAX(CAST(total_deaths AS int)) AS [Total Death Count]
FROM coviddeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY [Total Death Count] DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS [TOTAL CASES], SUM(CAST(new_deaths AS int)) AS [TOTAL DEATHS],  SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS [PERCENTAGE OF DEATH]
FROM coviddeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL

-- Moving towards Vaccinations
-- Total population vs Vaccinations
-- Shows Percentage of Population that has received at least one covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, ISNULL(vac.new_vaccinations,0)
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform Calculations on Partition by to find out Total Population vs Vaccinations

WITH popvsvac (Continent, Location, Date, Population, New_Vaccinations, [Rolling Count Of People Vaccinated]) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS [Rolling Count Of People Vaccinated]
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,([Rolling Count Of People Vaccinated]/population*100) 
FROM popvsvac
--where location = 'india'

--Using Temp Table to perform calculations on partition by in previous query

DROP TABLE IF EXISTS #percentageOfPopVaccinated
CREATE TABLE #percentageOfPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #percentageOfPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS [Rolling Count Of People Vaccinated]
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/population*100) 
FROM #percentageOfPopVaccinated
order by 2,3

-- Creating VIEW to store data for later visualizations
-- 1

CREATE VIEW vwPopulationInfectedPercentage AS
SELECT location, date, population, total_cases, (total_cases/population)*100 AS [Percentage of Infected Population]
FROM coviddeaths
--WHERE location = 'India'
WHERE continent is not null
--ORDER BY 1,2

-- 2

CREATE VIEW vwInfectionRateByCOUNTRY AS
SELECT location, population, MAX(total_cases) AS [Highest Infection Count], MAX((total_cases/population)*100) AS [Percentage of Infected Population] 
FROM coviddeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY location, population
--ORDER BY [Percentage of Infected Population] DESC

-- 3

CREATE VIEW vwDeathCountByCOUNTRY AS
SELECT location, MAX(CAST(total_deaths AS int)) AS [Total Death Count]
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY [Total Death Count] DESC

--4

CREATE VIEW vwInfectionRateByCONTINENT AS
SELECT continent, MAX(total_cases) AS [Highest Infection Count], MAX((total_cases/population)*100) AS [Percentage of Infected Population] 
FROM coviddeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY [Percentage of Infected Population] DESC 

--5

CREATE VIEW vwDeathCountByCONTINENT AS
SELECT continent, MAX(CAST(total_deaths AS int)) AS [Total Death Count]
FROM coviddeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY [Total Death Count] DESC

--6

CREATE VIEW vwGlobalNumbers AS
SELECT SUM(new_cases) AS [TOTAL CASES], SUM(CAST(new_deaths AS int)) AS [TOTAL DEATHS],  SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS [PERCENTAGE OF DEATH]
FROM coviddeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL 

--7

CREATE VIEW vwPercentPopulationVaccinated AS
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM PopvsVac




















