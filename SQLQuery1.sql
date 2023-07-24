SELECT *
FROM PortfolioProject..CovidDeaths$
--WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at the Total Cases vs population
-- Shows what percentage of population got covid
SELECT location, date,total_cases, population, (total_cases/population)*100 as CasesPerPopulation
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE 'Malay%'
ORDER BY 1,2

--looking at Countries that have the highest Infection rate compared to the population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
GROUP BY population, location
ORDER BY 4 DESC


-- Looking at Countries with the highest number of deaths per population

SELECT location, max(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing the continents with the highest death count

SELECT continent, max(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

--Total Global Number
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1


--Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM PortfolioProject..CovidDeaths$ AS dea
JOIN PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM PortfolioProject..CovidDeaths$ AS dea
JOIN PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingVaccinated/population)*100 AS PercentofVaxPopulation
FROM PopvsVac

DROP TABLE IF exists #percentpopulationVAccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(250),
location nvarchar(250),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM PortfolioProject..CovidDeaths$ AS dea
JOIN PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, (RollingVaccinated/population)*100 AS PercentofVaxPopulation
FROM #PercentPopulationVaccinated
ORDER BY 2,3




-- Creating View to store date for later visualisations

CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM PortfolioProject..CovidDeaths$ AS dea
JOIN PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
