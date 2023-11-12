use ProjectPortfolio

select *
from ['covid deaths$']
order by 3,4


--select * from [covidvaccinations$]
--order by 3,4



select location,date,total_cases,new_cases,total_deaths,population
from ['covid deaths$']
order by 1,2


--Total Death Percentage

select location,date,total_cases,total_deaths,(convert(float,total_deaths)/total_cases)*100 as DeathPercent
from ['covid deaths$']
order by 1,2

--Total Cases Vs Population

select location,date,population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from ['covid deaths$']
where location like '%India%'
order by 1,2


---Countries with Highest Infection rate compared to Population

select location,
population,
max(total_cases) as HighestInfectionCount ,
max((total_cases/population))*100 as PercentPopulationInfected
from ['covid deaths$']
group by location,population
order by PercentPopulationInfected desc

---Countries with Highest death count per Population

select location,
max(cast(total_deaths as int)) as TotalDeathCount
from ['covid deaths$']
where continent is not null
group by location
order by TotalDeathCount desc


----Continents with Highest death count per Population

select continent,
max(cast(total_deaths as int)) as TotalDeathCount
from ['covid deaths$']
where continent is not null
group by continent
order by TotalDeathCount desc

---Global Numbers

select date, 
sum(new_cases) as total_cases, 
sum(cast (new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage
from ['covid deaths$']
where continent is not null
group by date
order by 1,2

---- Global Numbers of cases & death
select 
sum(new_cases) as total_cases, 
sum(cast (new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage
from ['covid deaths$']
where continent is not null
order by 1,2


--- Total Population Vs Vaccination(Global)


select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
from ['covid deaths$'] dea
join CovidVaccinations$ vac
on vac.location = dea.location
and vac.date =dea.date
where dea.continent is not null
----and dea.location like '%India%'
order by 2,3

--- Total Population Vs Vaccination(Locally)


select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
from ['covid deaths$'] dea
join CovidVaccinations$ vac
on vac.location = dea.location
and vac.date =dea.date
where dea.continent is not null
and dea.location like '%India%'
order by 2,3

---- Rolling Count of People Vaccinated


select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ['covid deaths$'] dea
join CovidVaccinations$ vac
on vac.location = dea.location
and vac.date =dea.date
where dea.continent is not null
order by 2,3


---- Total Population Vs Vaccinated Percentage


with cte 
as 
(select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ['covid deaths$'] dea
join CovidVaccinations$ vac
on vac.location = dea.location
and vac.date =dea.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/population) * 100 
from cte


--- Ranking the covid cases

select dea.continent,dea.location, dea.population, dea.new_cases,
dense_rank() over(partition by dea.location order by dea.new_cases desc) as topmostcovidcases
from ['covid deaths$'] dea
join CovidVaccinations$ vac
on vac.location = dea.location
and vac.date =dea.date
where dea.continent is not null
order by topmostcovidcases 


----Avg No of Deaths by day (Continets & Countries)

select location,continent,
avg(new_deaths) as AvgDeath
from ['covid deaths$']
where continent is not null
group by location,continent
order by AvgDeath desc


---- Average of cases divided by the number of population of each country

select*,
ROW_NUMBER() over(order by percentage_population desc) as rn
from
(
select continent,location,
round(avg((total_cases/population)*100),2) as Percentage_population
from ['covid deaths$']
where continent is not null
group by continent,location
)x


---- Number of new vaccinated and rolling average of new vaccinated over time by country on the Asia continent

select dea.continent,dea.location, dea.date, dea.population, dea.new_cases, vac.new_vaccinations,
avg(convert(float,new_vaccinations)) over(partition by dea.location order by dea.date) as Rolling_Avg_Vaccines
from ['covid deaths$'] dea
join CovidVaccinations$ vac
on vac.location = dea.location
and vac.date =dea.date
where dea.continent is not null
and dea.continent = 'Asia'
order by 2,3



----TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ['covid deaths$'] dea
join CovidVaccinations$ vac
on vac.location = dea.location
and vac.date =dea.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population) * 100 
from #PercentPopulationVaccinated

---Creating  View
create view PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ['covid deaths$'] dea
join CovidVaccinations$ vac
on vac.location = dea.location
and vac.date =dea.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated
























































