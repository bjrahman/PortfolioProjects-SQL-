select * 
from PortfolioProject..CovidDeaths 
order by 3,4

--select * from PortfolioProject..CovidVaccination
--order by 3,4

--SELECTING THE DATA THAT WE ARE GOING TO USE

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- TOTAL DEATHS VS TOTAL CASES 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--TOTAL CASES VS POPULATION
--Showing infection rate of different locations

select location, date, population, total_cases, (total_cases/population)* 100 as InfectionRate
from PortfolioProject..CovidDeaths 
where continent is not null
order by 1,2

--HIGHEST INFECTION RATE BY CONTINENT

select continent, max (total_cases) as HighestinfectionCount, max((total_cases/population))* 100 as InfectionRate
from PortfolioProject..CovidDeaths 
where continent is not null
Group by continent
order by InfectionRate DESC


--HIGHEST DEATH COUNT BY CONTINENT
--showing continents with the highest death count
select continent,  max (cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..CovidDeaths
where continent is not null and location not like '%income%'
group by continent
order by TotalDeathCounts DESC

--GLOBAL NUMBERS

select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and location not like '%income%'
Group By date
order by 1,2

--TOTAL GLOBAL CASES VS TOTAL GLOBAL DEATHS

select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and location not like '%income%'
order by 1,2


--TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinatedPeople
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
		on dea.location =vac.location 
		and dea.date = vac.date
where dea.continent is not null 
order by 2,3 

--USE CTE
--TOTAL POPULATION VS VACCINATIONS
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaccinatedPeople)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinatedPeople
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
		on dea.location =vac.location 
		and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 
)
Select *, (RollingVaccinatedPeople/population) * 100
from PopvsVac

--USE TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated (
	Continent nvarchar (255),
	Location nvarchar (255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingVaccinatedPeople numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinatedPeople, (RollingVaccinatedPeople/population) *100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
		on dea.location =vac.location 
		and dea.date = vac.date
where dea.continent is not null 
order by 2,3 

Select *, (RollingVaccinatedPeople/population) * 100
from #PercentPopulationVaccinated

--Creating Views to store Data for Visualizations
GO

Create View PercentVaccinatedPopulatonn as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinatedPeople
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
		on dea.location =vac.location 
		and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 

select *
from PercentVaccinatedPopulatonn