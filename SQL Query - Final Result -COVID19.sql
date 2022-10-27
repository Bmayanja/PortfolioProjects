SELECT*
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT*
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract COVID in Canada
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Canada%'
ORDER BY 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of Population got COVID
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Canada%'
ORDER BY 1,2

--Looking at Contries with the Highest infection rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--showing the countries with the Highest Death Count per Population

SELECT location, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY Total_Death_Count DESC

--Let's break it down by Continent
--Showing the continents with the Highest Death count per population

SELECT continent, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY Total_Death_Count DESC

--VACCINATIONS TABLE

SELECT*
FROM PortfolioProject..CovidVaccinations
ORDER BY 1, 2

--Join both the Death and Vaccination tables

SELECT*
FROM PortfolioProject..CovidDeaths AS Death 
JOIN PortfolioProject..CovidVaccinations AS Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date

--Looking at the Total Population Vs Vaccinations

SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations
FROM PortfolioProject..CovidDeaths AS Death
JOIN PortfolioProject..CovidVaccinations AS Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL
ORDER BY 2,3


--USE CTE

WITH PopvsVacc (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(CONVERT(INT,Vacc.new_vaccinations)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths  Death
JOIN PortfolioProject..CovidVaccinations  Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVacc

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
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
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(CONVERT(INT,Vacc.new_vaccinations)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths  Death
JOIN PortfolioProject..CovidVaccinations  Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL
--ORDER BY 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(CONVERT(INT,Vacc.new_vaccinations)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths  Death
JOIN PortfolioProject..CovidVaccinations  Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL
--ORDER BY 2,3


SELECT*
FROM PercentPopulationVaccinated