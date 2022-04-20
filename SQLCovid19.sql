SELECT * FROM PortfolioProject..Covid1
ORDER BY 3, 4;


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid1;

-- Total cases and Total deaths
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM PortfolioProject..Covid1
ORDER BY location, date;

-- Total cases and Total deaths in Europe
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM PortfolioProject..Covid1
WHERE location LIKE '%euro%'
ORDER BY location, date;

-- Counting death for each country in Europe
SELECT location, MAX(CAST(total_deaths AS int)) AS MaxDeaths
FROM PortfolioProject..Covid1
WHERE continent IN ('Europe', 'Europe Union')
GROUP BY location
ORDER BY location, MaxDeaths;


-- Percentage of population that got Covid-19 in Europe
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS GotCovid
FROM PortfolioProject..Covid1
WHERE location LIKE '%euro%'
ORDER BY location, date DESC;

-- Highest Infection rate compared to population (Europe)
SELECT location, MAX(total_cases) AS Infection_count, population, MAX((total_cases/population)) * 100 AS GotCovid
FROM PortfolioProject..Covid1
WHERE location LIKE '%euro%'
GROUP BY location, population
ORDER BY location, population;


-- Highest Infection rate compared to population
SELECT location, MAX(total_cases) AS Infection_count, population, MAX((total_cases/population)) * 100 AS GotCovid
FROM PortfolioProject..Covid1
GROUP BY location, population
ORDER BY location, population;

-- Highest death count per country
SELECT location, MAX(CAST(total_deaths AS int)) AS deaths_count
FROM PortfolioProject..Covid1
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY deaths_count ASC;

-- Highest death count per continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS deaths_count
FROM PortfolioProject..Covid1
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY deaths_count;

-- Global numbers
SELECT date, SUM(new_cases) AS tot_cases, SUM(CAST(new_deaths AS int)) AS tot_deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases)) * 100 AS death_percentage
FROM PortfolioProject..Covid1
GROUP BY date
ORDER BY 1, 2;

-- Percentage of death (Overall)
SELECT SUM(new_cases) AS tot_cases, SUM(CAST(new_deaths AS int)) AS tot_deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases)) * 100 AS death_percentage
FROM PortfolioProject..Covid1
ORDER BY 1, 2;

-- Day 18.5: The median time it takes from the first symptoms of COVID-19 to death is 18.5 days.
SELECT date, (SUM(CAST(new_deaths AS int)) / SUM(new_cases)*1000) AS DailyDeathRatio
FROM Covid1
GROUP BY date
ORDER BY date, DailyDeathRatio

-- join CovidData1 and CovidData2 on date and location
SELECT * 
FROM PortfolioProject..Covid1 deaths
JOIN PortfolioProject..CovidData2$ vaccination 
	ON deaths.date = vaccination.date AND deaths.location = vaccination.location

-- total population and vaccinations
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations
FROM PortfolioProject..Covid1 deaths
JOIN PortfolioProject..CovidData2$ vaccination 
	ON deaths.date = vaccination.date 
	AND deaths.location = vaccination.location
WHERE deaths.continent IS NOT NULL
ORDER BY continent, location, date

-- Vaccinations per day
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,
SUM(CAST(vaccination.new_vaccinations AS bigint)) OVER (PARTITION BY deaths.location, deaths.date) AS GotVaccinatedPerDay
FROM PortfolioProject..Covid1 deaths
JOIN PortfolioProject..CovidData2$ vaccination 
	ON deaths.date = vaccination.date 
	AND deaths.location = vaccination.location
WHERE deaths.continent IS NOT NULL
ORDER BY continent, location, date

-- average life expectancy in every country
SELECT continent, ROUND(AVG(life_expectancy), 3) AS AvgLifeExp
FROM PortfolioProject..CovidData2$
GROUP BY continent
ORDER BY 1, 2

-- CTE
WITH PeopleVaccinated (Continent, Location,  Date, Population, New_vaccinations , GotVaccinatedPerDay)
AS 
( SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,
SUM(CAST(vaccination.new_vaccinations AS bigint)) OVER (PARTITION BY deaths.location, deaths.date) AS GotVaccinatedPerDay
FROM PortfolioProject..Covid1 deaths
JOIN PortfolioProject..CovidData2$ vaccination 
	ON deaths.date = vaccination.date 
	AND deaths.location = vaccination.location
WHERE deaths.continent IS NOT NULL
)
SELECT * FROM PeopleVaccinated

-- Temp table
DROP TABLE IF EXISTS #VaccinatedPopulation
CREATE TABLE #VaccinatedPopulation
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
GotVaccinatedPerDay NUMERIC
)

INSERT INTO #VaccinatedPopulation
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,
SUM(CAST(vaccination.new_vaccinations AS bigint)) OVER (PARTITION BY deaths.location, deaths.date) AS GotVaccinatedPerDay
FROM PortfolioProject..Covid1 deaths
JOIN PortfolioProject..CovidData2$ vaccination 
	ON deaths.date = vaccination.date 
	AND deaths.location = vaccination.location
WHERE deaths.continent IS NOT NULL


SELECT population, (GotVaccinatedPerDay / population) * 100 AS PercVaccinated
FROM #VaccinatedPopulation