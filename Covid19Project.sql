

Select * from PortfolioProject..CovidDeaths
where continent is not null -- we make continent as not nuul bcz in our data wherever continent is null, the location column is continent name and we need only countries
order by 3,4;

Select *from PortfolioProject..CovidVaccinations
order by 3,4;

---Selecting data from CovidDeaths table for use

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

----Total cases vs total Deaths
-- Shows the liklihood of dying if you are infected with Covid-19 in your country.

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS death_percentage
from PortfolioProject..CovidDeaths
where location like '%India'

--- Total Cases vs Population
-- Percentage of infected population in a particular country by date
Select location, date, total_cases, population, (total_cases/population) *100 as infected_population_percentage
from PortfolioProject..CovidDeaths
where location like '%India'
order by 1,2

--- Countries with highest infection rates

Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population) *100) as infected_population_percentage
from PortfolioProject..CovidDeaths
group by location, population
order by infected_population_percentage desc

--- Countries with highest death count per population
-- needto cast the total_deaths data as it is varchar and MAX cannot be applied on it correctly

Select location, MAX(cast(total_deaths as int))as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by total_death_count desc

--- Death rate per country

Select location, MAX(total_cases) as cases,MAX(CONVERT(int,total_deaths)) as deaths, (MAX(CONVERT(int,total_deaths))/MAX(total_cases))*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by death_percentage desc

---Death rate per continent

Select continent, MAX(total_cases) as cases,MAX(CONVERT(int,total_deaths)) as deaths, (MAX(CONVERT(int,total_deaths))/MAX(total_cases))*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by death_percentage desc

--- checking the total number of deaths per continent
--- continents with highest death count

Select continent, MAX(cast(total_deaths as int))as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by total_death_count desc


--Global Numbers

Select continent, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from  PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by death_percentage

--- Total cases till date 18th January 2022

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from  PortfolioProject..CovidDeaths
where continent is not null


-----Total Polulation vs total vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as
rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
order by 2,3 


--- USE CTE(Common Table Expressions) to find the percent of total vaccinated people from the total population of each country
WITH PopVsVac (continent, location,date, population, new_vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as
rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
--order by 2,3 
)
Select * , (rolling_people_vaccinated / population) * 100 as percent_vaccinated
from PopVsVac

---Using TEMP table

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric

)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as
rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
--order by 2,3 

Select * , (rolling_people_vaccinated / population) * 100 as percent_vaccinated
from #PercentPopulationVaccinated


-- Creating views for visualizations

Create view PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as
rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
--order by 2,3 

Select * from PopulationVaccinated



--- total population vaccinated in USA

Create view PopulationVaccinatedUS as
Select dea.continent, dea.location, dea.population, MAX(cast(vac.people_vaccinated as bigint)) as total_population_vaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
where dea.location like '%States%' 
group by dea.continent, dea.location, dea.population


Select continent, location, population,( total_population_vaccinated/population)*100 as percent_population_vaccinated
from PopulationVaccinatedUS

----- Creating view for vaccinated population in india

create view vaccinated_population_india as

Select dea.continent, dea.location, dea.population, MAX(cast(vac.people_vaccinated as bigint)) as total_population_vaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
where dea.location like '%India' 
group by dea.continent, dea.location, dea.population

Select continent, location, population,( total_population_vaccinated/population)*100 as percentage_population_vaccinated
from vaccinated_population_india

---Creating view for fully vaccinated population in india
create view fully_vaccinated_population_india as
Select dea.continent, dea.location, dea.population, MAX(cast(vac.people_fully_vaccinated as bigint)) as fully_vaccinated_population
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
where dea.location like '%India' 
group by dea.continent, dea.location, dea.population

Select continent, location, population,( fully_vaccinated_population/population)*100 as percentage_population_vaccinated
from fully_vaccinated_population_india

