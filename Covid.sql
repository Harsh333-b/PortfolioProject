SELECT * FROM dbo.Sheet2$

SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Sheet2$';
USE Vacine;
SELECT location,date,total_cases,total_deaths 
FROM dbo.Sheet2$
ORDER BY 1,2;

-- lOOKING at Total cases Vs Total Deaths
-- Shows likehood of dying if you contract covid in your country

--SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 AS DeathPercentage
--FROM dbo.Sheet2$
--WHERE location LIKE '%states%'
--ORDER BY 1,2

SELECT location,
       date,
       total_cases,
       total_deaths,
       (CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)) * 100 AS DeathPercentage
FROM dbo.[Sheet2$]
WHERE location LIKE '%states%'
ORDER BY 1,2;


-- Looking at Total cases Vs population
-- Shows what percentage of population got Covid
SELECT location,
       date,
       population,
       total_cases,
       (CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS Population_Percentage
FROM dbo.[Sheet2$]
WHERE location LIKE '%states%'
ORDER BY 1,2;

SELECT location,
       date,
       population,
       total_cases,
       CONCAT(ROUND((CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100, 2), '%') AS Population_Percentage
FROM dbo.[Sheet2$]
--WHERE location LIKE '%India%'
ORDER BY 1,2;


-- Looking at Countries with Hightest Infection Rate compared to Population
SELECT location,
       population,
       MAX(total_cases) AS HighestInfectionCount,
       MAX((CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100) AS PercentPopulationInfection
FROM dbo.[Sheet2$]
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfection DESC; -- highest no. first

-- Showing Countries with Highest Death Count Per Population
SELECT location,MAX(total_deaths) AS TotalDeathCount
FROM dbo.Sheet2$
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount -- Convert it nvarchar(255) to INT
FROM dbo.Sheet2$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT count(*) 
FROM dbo.Sheet2$
WHERE continent IS NOT NULL
--ORDER BY 3,4;

SELECT * 
FROM dbo.Sheet2$
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- Let's break things down by continent
SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount -- Convert it nvarchar(255) to INT
FROM dbo.Sheet2$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

USE Vacine; -- Run this every time when you come after long time & want to reuse it

-- Showing continets with the highest death count per population
-- Global Numbers , advance
SELECT 
    date,
    SUM(new_cases) AS TotalCases,
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
    CASE 
        WHEN SUM(new_cases) != 0 THEN 
            SUM(CAST(new_deaths AS INT)) * 100.0 / SUM(new_cases) 
        ELSE 
            0 
    END AS DeathPercentage
FROM dbo.[Sheet2$]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

SELECT 
    SUM(new_cases) AS TotalCases,
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
    CASE 
        WHEN SUM(new_cases) != 0 THEN 
            SUM(CAST(new_deaths AS INT)) * 100.0 / SUM(new_cases) 
        ELSE 
            0 
    END AS DeathPercentage
FROM dbo.[Sheet2$]
WHERE continent IS NOT NULL;

SELECT * 
from DBO.Sheet2$;

SELECT COUNT(*) AS ColumnCount -- find column count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Sheet2$' AND TABLE_SCHEMA = 'dbo';

USE PortfolioProject
USE Vacine
SELECT * FROM dbo.Sheet1$;


SELECT * 
FROM dbo.Sheet1$ death
JOIN dbo.sheet2$ vacine
ON death.location = vacine.location
AND death.date = vacine.date;

USE PortfolioProject; 
USE Vacine;

-- Check if the tables exist in the correct schema
SELECT * 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN ('Sheet1$', 'Sheet2$') AND TABLE_SCHEMA = 'dbo';


WITH PopVsVac(continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM dbo.Sheet1$ dea
JOIN dbo.Sheet2$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3;
)
SELECT * FROM PopVsVac;

USE Vacine;
-- Temp Table
CREATE TABLE #percentPopulationVaccinated2
(
Continent NVARCHAR(233),
Location NVARCHAR(245),
Date DATETIME,
Population NUMERIC,
New_vaccination NUMERIC,
RollingPeopleVaccinated NUMERIC);