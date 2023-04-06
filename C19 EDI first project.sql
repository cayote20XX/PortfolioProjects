 Select * 
 From CovidDeaths
 Where continent is not null
 order by 3,4

 --Select *
 --From CovidVaccinations
 --order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
 Where continent is not null
Order by 1,2

-- Look into Total Cases vs Total Deaths - does new cases equal to deaths

Select location, date, total_cases, total_deaths, (total_deaths/(CAST(total_cases as int)*100 AS DeathPercentage
From CovidDeaths
Order by 1,2

--Likelihood of dying if you contract covid in Kenya
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where location like '%kenya%'
Order by 1,2

-- total cases vs Population
-- Shows percentage of population with covid
Select location, date, population,
total_cases, (total_cases/population)*100 as TotalCasesPercentage
From CovidDeaths
Where location like '%kenya%'
Order by 1,2

--which countries have the highest prevalance rate of COVID compared to population
Select location, population,MAX(total_cases) as HighestPrevalanceCount,
Max(
(total_cases/population)*100)as HighestPrevalanceRate
From CovidDeaths
--Where location like '%kenya%'
Group by location, population
Order by HighestPrevalanceRate desc

--show highest death rate per location
Select location, MAX(cast(total_deaths as bigint)) as HighestDeathCount
From CovidDeaths
--Where location like '%kenya%'
 Where continent is not null
Group by location
Order by HighestDeathCount desc


--Let's break it down by continent and Location

Select location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From CovidDeaths
--Where location like '%kenya%'
 Where continent is  null
Group by location
Order by TotalDeathCount desc


Select continent, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From CovidDeaths
--Where location like '%kenya%'
 Where continent is  not null
Group by continent
Order by TotalDeathCount desc

--More complex how far can i take the analysis
--come from a view point of visualization as the end goal
-- think thorugh with the end goal of it coming from tabluea when drilling down, having layers

Select  MAX(cast(Total_deaths as bigint)) as TotalDeathCount, population, continent
From CovidDeaths
--Where location like '%kenya%'
 Where continent is  not null
Group by population
Order by TotalDeathCount desc

--global numbers exploratory like from the beginning and see what can go up
--the GROUPING by above does not work because when grouping by will need a calculated field afterwards

Select date, 
SUM(new_cases) as TotalCases
, SUM (new_deaths)as TotalDeaths, 

 SUM(convert(int, new_deaths))/SUM (new_cases)*100
--total_cases, (total_cases/population)*100 as TotalCasesPercentage
From CovidDeaths
--Where location like '%kenya%'
where new_cases is not null
Group by date
Order by 1,2

--Total vaccination numbers from a global perspective

Select * 
From CovidVaccinations vac
Join CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
order by 3,4

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER  (Partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations,

From CovidVaccinations vac
Join CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is not null
order by 2,3

-- USE cte TO PUT it together
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingTotalVaccinations)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER  (Partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
From CovidVaccinations vac
Join CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingTotalVaccinations/Population) * 100
From PopvsVac

--Temp tables
--use the drop table function to catch errors when making errors such as adding back order by
Drop table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingTotalVaccinations numeric
 )

insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER  (Partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
From CovidVaccinations vac
Join CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingTotalVaccinations/Population) * 100
From #PercentPopulationVaccinated


--Creating view to store data for later visaulzaitons

Create View  PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER  (Partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
From CovidVaccinations vac
Join CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is not null
--order by 2,3


--this can be set aside to be done in  bi
Select*
From PercentPopulationVaccinated

--Next steps is to store and upload 