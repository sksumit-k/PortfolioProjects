SELECT *
FROM PortfolioProject..CovidDeaths  -- .. to get specific folder in portfolioproject which is coviddeaths
where continent is not null
order by 3,4 -- to make it like excel file

--SELECT *
--FROM PortfolioProject..CovidVaccinations -- .. to get specific folder in portfolioproject which is covidvaccinations
--order by 3,4

-- Selecting data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2 -- 2 for date order

-- looking at Total cases vs Total death

SELECT location, date, total_cases, total_deaths
FROM PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- shows likelyhood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage  -- (total_deaths/total_cases)*100 for death percentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'  -- to get data of 'united states'
and continent is not null 
order by 1,2

-- looking at Total cases vs population(shows what percentage of population got covid)  

SELECT location, date, population, total_cases, PercentagePopulationInfected = (total_cases/population)*100 -- (total_cases/population)*100 for cases percentage
FROM PortfolioProject..CovidDeaths
where location like '%states%' 
and continent is not null 
order by 1,2

-- looking at country with highest infection rate compared to the population  

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
where continent is not null 
group by location,population
order by PercentagePopulationInfected Desc

-- Showing countries with heighest deathcount per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount -- have to convert total_deaths from varchar(250) to int because it's not showing complete number
FROM PortfolioProject..CovidDeaths
where continent is not null  -- will remove all null naulues of continent (and will remove continents and shows only countries)
group by location
order by TotalDeathCount Desc

-- showing continents with the heighest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount -- have to convert total_deaths from varchar(250) to int because it's not showing complete number
FROM PortfolioProject..CovidDeaths
where continent is not null  -- will include null values as it's not taking any other country in north america except U.S.
group by continent
order by TotalDeathCount Desc

-- GLOBAL NUMBERS

-- global numbers(total cases globally DateWise, totaldeaths, and death percentage)

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
-- where location like '%states%' 
where continent is not null 
-- Group by date
Order by 1,2

-- Let's explore covid vaccination table
-- Firstly joint both tables on location and date

select *
From PortfolioProject..CovidDeaths dea -- dea for shortcut name
join PortfolioProject..CovidVaccinations vac -- vac for shortcut name
	on dea.location = vac.location
	and dea.date = vac.date
	order by 3,4

-- Looking at Total_population vs Vaccinations (means total amount of people in the world is been vaccinated)

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea -- dea for shortcut name
join PortfolioProject..CovidVaccinations vac -- vac for shortcut name
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- addind 'new vaccinations' to a new column date by date but ends when country name ends 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int))OVER(partition by dea.location order by dea.location, dea.date) as RollindPeopleVaccinated
--(RollindPeopleVaccinated/population)*100 --we can't use RollingPeopleVaccinated here like this we just created that column so we did it below, how it works( so, we have to create whether CTE(common table expression) or TEMP TABLE )
From PortfolioProject..CovidDeaths dea -- dea for shortcut name
join PortfolioProject..CovidVaccinations vac -- vac for shortcut name
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
 
 
 -- USE CTE
WITH PopvsVac(Continent,Location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int))OVER(partition by dea.location order by dea.location, dea.date) as RollindPeopleVaccinated
From PortfolioProject..CovidDeaths dea -- dea for shortcut name
join PortfolioProject..CovidVaccinations vac -- vac for shortcut name
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From PopvsVac


-- 'Or' we can use
-- (TEMP TABLE)

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int))OVER(partition by dea.location order by dea.location, dea.date) as RollindPeopleVaccinated
From PortfolioProject..CovidDeaths dea -- dea for shortcut name
join PortfolioProject..CovidVaccinations vac -- vac for shortcut name
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated


-- Creating view to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int))OVER(partition by dea.location order by dea.location, dea.date) as RollindPeopleVaccinated
From PortfolioProject..CovidDeaths dea -- dea for shortcut name
join PortfolioProject..CovidVaccinations vac -- vac for shortcut name
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated
