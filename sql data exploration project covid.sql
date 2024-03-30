#successfully imported data
select *
from sqlproject1.coviddeaths;

select new_vaccinations
from sqlproject1.covidvaccinations;

select location, date, total_cases, new_cases, total_deaths, population
from sqlproject1.coviddeaths
order by 1,2;

#looking at total cases vs total deaths

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from sqlproject1.coviddeaths
order by 1,2;

#looking at total cases vs total deaths region wise
#shows the likelyhood of dieing if get covid in your country

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from sqlproject1.coviddeaths
where location like '%india%'
order by 1,2;

# looking in Total cases vs population
#shows what percentation of population gets covid
select location, date, total_cases, population,(total_cases/population)*100 as population_cases_percentage
from sqlproject1.coviddeaths
order by 1,2;

#looking at total cases vs population region wise
#shows what percentation of population gets covid region wise

select location, date, total_cases, population,(total_cases/population)*100 as population_cases_percentage
from sqlproject1.coviddeaths
where location like '%india%'
order by 1,2;


#countries  with highest infection rate as compared to population
select location, max(total_cases) as highestinfection, population, max((total_cases/population)*100) as population_cases_percentage
from sqlproject1.coviddeaths
#where location like '%india%'
group by location,population
order by population_cases_percentage desc;


#countries with highest death count per population



Select Location, MAX(cast(Total_deaths as signed)) as TotalDeathCount
From sqlproject1.coviddeaths
#Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;

# break things by continent



#showing continent of the highest death count

Select continent, MAX(cast(Total_deaths as signed)) as TotalDeathCount
From sqlproject1.coviddeaths
#Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;


# global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(New_Cases)*100 as DeathPercentage
From sqlproject1.CovidDeaths
#--Where location like '%states%'
where continent is not null 
#--Group By date
order by 1,2;

#total population vs vaccination

select d.continent, d.location,d.date,d.population,f.new_vaccinations
from sqlproject1.coviddeaths as d
join sqlproject1.covidvaccinations as f
	on d.location=f.location and
    d.date=f.date
where d.continent is not null
order by 2,3 asc;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From sqlproject1.CovidDeaths dea
Join sqlproject1.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From sqlproject1.CovidDeaths as dea
Join sqlproject1.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

