-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International','Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


--5. Vaccinatedpopulation in India

create view vaccinated_population_india as

Select dea.continent, dea.location, dea.population, MAX(cast(vac.people_vaccinated as bigint)) as total_population_vaccinated,
MAX(cast(vac.people_fully_vaccinated as bigint)) as fully_vaccinated_population
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
where dea.location like '%India'
group by dea.continent, dea.location, dea.population

Select continent, location, population,( total_population_vaccinated/population)*100 as percentage_population_vaccinated,
( fully_vaccinated_population/population)*100 as percentage_population_fully_vaccinated
from vaccinated_population_india

--6. Vaccinated Population in India and its Neighbours

create view vaccinated_population_indian_neighbours as

Select dea.continent, dea.location, dea.population, MAX(cast(vac.people_vaccinated as bigint)) as total_population_vaccinated
--MAX(cast(vac.people_fully_vaccinated as bigint)) as fully_vaccinated_population
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
where dea.location In ('India','China','Nepal','Bhutan','Bangladesh','Sri Lanka','Pakistan') 
group by dea.continent, dea.location, dea.population

Select continent, location, population,( total_population_vaccinated/population)*100 as percentage_population_vaccinated
--( fully_vaccinated_population/population)*100 as percentage_population_fully_vaccinated
from vaccinated_population_indian_neighbours