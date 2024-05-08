--Looking at all parameters from the world covid deaths
SELECT *
FROM [COVID ANALYSIS].dbo.['World Covid Deaths]
ORDER BY 3,4

--Looking at all parameters from the world covid vaccination
SELECT *
FROM [COVID ANALYSIS].dbo.['World Covid Vaccination]
ORDER BY 3,4

--Looking at selected parameters from the world covid deaths
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [COVID ANALYSIS].dbo.['World Covid Deaths]
ORDER BY 1,2

--looking at the death percentage of Nigeria, this equally shows the likelyhood of a human to die from contracting the virus in Nigeria
SELECT location, date, population, cast(total_cases as float) TC_cast, cast(total_deaths as float) TD_cast, (cast(total_deaths as float))/(cast(total_cases as float))*100 DeathPercentage
FROM [COVID ANALYSIS].dbo.['World Covid Deaths]
WHERE location like '%Nigeria%'
ORDER BY 1,2

--looking at the infection percentage in the Nigerian Population,  ie, the percentage of Nigerians who got infected by the virus.
SELECT location, date, population, cast(total_cases as float) TC_cast, (cast(total_cases as float)/(population))*100 InfectedPercentage
FROM [COVID ANALYSIS].dbo.['World Covid Deaths]
WHERE location like '%Nigeria%'
ORDER BY 1,2

--looking at ALL countries based on their infection rate, from highest rate to lowest. This is each countries infection rate per its own population.
SELECT location, population, max(cast(total_cases as float)) TC_cast, max(cast(total_cases as float)/(population))*100 InfectedPercentage
FROM [COVID ANALYSIS].dbo.['World Covid Deaths]
--WHERE location like '%Nigeria%'
group by location, population
ORDER BY 4 desc

--looking at All countries based on their death COUNT from the infection, from highest to lowest.
SELECT location, population, max(cast(total_deaths as float)) TD_cast
FROM [COVID ANALYSIS].dbo.['World Covid Deaths]
where continent is not null
group by location, population
ORDER BY 3 desc

--looking at All countries based on their death rate from the infection, from highest rate to lowest. This is each countries death rate per its own population.
SELECT location, population, max(cast(total_deaths as float)) TD_cast, max(cast(total_deaths as float)/(population))*100 DeathPercentage
FROM [COVID ANALYSIS].dbo.['World Covid Deaths]
where continent is not null
group by location, population
ORDER BY 4 desc

--looking at the death count of the countries grouped into their respective continents.
select continent, max(cast(total_deaths as float)) TD_cast
FROM [COVID ANALYSIS].dbo.['World Covid Deaths]
where continent is not null
group by continent
order by 1

--looking at the continents themselves listed as locations in the explored dataset, this also includes the income level of the world with their respective death count.
select location, max(cast(total_deaths as float)) TD_cast
FROM [COVID ANALYSIS].dbo.['World Covid Deaths]
where continent is null
group by location
order by 1

--CONTINENTAL NUMBERS

--looking at the infection rate of the continents
SELECT location, population, max(cast(total_cases as float)) TC_cast, max(cast(total_cases as float)/(population))*100 InfectedPercentage
FROM [COVID ANALYSIS].dbo.['World Covid Deaths]
WHERE continent is null
group by location, population
ORDER BY 4 desc

--looking at the death rate of the continents from the infection
SELECT location, population, max(cast(total_deaths as float)) TD_cast, max(cast(total_deaths as float)/(population))*100 DeathPercentage
FROM [COVID ANALYSIS].dbo.['World Covid Deaths]
WHERE continent is null
group by location, population
ORDER BY 4 desc

--looking at the death rate of the infected patients
SELECT location, population,  max(cast(total_cases as float)) TC_cast, max(cast(total_deaths as float)) TD_cast, max(cast(total_deaths as float))/ max(cast(total_cases as float))*100 DeathPercentage
FROM [COVID ANALYSIS].dbo.['World Covid Deaths]
WHERE continent is null
group by location, population
ORDER BY 5 desc


--Looking at the vaccinations table in relation to the deaths table

--All Parameters

Select *
from [COVID ANALYSIS].dbo.['World Covid Deaths] Deaths
	join [COVID ANALYSIS].dbo.['World Covid Vaccination] Vacs
	on Deaths.location = Vacs.location
	and Deaths.date = Vacs.date 
order by 3,4

--Selected Parameters

select Vacs.continent, Vacs.location, vacs.date, deaths.population, vacs.new_vaccinations
from [COVID ANALYSIS].dbo.['World Covid Deaths] Deaths
	join [COVID ANALYSIS].dbo.['World Covid Vaccination] Vacs
	on Deaths.location = Vacs.location
	and Deaths.date = Vacs.date
	where vacs.continent is not null
order by 2,3

--looking at the total vaccination for each country on a daily basis; with the previous day total carried over to the next day and so on.
select Vacs.continent, Vacs.location, vacs.date, deaths.population, vacs.new_vaccinations, 
sum(cast(vacs.new_vaccinations as float)) over (partition by vacs.location order by vacs.date) RollingVaccinations
from [COVID ANALYSIS].dbo.['World Covid Deaths] Deaths
	join [COVID ANALYSIS].dbo.['World Covid Vaccination] Vacs
	on Deaths.location = Vacs.location
	and Deaths.date = Vacs.date
	where vacs.continent is not null
order by 2,3

 --looking at the vaccination percentage of the above query on a daily basis.

WITH Population_Vs_Vaccination (Continent, Location, Date, Population, Vaccinations, RollingVaccinations)
as
(
select Vacs.continent, Vacs.location, vacs.date, deaths.population, vacs.new_vaccinations, 
sum(cast(vacs.new_vaccinations as float)) over (partition by vacs.location order by vacs.date) RollingVaccinations
from [COVID ANALYSIS].dbo.['World Covid Deaths] Deaths
	join [COVID ANALYSIS].dbo.['World Covid Vaccination] Vacs
	on Deaths.location = Vacs.location
	and Deaths.date = Vacs.date
	where vacs.continent is not null
)
select*, (RollingVaccinations/Population)*100 Vaccinations_percent
from Population_Vs_Vaccination

--looking at the countries with highest vaccination percentage.

select Vacs.location, deaths.population, sum(cast(vacs.new_vaccinations as float)) Total_vaccinations,
(sum(cast(vacs.new_vaccinations as float))/population)*100 Vaccination_percentage
from [COVID ANALYSIS].dbo.['World Covid Deaths] Deaths
	join [COVID ANALYSIS].dbo.['World Covid Vaccination] Vacs
	on Deaths.location = Vacs.location
	and Deaths.date = Vacs.date
	where vacs.continent is not null
	group by Vacs.location, deaths.population
order by 4 desc