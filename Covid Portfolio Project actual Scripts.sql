Select *
From PortfolioProject..['Covid Deaths$']
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..['Covid Vaccinations$']
--order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['Covid Deaths$']
order by 1,2

---Total cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
where location like '%Nigeria%'
where continent is not null
order by 1,2

--Total Cases vs Population
--Percentage of population that got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
where location like '%states%'
where continent is not null
order by 1,2

--Countries with Highest Infection Rate vs Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['Covid Deaths$']
--where location like '%states%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

---Countries with Highest Death Count vs Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

---FIlter by Location
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
--where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc



---FIlter by Continent
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


---Continent with the Highest Death count vs Population
 Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLobal Numbers

Select date, SUM (new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

--OR

Select SUM (new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2


---Total Population vs Vaccination
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingpeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
---order by 2,3
)
select *, (RollingpeopleVaccinated/Population)*100
From PopvsVac


--TEMP Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
---order by 2,3

select *, (RollingpeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

 
---Creating View to Store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3