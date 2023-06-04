create database Portfolio

select *
from Portfolio ..CovidDeaths
order by 3,4;

--select *
--from Portfolio ..CovidVaccinations
--order by 3,4;

-- Select Data that we are going to be using
Select location ,date,total_cases,new_cases,total_deaths,population
from  Portfolio ..CovidDeaths
order by 1,2;


-- Looking at Total Cases vs Total Deaths
Select location ,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from  Portfolio ..CovidDeaths
where location like '%states%'
order by 1,2;

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you conttract covid in your country
Select location ,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from  Portfolio ..CovidDeaths
where location like '%kenya%'
order by 1,2;

-- looking at total cases vs population
-- shows what percentage of population got covid
Select location ,date,Population,total_cases,(total_cases/population)*100 as Pop_Perct_got_covid
from  Portfolio ..CovidDeaths
where location like '%kenya%'
order by 1,2;


-- looking at countries with Highest Infection Rate compared to population
Select location,population,max(total_cases) as HIGHEST_INFECTION_COUNT, MAX((total_cases/population))*100 as
Perc_Pop_Infected
from Portfolio ..CovidDeaths
-- where location like '%states%'
Group by location,population
order by Perc_Pop_Infected desc;

-- showinng countries with Highest Death Count Per Pop
Select location,Max(cast(Total_deaths as int))as TotalDeathCount
from Portfolio ..CovidDeaths
-- where location like '%states%'
where continent is not null
Group by location,population
order by TotalDeathCount desc;

-- breaking things down by continent
Select continent,Max(cast(Total_deaths as int))as TotalDeathCount
from Portfolio ..CovidDeaths
-- where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc;

-- showing continents with the highest death count per population
--  breaking things down by location
Select location,Max(cast(Total_deaths as int))as TotalDeathCount
from Portfolio ..CovidDeaths
-- where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc;

-- GLOBAL  NUMBERS
Select date ,sum(new_cases) as total_Cases,sum(cast(new_deaths as int)) as Total_Deaths,(sum(cast(new_deaths as int))/sum
(new_cases))*100 as GLob_DeathPercentage
from Portfolio..CovidDeaths
-- where location like %states%
where continent is not null
group by date
order by 1,2;

Select sum(new_cases) as total_Cases,sum(cast(new_deaths as int)) as Total_Deaths,(sum(cast(new_deaths as int))/sum
(new_cases))*100 as GLob_DeathPercentage
from Portfolio..CovidDeaths
-- where location like %states%
where continent is not null
order by 1,2;
-- looking at total population vs vaccinations


--using cte
with popvsvac (Contnent,location,Date,Population,New_vaccinations,RollingPeople_VAC)
as(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations))OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeople_VAC
From Portfolio..CovidDeaths dea
join portfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeople_VAC/Population)*100
from popvsvac 

-- temp table
drop table if exists #PercentpopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccations numeric,
RollingPeople_VAC numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations))OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeople_VAC
From Portfolio..CovidDeaths dea
join portfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *,(RollingPeople_VAC/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later Visualization
drop view PercentPopulationVaccinated
Create View
PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.location,
dea.Date)as RollingPeople_VAC
--,(RollingPeople_VAC/Population)*100
from Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated