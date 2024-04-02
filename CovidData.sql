
Select * from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select * from PortfolioProject..CovidVaccinations
--order by 3,4


Select location,date, total_cases,new_cases,total_deaths,population 
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract covid in your home country
Select location,date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at total cases vs population
-- Shows what percentage of population got covid
Select location,population, total_cases,(total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location,population
order by PercentPopulationInfected desc

--Breaking it down by continent
-- Showing continents with highest death counts
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing Countries with Highest Death Count per population
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc


-- Global Numbers
Select  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2

Select* 
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated,
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

--Use CTE
with PopvsVac (Continent, location,date,population,new_vaccinations,RollingPeopleVaccinated)
as (Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)

Select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp table
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view for visulization

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

Select * From PercentPopulationVaccinated