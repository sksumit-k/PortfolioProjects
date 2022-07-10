-- Data published by - COVID-19 Data Repository by the Center for Systems Science and Engineering (CSSE) at Johns Hopkins University

SELECT *
FROM [PortfolioProject(CompleteData)_1]..CovidDeaths   -- .. to get specific folder in portfolioproject(CompleteData)_1 which is coviddeaths
where continent is not null
order by 3,4 -- to make it like excel file

--SELECT *
--FROM [PortfolioProject(CompleteData)_1]..CovidVaccinations   -- .. to get specific folder in portfolioproject(CompleteData)_1 which is coviddeaths
--where continent is not null
--order by 3,4

-- Selecting data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject(CompleteData)_1]..CovidDeaths
where continent is not null 
order by 1,2 -- 2 for date order

-- looking at Total cases vs Total death

SELECT location, date, total_cases, total_deaths
FROM [PortfolioProject(CompleteData)_1]..CovidDeaths
where continent is not null 
order by 1,2

-- shows likelyhood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage  -- (total_deaths/total_cases)*100 for death percentage
FROM [PortfolioProject(CompleteData)_1]..CovidDeaths
where location like '%india%'  -- to get data of 'india'
and continent is not null 
order by 1,2

-- looking at Total cases vs population(shows what percentage of population got covid)  

SELECT location, date, population, total_cases, PercentagePopulationInfected = (total_cases/population)*100 -- (total_cases/population)*100 for cases percentage
FROM [PortfolioProject(CompleteData)_1]..CovidDeaths
where location like '%india%' 
and continent is not null 
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to the Population  

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM [PortfolioProject(CompleteData)_1]..CovidDeaths
where continent is not null
--and location like '%india%'
group by location,population
order by PercentagePopulationInfected Desc

-- Showing countries with heighest deathcount per population

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount -- have to convert total_deaths from varchar(250) to int because it's not showing complete number
FROM [PortfolioProject(CompleteData)_1]..CovidDeaths
where continent is not null  -- will remove all null naulues of continent (and will remove continents and shows only countries)
group by location
order by TotalDeathCount Desc

-- let's break things down by continent
-- showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount -- have to convert total_deaths from varchar(255) to int because it's not showing complete number
FROM [PortfolioProject(CompleteData)_1]..CovidDeaths
where continent is not null  -- will include null values as it's not taking any other country in north america except U.S.
group by continent
order by TotalDeathCount Desc

-- GLOBAL NUMBERS

-- global numbers(total cases globally, totaldeaths, and death percentage)

SELECT SUM(new_cases) as Global_Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM [PortfolioProject(CompleteData)_1]..CovidDeaths
-- where location like '%india%' 
where continent is not null 
-- Group by date
Order by 1,2

-- Let's explore covid vaccination table
-- Firstly joint both tables on location and date

select *
From [PortfolioProject(CompleteData)_1]..CovidDeaths dea -- dea for shortcut name
join [PortfolioProject(CompleteData)_1]..CovidVaccinations vac -- vac for shortcut name
	on dea.location = vac.location
	and dea.date = vac.date
	order by 3,4

-- Looking at Total_population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [PortfolioProject(CompleteData)_1]..CovidDeaths dea -- dea for shortcut name
join [PortfolioProject(CompleteData)_1]..CovidVaccinations vac -- vac for shortcut name
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- addition of 'new vaccinations' to a new column date by date but ends when country name ends
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint))OVER(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollindPeopleVaccinated/population)*100 --we can't use RollingPeopleVaccinated here like this we just created that column so we did it below, how it works( so, we have to create whether CTE(common table expression) or TEMP TABLE )
From [PortfolioProject(CompleteData)_1]..CovidDeaths dea -- dea for shortcut name
join [PortfolioProject(CompleteData)_1]..CovidVaccinations vac -- vac for shortcut name
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
 
 
 -- USE CTE
WITH PopvsVac(Continent,Location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint))OVER(partition by dea.location order by dea.location, dea.date) as RollindPeopleVaccinated
From [PortfolioProject(CompleteData)_1]..CovidDeaths dea -- dea for shortcut name
join [PortfolioProject(CompleteData)_1]..CovidVaccinations vac -- vac for shortcut name
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
SUM(CAST(vac.new_vaccinations as bigint))OVER(partition by dea.location order by dea.location, dea.date) as RollindPeopleVaccinated
From [PortfolioProject(CompleteData)_1]..CovidDeaths dea -- dea for shortcut name
join [PortfolioProject(CompleteData)_1]..CovidVaccinations vac -- vac for shortcut name
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated


-- Creating view to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint))OVER(partition by dea.location order by dea.location, dea.date) as RollindPeopleVaccinated
From [PortfolioProject(CompleteData)_1]..CovidDeaths dea -- dea for shortcut name
join [PortfolioProject(CompleteData)_1]..CovidVaccinations vac -- vac for shortcut name
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated