select *
from PortfolioProject..[covid-data-death]
order by 3,4

--data that used
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..[covid-data-death]
order by 1,2

--total cases vs total death = % death rate
select location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathRate
from PortfolioProject..[covid-data-death]
where location like '%Indonesia'
order by 1,2

--total cases vs population = % population get covid
select location, date, total_deaths, population, (total_cases/population)*100 as PositiveCase
from PortfolioProject..[covid-data-death]
where location like '%Indonesia'
order by 1,2

--highest infection rate vs population
select location, population, max(total_cases) as HighestInfectionRate, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..[covid-data-death]
--where (location like '%Indonesia' and total_deaths is not null)
group by Location, population
order by PercentPopulationInfected desc

--highest death count continent
select continent, max(total_deaths) as total_deathcount
from PortfolioProject..[covid-data-death]
where continent is not null
group by continent
order by total_deathcount desc

--highest death count COUNTRY
select location, population, max(total_deaths) as total_deathcount
from PortfolioProject..[covid-data-death]
where continent is not null
group by Location, population
order by total_deathcount desc

--global numbers 
select  sum(new_cases)as globalNewCase, sum(new_deaths)as globalNewDeaths, case 
when sum(new_cases)=0
then NULL
else sum(new_deaths)/sum(new_cases)*100 end as GlobalDeathRate
from PortfolioProject..[covid-data-death]
where continent is not null
--group by date
order by 1,2
-------------------

select *
from PortfolioProject..[covid-data-death] dea
join PortfolioProject..[covid-data-vaccination] vac
on dea.location=vac.location
and dea.date = vac.date

with popvsvac(continent, location, date,population, new_vaccinations, peopleVaccinated)
as(
--total population vs vaccin
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
--,(PeopleVaccinated/dea.population)*100 as percentVaccinationPopulation
from PortfolioProject..[covid-data-death] dea
join PortfolioProject..[covid-data-vaccination] vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)

select *, (peopleVaccinated/population)*100 as percentpopulationvaccinated
from popvsvac

--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
--total population vs vaccin
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
--,(PeopleVaccinated/dea.population)*100 as percentVaccinationPopulation
from PortfolioProject..[covid-data-death] dea
join PortfolioProject..[covid-data-vaccination] vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

select * from #percentpopulationvaccinated


--create view to store data
create View percentpopulationvaccinated as 
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
--,(PeopleVaccinated/dea.population)*100 as percentVaccinationPopulation
from PortfolioProject..[covid-data-death] dea
join PortfolioProject..[covid-data-vaccination] vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

select * from percentpopulationvaccinated