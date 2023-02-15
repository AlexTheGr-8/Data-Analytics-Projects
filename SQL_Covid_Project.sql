SELECT *
FROM Covid_project.dbo.covid_deaths
ORDER BY location, date



-- Selecting the data that will be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_project.dbo.covid_deaths
ORDER BY location, date


-- Examining Total cases vs Total deaths
-- Shows the likelyhood of dying if a person has covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid_project.dbo.covid_deaths
ORDER BY location, date


-- Examining Total cases vs Total population
-- Shows what percentage of population that got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentageInfected
FROM Covid_project.dbo.covid_deaths
ORDER BY location, date

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid_project.dbo.covid_deaths
Group by Location, Population, date
order by PercentPopulationInfected desc



-- Finding countries with the highest infection rate compared to population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)*100) AS HighestPercentageInfected
FROM Covid_project.dbo.covid_deaths
GROUP BY location, population
ORDER BY HighestPercentageInfected DESC

-- Finding continents with highest death count
SELECT continent, MAX(CAST(total_deaths AS int)) AS ContinentTotalDeathCount
FROM Covid_project.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY ContinentTotalDeathCount DESC


-- Finding countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Covid_project.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global Numbers
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM Covid_project.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, TotalCases


SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM Covid_project.dbo.covid_deaths
WHERE continent IS NOT NULL
ORDER BY TotalCases, TotalDeaths


-- Looking at Population vs Vacciations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Covid_project.dbo.covid_deaths dea 
INNER JOIN Covid_project.dbo.covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3 


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid_project.dbo.covid_deaths dea
Join Covid_project.dbo.covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated