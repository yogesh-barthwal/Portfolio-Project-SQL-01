--Selectiong the required data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths;

-- Calculating total deaths vs total cases
--It shows the likelihood of dying if one gets infected by Covid in India

SELECT location, date, total_deaths, total_cases, total_deaths * 1.0/total_cases *100 death_percentage
FROM covid_deaths

-- Calculating Total Cases vs Population
-- Showing what percentage of population got infected
SELECT location, date, population,total_deaths, total_cases, total_cases * 1.0/population *100 contracting_percentage
FROM covid_deaths
WHERE location ilike '%india'
ORDER BY 6 DESC;

--Showing maximum infected countries
SELECT location, population,MAX(total_cases) max_total_cases,MAX(total_cases * 1.0/population) *100 infection_percentage
FROM covid_deaths
WHERE population IS NOT NULL and total_cases IS NOT NULL
GROUP BY location, population	
ORDER BY infection_percentage DESC

--Showing Highest Death count per population
SELECT location, population,MAX(total_deaths) max_total_deaths,
MAX(total_deaths * 1.0/population) *100 death_percentage_population,

FROM covid_deaths
WHERE population IS NOT NULL and total_cases IS NOT NULL
GROUP BY location, population	
ORDER BY death_percentage_population DESC


SELECT location,MAX (total_deaths) max_total_deaths 
 FROM covid_deaths
 WHERE total_deaths IS NOT NULL and continent IS NOT NULL
 GROUP BY location
 ORDER BY max_total_deaths DESC
 
-- Showing By Continent
SELECT continent, MAX(total_deaths) max_total_deaths_continent
FROM covid_deaths
GROUP BY continent
ORDER BY max_total_deaths_continent DESC


SELECT location,MAX (total_deaths) max_total_deaths 
 FROM covid_deaths
 WHERE total_deaths IS NOT NULL and continent IS NULL
 GROUP BY location
 ORDER BY max_total_deaths DESC

--Percentage of total deaths vs total cases
SELECT date, SUM(new_cases) new_cases_total,
 SUM(new_deaths) new_deaths_total,
 SUM(new_deaths)*1.0/NULLIF(SUM(new_cases),0)*100 new_deaths_percentage
 FROM covid_deaths
 WHERE continent is NOT NULL
 GROUP BY date
 ORDER BY 1,2
 -- Total reported cases an deaths
 SELECT  SUM(new_cases) new_cases_total,
 SUM(new_deaths) new_deaths_total,
 SUM(new_deaths)*1.0/NULLIF(SUM(new_cases),0)*100 new_deaths_percentage
 FROM covid_deaths
 WHERE continent is NOT NULL
 --GROUP BY date
 ORDER BY 1,2



SELECT dea.location, dea.date, SUM(vacc.new_tests) total_new_tests
FROM covid_deaths dea
JOIN covid_vaccinations vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is NOT NULL and vacc.new_tests IS NOT NULL
GROUP BY dea.location, dea.date
ORDER BY total_new_tests DESC

SELECT dea.continent,dea.location, dea.date, dea.population,vacc.new_vaccinations,SUM(vacc.new_vaccinations)
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) total_new_vaccinations 
FROM covid_deaths dea
JOIN covid_vaccinations vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is NOT NULL and vacc.new_vaccinations IS NOT NULL

-- Using CTE for calculating Population vs Vaccinations
WITH pop_vs_vacc(continent, location,date,population,new_vaccinations,total_new_vaccinations)

AS
(
SELECT dea.continent,dea.location, dea.date, dea.population,vacc.new_vaccinations,SUM(vacc.new_vaccinations)
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) total_new_vaccinations 
FROM covid_deaths dea
JOIN covid_vaccinations vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is NOT NULL and vacc.new_vaccinations IS NOT NULL and dea.location='India'
)
SELECT *, (total_new_vaccinations*1.0/population)*100 percentage_vaccinations 
FROM pop_vs_vacc
ORDER BY continent,location,percentage_vaccinations

--Vaccinations vs Population using temp table
DROP TABLE IF EXISTS pop_vs_vacc;
CREATE TEMPORARY TABLE pop_vs_vacc
(
	continent VARCHAR(100),
	location VARCHAR(100),
	date TIMESTAMP,
	population NUMERIC,
	new_vaccinations INTEGER,
	total_rolling_vaccinations INTEGER
);
INSERT INTO pop_vs_vacc
SELECT dea.continent,dea.location, dea.date, dea.population,vacc.new_vaccinations,SUM(vacc.new_vaccinations)
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) total_new_vaccinations 
FROM covid_deaths dea
JOIN covid_vaccinations vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is NOT NULL and vacc.new_vaccinations IS NOT NULL;

SELECT *, (total_rolling_vaccinations*1.0/population) percent_population_vaccinated
FROM pop_vs_vacc


CREATE VIEW population_vaccinated
AS
SELECT dea.continent,dea.location, dea.date, dea.population,vacc.new_vaccinations,SUM(vacc.new_vaccinations)
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) total_new_vaccinations 
FROM covid_deaths dea
JOIN covid_vaccinations vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is NOT NULL and vacc.new_vaccinations IS NOT NULL

