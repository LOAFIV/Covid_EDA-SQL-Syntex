/*
Covid 19 Data Exploration 


Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/



SELECT *
From [Covid-19 Data].dbo.CovidDeaths$

--Select data to use

SELECT Location, Date, total_cases, new_cases, total_deaths, population
From [Covid-19 Data].dbo.CovidDeaths$
Order by 1,2




--Looking at Total Cases vs Total Deaths

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 As Death_Percentage
From [Covid-19 Data].dbo.CovidDeaths$
Order by 1,2



--Looking at Total Cases vs Total Deaths (Shows probability of dying if Covid is contracted in your country)

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 As Death_Percentage
From [Covid-19 Data].dbo.CovidDeaths$
WHERE Location like 'Nigeria'
Order by 1,2



--Looking at Total Cases vs Population (Shows what percentage of the population contracted Covid)


SELECT Location, Date, total_cases, population, (total_cases/population)*100 As PercentPopulationInfected
From [Covid-19 Data].dbo.CovidDeaths$
WHERE Location like '%states%'
Order by 1,2

SELECT Location, Date, total_cases, population, (total_cases/population)*100 As PercentPopulationInfected
From [Covid-19 Data].dbo.CovidDeaths$
WHERE Location like 'Nigeria'
Order by 1,2



--Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 As PercentPopulationInfected
From [Covid-19 Data].dbo.CovidDeaths$
Group by Location, Population
Order by PercentPopulationInfected desc




--Showing Countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeaths
From [Covid-19 Data].dbo.CovidDeaths$
WHERE Continent is not null
Group by Location
Order by TotalDeaths desc



--Breaking things down by Continent
--Showing continent with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths
From [Covid-19 Data].dbo.CovidDeaths$
WHERE Continent is null
Group by location
Order by TotalDeaths desc

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths
From [Covid-19 Data].dbo.CovidDeaths$
WHERE Continent is not null
Group by continent
Order by TotalDeaths desc



--- Global Outlook

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Covid-19 Data].dbo.CovidDeaths$
WHERE Continent is not null
Group by date
Order by 1,2


SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Covid-19 Data].dbo.CovidDeaths$
WHERE Continent is not null
--Group by date
Order by 1,2
 


--Looking at Total Population Vs Vaccinations

SELECT *
from [Covid-19 Data].dbo.CovidVaccinations$


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date )
as RollingCountVacc
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by  2, 3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
	Over (Partition by dea.location order by dea.location, dea.date )
	as RollingCountVacc
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by  2, 3
)


Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Select * from #PercentPopulationVaccinated


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date )
as RollingPeopleVacc
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by  2, 3)


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date )
as RollingPeopleVacc
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by  2, 3)


Create view TotalDeaths_by_continent as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths
From [Covid-19 Data].dbo.CovidDeaths$
WHERE Continent is not null
Group by continent
--Order by TotalDeaths desc


Create view higest_death_by_population as
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeaths
From [Covid-19 Data].dbo.CovidDeaths$
WHERE Continent is not null
Group by Location
--Order by TotalDeaths desc

Create view Percent_of_population_US as
SELECT Location, Date, total_cases, population, (total_cases/population)*100 As PercentPopulationInfected
From [Covid-19 Data].dbo.CovidDeaths$
WHERE Location like '%states%'
--Order by 1,2