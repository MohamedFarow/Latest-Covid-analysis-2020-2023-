use PortfolioProject
select * from PortfolioProject..CovidDeaths$  where continent is not null order by 3, 4
--Select the data I am working
select location, date, total_cases,New_cases, total_deaths, population from PortfolioProject..CovidDeaths$ order by 1,2

-- Looking at total cases vs total deaths

select location, date, total_cases, total_deaths, 
(convert(float,total_deaths)/nullif (convert (float, total_cases),0)) * 100 as Deaths
  from PortfolioProject..CovidDeaths$ where location like '%States%'   order by 1,2
  -- shows the percantage of population got infected by covid


  select location, date, total_cases, total_deaths, 
(convert(float,total_deaths)/nullif (convert (float, total_cases),0)) * 100 as Deaths
  from PortfolioProject..CovidDeaths$ where location like '%States%'  order by 1,2


  select location, date, total_cases, population, (convert(float, total_cases) / nullif (convert(float, population),0)) * 100 
  as "No of  Population" from CovidDeaths$ where population like '%states%'  order by 1,2

  select location, date, population, total_cases , (total_cases / population) * 100 as No_Pop 
  from CovidDeaths$  where location = 'United States' order by 1,2

--Select location, date, total_cases,total_deaths, 
--(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
--from PortfolioProject..covidDeaths
--order by 1,2


--- Showing the highest infection rate

select location, population, max(total_cases) as HighestInfected , max(total_cases / population) * 100 as  percentpopulationinfected
from CovidDeaths$ group by location , population order by percentpopulationinfected desc

select location,population, date , max(total_cases) as HighestInfected, max(total_cases / population) * 100 as percentpopulationinfected
from CovidDeaths$ group by location,population,date order by percentpopulationinfected desc

-- Showing the highest death count per population

select location, 
--max(convert(int,total_cases)) as TotalDeathCount from CovidDeaths$
max(cast(total_deaths as int)) as TotalDeathCount from CovidDeaths$ 
where continent is not null
group by location
order by TotalDeathCount desc

-- Showing the highest death count per continent

select continent,
max(convert(int,total_cases)) as TotalCaseCount 
from CovidDeaths$
--max(cast(total_deaths as int)) as TotalDeathCount from CovidDeaths$ 
where continent is  null  
group by  continent
order by TotalCaseCount desc

select  location, 
max(convert(int,total_cases)) as TotalCaseCount 
from CovidDeaths$
--max(cast(total_deaths as int)) as TotalDeathCount from CovidDeaths$ 
where continent is  null 

group by  location
order by TotalCaseCount desc

select location, sum(cast(total_deaths as bigint)) as TotalDeathCount from CovidDeaths$
where continent is null and location  not in ('World','Europian Union')
group by location
order by TotalDeathCount desc

-- Showing Total Cases and Deaths in the Entire World
select  sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths,
nullif(sum(cast(new_deaths as bigint)),0)/nullif(sum(New_cases),0)* 100 as  DeathPercentage 
from CovidDeaths$
where continent is not null
--group by date
order by 1,2


select  sum(new_cases) as total_cases , nullif(sum(convert(int,new_deaths )),0) as total_deaths,  
nullif(sum(convert(int, new_deaths )),0)/sum(New_cases) * 100 as  DeathPercentage from CovidDeaths$
where continent is not null
--group by date
order by 1,2



--Joiniing 2 Tables
--Looking at total vaccination vs population and creating CTE
with popvsvac ( Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location ,dea.date) RollingPeopleVaccinated
from 
CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

select *, (RollingPeopleVaccinated / population) from popvsvac

--Temp Table
drop table if exists #PercentpopulationVaccinated
create table #PercentpopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
) 
insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint )) over (partition by dea.location order by dea.location ,dea.date) RollingPeopleVaccinated
from 
CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3
select *, (RollingPeopleVaccinated / population) from #PercentpopulationVaccinated

--Creating Views

create view PercentpopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint )) over (partition by dea.location order by dea.location ,dea.date) RollingPeopleVaccinated
from 
CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

--Querying View
select * from PercentpopulationVaccinated