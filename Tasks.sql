use PortfolioProject;

select * 
from CovidDeaths
where continent is not null
order by 3,4;

--select * 
--from CovidVaccinations
--order by 3,4;

--Selecting the data which is required

select location, date, total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by location, date

--Total cases vs total deaths
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percent
from CovidDeaths
where location like 'India' and continent is not null
order by location, date

--Total cases vs population
--find what % of population got covid
select location, date, population, (total_cases/population)*100 as population_percent
from CovidDeaths
where continent is not null
--where location like 'India'
order by location, date

--Countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as population_percent
from CovidDeaths
where continent is not null
group by location, population
order by population_percent desc

--Countries with highest death count per Population
select location, MAX(cast(total_deaths as int)) as total_deathCount
from CovidDeaths
where continent is not null
group by location
order by total_deathCount desc


-- now checking things with continent
--checking continents with highest death count per Population
select continent, MAX(cast(total_deaths as int)) as total_deathCount
from CovidDeaths
where continent is not null
group by continent
order by total_deathCount desc

--checking the global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as death_percent
from CovidDeaths
where continent is not null
group by date
order by 1,2

--Total cases with death percent
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as death_percent
from CovidDeaths
where continent is not null
order by 1,2

--Joining vaccination and death table
select *
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date

--checking total population vs vaccinations

select d.continent,d.location,d.date,d.population,v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,
	d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3

--using CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,
	d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--temporary table
DROP table if exists #PercentPopulationVaccinated
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
select d.continent,d.location,d.date,d.population,v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,
	d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
--where d.continent is not null

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

