SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT Location, date,total_cases,new_cases,total_deaths, population FROM PortfolioProject..CovidDeaths ORDER BY 1,2;

--Total cases vs Total Deaths 
SELECT Location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE Location = 'Qatar' AND  continent IS NOT NULL
ORDER BY 1,2;

--Total cases vs Population  -- Percentage of Population got Covid
SELECT Location, date,total_cases,total_deaths, population ,(total_cases/population)*100 as PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths 
WHERE Location = 'Qatar' AND  continent IS NOT NULL
ORDER BY 1,2;

--Countries with highest infection rate compared to the population
SELECT Location,population,MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC;

--countries with highest death count per population 
SELECT Location,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--Continent with highest death count per population 
SELECT continent,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global Numbers
SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int))as total_deaths , 
SUM(CAST(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY 1,2

--Data from Covid Vaccination table
SELECT * FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4;

--Joining table CovidDeath with CovidVaccine

SELECT * FROM PortfolioProject..CovidDeaths  as de
JOIN PortfolioProject..CovidVaccinations as va
on de.location = va.location
and de.date = va.date 

-- Total population vs Vaccination using CTE

WITH PopVsvac (continent,location,date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT de.continent,de.location,de.date,de.population,va.new_vaccinations,
SUM(CAST(va.new_vaccinations as INT)) OVER(PARTITION BY de.location ORDER BY de.location,de.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths  as de
JOIN PortfolioProject..CovidVaccinations as va
on de.location = va.location
and de.date = va.date 
WHERE de.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
from PopVsvac

--Creating View to store date for later visualizations
Go
CREATE VIEW PercentagePopulationVaccinatedView as 
SELECT de.continent,de.location,de.date,de.population,va.new_vaccinations,
SUM(CAST(va.new_vaccinations as INT)) OVER(PARTITION BY de.location ORDER BY de.location,de.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths  as de
JOIN PortfolioProject..CovidVaccinations as va
on de.location = va.location
and de.date = va.date 
WHERE de.continent IS NOT NULL;
