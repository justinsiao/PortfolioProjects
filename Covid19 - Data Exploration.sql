SELECT *
FROM covid_deaths
ORDER BY 3,4;

-- Selecting data to start with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1,2;

-- Total cases vs total deaths
-- Shows likelihood of dying if you contract covid in PH

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths
WHERE location LIKE 'Philippines'
ORDER BY 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, population, total_cases,  (total_cases/population)*100 as percent_population_infected
FROM covid_deaths
WHERE total_cases IS NOT NULL AND population IS NOT NULL AND continent IS NOT NULL
GROUP BY location, population, total_cases
ORDER BY percent_population_infected DESC


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as highest_infection, MAX(total_cases/population)*100 as percent_population_infected
FROM covid_deaths
WHERE population IS NOT NULL AND total_cases IS NOT NULL AND continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as total_death_count, MAX(total_deaths/population)*100 as percent_popu_deaths
FROM covid_deaths
WHERE total_deaths IS NOT NULL and continent IS NOT NULL
GROUP BY location
ORDER BY percent_popu_deaths DESC;

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY total_death_count DESC;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) as rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 2,3;

-- Using WITH clause to determing the percentage of running vaccinated over population

WITH pop_vs_vacc (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) as rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 2,3
)

SELECT *, (rolling_people_vaccinated/population)*100 as rolling_percentage_vacc
FROM pop_vs_vacc;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS percent_population_vaccinated;
CREATE TABLE percent_population_vaccinated(
	continent VARCHAR(255),
	location VARCHAR(255),
	date DATE,
	population NUMERIC,
	new_vaccinations NUMERIC,
	rolling_percentage_vacc NUMERIC
);

INSERT INTO percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) as rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 2,3;

SELECT *, (rolling_percentage_vacc/population)*100 as rolling_people_vaccinated
FROM percent_population_vaccinated

-- CREATING VIEW to store data for later viz.

CREATE VIEW percent_population_vacc as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) as rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 2,3;
