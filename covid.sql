 select data that we are going to using

select location,date, total_cases, new_cases, total_deaths from covidDeaths
order by 1,2

 looking at total cases vs total deaths
 shows the percent of dying if you are infected

SELECT location,
       date,
       total_cases,
       total_deaths,
       CASE 
           WHEN total_cases > 0 THEN (total_deaths / total_cases) * 100
           ELSE 0 
       END AS DeathPercentage
FROM covidDeaths 
WHERE location LIKE '%state%'
ORDER BY location, date;

looking at total_cases vs poulation
SELECT location,
       date,
       total_cases,
       population,
       CASE 
           WHEN population > 0 THEN (total_cases * 100) /population
           ELSE 0 
       END AS InfectedPercentage
FROM covidDeaths 
WHERE location ='United States'
ORDER BY location, date;

 highest countries with infection rate vs poulation

select location, population, MAX(total_cases) as HighestInfectionCount
, Max((total_cases * 100) /population) as maxRate 
from covidDeaths 
where location  not in ('World','High-income countries',
'Asia',
'Europe',
'Upper-middle-income countries',
'European Union (27)',
'North America','Lower-middle-income countries','Oceania',
'South America')
group by location, population
order by maxRate desc


 percentage of people died accroding to polulation

select location, population, max(total_deaths) as TotalDeaths, max((total_deaths*100)/population) as maxRate
from covidDeaths
where continent is not null
group by location, population
order by TotalDeaths desc

lets break this rate by contienent

select location, max(total_deaths) as TotalDeaths
from covidDeaths
where continent is  null
group by location
order by TotalDeaths desc

 global numbers

select date, sum(new_cases) as 'new cases', sum(new_deaths) as 'new deaths', 
(case 
when sum(new_cases)>0 then sum(new_deaths)/sum(new_cases)*100
else 0
end) as 'death perce'
from covidDeaths
where continent is not null
group by date
order by 1,2


 total population vs vaccination
 you must use cte to be able to add the new column  name

with PopvsVac(continet, location, date, population,new_people_vaccinated_smoothed, vac_increase)
as
(

select d.continent,d.location ,d.date,d.population, v.new_people_vaccinated_smoothed,
sum(convert(float, v.new_people_vaccinated_smoothed)) 
over (partition by v.location order by d.location,d.date) as vac_increase
(vac_increase/population)*100 as percentagee
from covidDeaths as d
join covidVaccination as v
on d.location = v.location and 
	d.date = v.date
	where d.continent is not null
order by 2,3
)
select *,(vac_increase/population)*100 as percentagee from PopvsVac

temp table
drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(continet nvarchar(255),
location nvarchar(255),
date DateTime,
population numeric,
new_people_vaccinated_smoothed numeric, 
vac_increase numeric)

insert into #PercentagePopulationVaccinated
select d.continent,d.location ,d.date,d.population, v.new_people_vaccinated_smoothed,
sum(convert(float, v.new_people_vaccinated_smoothed)) 
over (partition by v.location order by d.location,d.date) as vac_increase
(vac_increase/population)*100 as percentagee
from covidDeaths as d
join covidVaccination as v
on d.location = v.location and 
	d.date = v.date
	where d.continent is not null
order by 2,3
select *,(vac_increase/population)*100 as percentagee from #PercentagePopulationVaccinated

 Views
create view PercentagePopulationVaccinated
as
select d.continent,d.location ,d.date,d.population, v.new_people_vaccinated_smoothed,
sum(convert(float, v.new_people_vaccinated_smoothed)) 
over (partition by v.location order by d.location,d.date) as vac_increase
(vac_increase/population)*100 as percentagee
from covidDeaths as d
join covidVaccination as v
on d.location = v.location and 
	d.date = v.date
	where d.continent is not null

select distinct(continent) from PercentagePopulationVaccinated