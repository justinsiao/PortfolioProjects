-- FOR TABLEAU VIZ
-- 1.

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths
	, (SUM(CAST(new_deaths as DOUBLE PRECISION))/SUM(CAST(new_cases as DOUBLE PRECISION)))*100 as death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL;

-- 2.

SELECT location, SUM(new_deaths) as total_death_count
FROM covid_deaths
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International', 'Lower middle income', 'Upper middle income', 'High income', 'Low income')
GROUP BY location
ORDER BY total_death_count DESC;

-- 3.

SELECT location, population, COALESCE(MAX(total_cases), 0) as highest_infection, COALESCE(MAX(total_cases/population), 0)*100 as percent_population_infected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- 4.

SELECT location, population, date, COALESCE(MAX(total_cases), 0) as highest_infection, COALESCE(MAX(total_cases/population),0)*100 as percent_population_infected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY percent_population_infected DESC;
