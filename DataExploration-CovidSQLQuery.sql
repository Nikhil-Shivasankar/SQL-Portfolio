-- Covid 19
-- Data Exploration


Select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations$
--where continent is not null
--order by 3,4

-- Selecting the Data used in the project

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Death by covid in India

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths$
where location like 'India' and continent is not null
order by 1,2

-- Total Cases vs Population
-- Percentage of population of India that got infected by Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where location like 'India' and continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_deaths) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
Group by Location
order by TotalDeathCount desc 

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,Sum(cast(new_deaths as int))/Sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Total Population vs Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine
--cast and convert can be used similarly

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- order by is used in partition to give rolling count else itll show full count for same location again and again
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- We cant use the column we created to create say a percentage of rolling people vaccinated 
--Hence the need to create a ste or a temp table


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac(continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- order by is used in partition to give rolling count else itll show full count for same location again and again
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
-- order by cant be used in cte
)

Select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- order by is used in partition to give rolling count else itll show full count for same location again and again
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date,dea.population,
vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- order by is used in partition to give rolling count else itll show full count for same location again and again
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated

































