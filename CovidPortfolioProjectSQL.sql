Select *
From PortfolioProjectCovid..CovidDeaths
Order by 3,4



Select *
From PortfolioProjectCovid..CovidVaccinations
Order by 3,4

-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCovid..CovidDeaths
Order by 1,2

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float))*100 AS death_percentage
From PortfolioProjectCovid..CovidDeaths
--where location like '%states%'
Order by 1,2

---Looking at total cases vs population
--shows what % of population got Covid
Select location, date, population, total_cases, (CAST(total_cases as float)/CAST(population as float))*100 AS infected_pop_percentage
From PortfolioProjectCovid..CovidDeaths
where location like '%states%'
Order by 1,2

--Looking at countires with highest infection rate compared to population
Select location, population, MAX(CAST(total_cases as float)) AS highest_infection_count, MAX((CAST(total_cases as float)/CAST(population as float)))*100 AS infected_pop_percentage
From PortfolioProjectCovid..CovidDeaths
--where location like '%states%'
Group by location, population
Order by infected_pop_percentage desc


--Looking at countires with highest death count compared to population
Select location, MAX(CAST(total_deaths as float)) AS total_death_count
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by location, population
Order by total_death_count desc


Select *
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
order by 3,4


--Looking at continents with highest death counts
Select continent, MAX(CAST(total_deaths as float)) AS total_death_count
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by continent
Order by total_death_count desc

--Looking at global numbers
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as death_percentage
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Looking at total population vs vaccinations

--Use CTE

With pop_vs_vacc (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(Cast(Vac.new_vaccinations as float)) OVER (Partition by Dea.location Order by Dea.location, 
Dea.Date) as rolling_vaccinations
From PortfolioProjectCovid..CovidDeaths Dea
Join PortfolioProjectCovid..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null
--Order by 2,3
)
Select *, (rolling_vaccinations/population)*100
From pop_vs_vacc

--Use Temp Table
 
 Drop Table if exists #PercentPopulationVacc
 Create Table #PercentPopulationVacc
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 new_vaccinations numeric,
 rolling_vaccinations numeric
 )

 Insert into #PercentPopulationVacc
 Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(Cast(Vac.new_vaccinations as float)) OVER (Partition by Dea.location Order by Dea.location, 
Dea.Date) as rolling_vaccinations
From PortfolioProjectCovid..CovidDeaths Dea
Join PortfolioProjectCovid..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null
--Order by 2,3

Select *, (rolling_vaccinations/population)*100
From #PercentPopulationVacc


--Creating View to store data for visualizations

Create View PercentPopulationVacc as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(Cast(Vac.new_vaccinations as float)) OVER (Partition by Dea.location Order by Dea.location, 
Dea.Date) as rolling_vaccinations
From PortfolioProjectCovid..CovidDeaths Dea
Join PortfolioProjectCovid..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null
--Order by 2,3


Select * 
From PercentPopulationVacc