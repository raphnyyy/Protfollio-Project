--dataset of covid-19 in thailand
-- URL:https://ourworldindata.org/covid-deaths
--Latest information as of 30/05/22
--Covid-19 deaths dataset around the world (coviddeaths.csv)
--Covid-19 vaccine dataset around the world (covidvaccination.csv)

--1.Views dataset : Thailand's Dead and Vaccinated Datasets in Thailand

--1.1  Thailand's Dead Datasets
SELECT * FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE location LIKE '%thai%'
ORDER BY location,date

--1.2  Thailand's Vaccinated Datasets
SELECT * FROM [SQL-Exploration-PortfollioProject].dbo.CovidVaccination$
WHERE location = 'Thailand'
ORDER BY location,date



--2. Select data that we are about to be useing in this project
--dataset coviddeath
SELECT location,date,population,total_cases,new_cases
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE location LIKE '%thai%'
ORDER BY location,date
--dataset covidvaccination
SELECT location,date,population,total_cases,new_cases
FROM [SQL-Exploration-PortfollioProject].dbo.CovidVaccination$
WHERE location LIKE '%thai%'
ORDER BY location,date



--QUESTION
--Question 2.1 : deaths percentage in thailand (total deaths VS total cases)
--Solve : Probability of dying if you contract covid in Thailand
SELECT location,date,
		total_cases,
		total_deaths,
		ROUND((total_deaths/total_cases)*100,5) AS deathspercentage
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE location LIKE '%thai%'
ORDER BY location,date DESC

--Question 2.2  : Percentage of population got covid in thailand
SELECT location,date,
	   total_cases,
	   population,
	   (total_cases/population)*100 AS gotcovidpercentage	   
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE location = 'Thailand'
ORDER BY gotcovidpercentage DESC

--Question 2.3 Number of infected people by year  
SELECT DATEPART(YEAR,date) AS year,
	   MAX(total_cases) AS total_case
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE location = 'Thailand'
GROUP BY DATEPART(YEAR,date)
ORDER BY year


--Question2.4 : Number of infected people by year, month, quarter in thailand
SELECT DATEPART(YEAR,date) AS year,
	   DATEPART(QUARTER,date) AS quarter,
	   DATEPART(month,date) AS month,
	   MAX(total_cases) AS cases
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE location LIKE '%thai%'
GROUP BY  ROLLUP( DATEPART(YEAR,date),DATEPART(QUARTER,date), DATEPART(month,date))
ORDER BY year,quarter,month

--Question2.5 :  Number of infected people by month
WITH cte as
(
SELECT DATEPART(YEAR,date) AS year,
	   DATEPART(QUARTER,date) AS quarter,
	   DATEPART(month,date) AS month,
	   MAX(total_cases) AS cases
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE location LIKE '%thai%'
GROUP BY  ROLLUP( DATEPART(YEAR,date),DATEPART(QUARTER,date), DATEPART(month,date))

)
SELECT year,month,cases FROM cte
WHERE month IS NOT NULL
ORDER BY year,quarter,month

--Queation2.6 :  Number of infected people by quarter

SELECT DATEPART(YEAR,date) AS year,
	   DATEPART(QUARTER,date) AS quarter,
	   DATEPART(month,date) AS month,
	   MAX(total_cases) AS cases
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE location LIKE '%thai%'
GROUP BY  ROLLUP( DATEPART(YEAR,date),DATEPART(QUARTER,date), DATEPART(month,date))
HAVING  DATEPART(month,date) IS NULL
ORDER BY year,quarter


--join table vaccinations and preview dataset
SELECT *
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$ AS cd
LEFT JOIN [SQL-Exploration-PortfollioProject].dbo.CovidVaccination$ AS cv
ON cd.continent = cv.continent
AND cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cd.location = 'Thailand'
ORDER BY cd.date DESC


--2.7.cumulative number of infected people in Thailand who have been vaccinated compared to the population
SELECT  cd.continent,
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations,
		SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS CumulativeVaccinated

FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$ AS cd
LEFT JOIN [SQL-Exploration-PortfollioProject].dbo.CovidVaccination$ AS cv
ON cd.continent = cv.continent
AND cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cd.location = 'Thailand'
ORDER BY  cd.location,cd.date DESC


--2.8. Percentage of people in Thailand who have been vaccinated compared to the population
--Create Common Table Expression
WITH cte (Continent,Location,Date,Population,New_vaccinations,CumulativeVaccinated) AS
(
	SELECT  cd.continent,
			cd.location,
			cd.date,
			cd.population,
			cv.new_vaccinations,
			SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY  cd.location,cd.date ) AS CumulativeVaccinated

FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$ AS cd
LEFT JOIN [SQL-Exploration-PortfollioProject].dbo.CovidVaccination$ AS cv
ON cd.continent = cv.continent
AND cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cd.location = 'Thailand'
)

SELECT * ,(CumulativeVaccinated/Population)*100 FROM cte


-- Create view to store data of covid deaths and vaccinations 
DROP VIEW IF EXISTS CovidDeathAndVaccination
CREATE VIEW CovidDeathAndVaccination AS
SELECT cd.continent,
		cd.location,
		cd.date,
		cd.population,
		cd.new_cases,
		cd.total_cases,
		cd.new_deaths,
		cd.total_deaths,
		cv.new_vaccinations,
		cv.total_vaccinations
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$ AS cd
LEFT JOIN [SQL-Exploration-PortfollioProject].dbo.CovidVaccination$ AS cv
ON cd.continent = cv.continent
AND cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cd.location = 'Thailand'


-- Create view to store data of tha 
DROP VIEW IF EXISTS CumulativeVaccinatedTH
CREATE VIEW CumulativeVaccinatedTH AS
SELECT  cd.continent,
			cd.location,
			cd.date,
			cd.population,
			cv.new_vaccinations,
			SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY  cd.location,cd.date ) AS CumulativeVaccinated

FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$ AS cd
LEFT JOIN [SQL-Exploration-PortfollioProject].dbo.CovidVaccination$ AS cv
ON cd.continent = cv.continent
AND cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cd.location = 'Thailand'

SELECT * FROM CumulativeVaccinatedTH







--WORLDWIDE COVID-19 DATASET
-- URL:https://ourworldindata.org/covid-deaths
--Latest information as of 30/05/22
--Covid-19 deaths dataset around the world (coviddeaths.csv)
--Covid-19 vaccine dataset around the world (covidvaccination.csv)


--CHECK COUNTRIES DATASET
SELECT distinct(continent),location
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE continent IS NOT NULL
--location = country : world,upper middle income,high income,lower middle income,low income,International is not included
--The European Union is in Europe, so it will not be included 
--Continent data type will not be included in the location column.
--data

-- Worldwide Dead Datasets
SELECT * FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY location,date

-- Worldwide Vaccinated Datasets
SELECT * FROM [SQL-Exploration-PortfollioProject].dbo.CovidVaccination$
WHERE continent IS NOT NULL
ORDER BY location,date



--QUESTION

--Question 1 : Number and percentage of infected countries and deaths by country each year
SELECT DATEPART(YEAR,date) AS year,
	   location,
	   population,
	   SUM(new_cases) AS total_cases, 
	   SUM(CAST(new_deaths AS float)) AS total_deaths,
	   ROUND((SUM(new_cases)/population),5)*100  AS percentinfected,
	   ROUND((SUM(CAST(new_deaths AS float))/population),5)*100 AS percentdeaths
	  FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY DATEPART(YEAR,date),population, location
ORDER BY  location, population
		


--Question 2 : Percentage likelihood that if infected with covid-19 will have a chance of dying
SELECT SUM(new_cases) AS total_cases,
	   SUM(CONVERT(bigint,new_deaths)) AS total_deaths,
	   ROUND(SUM(CONVERT(bigint,new_deaths))/SUM(new_cases),5) AS DeathsPercentage
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE continent IS NULL


--Quesion 3  : Percentage Countries with the most infections compared to their own population 
SELECT location,population,SUM(new_cases) AS infected,
	   ROUND(SUM((new_cases/population)*100),5) AS percentagehightinfected
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE continent IS  NOT NULL
GROUP BY  location,population
ORDER BY  percentagehightinfected DESC


--Question 4 : Percentage Countries with the most dying Percentage Countries with the most dying per population
SELECT location,population,SUM(CONVERT(bigint,new_deaths)) AS total_deaths,
	   ROUND(((SUM(CONVERT(bigint,new_deaths))/population)*100),5) AS Percentagedeath
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$
WHERE continent IS  NOT NULL
GROUP BY location,population
ORDER BY Percentagedeath DESC   



--Question 5 : Number of people infecteded and vaccinated by continent

WITH cte (Continent,Total_cases,Total_deaths) AS
(
SELECT cd.continent,cd.total_cases,cv.total_deaths
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$ AS cd
JOIN [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$  AS cv
ON cd.continent= cv.continent
)

SELECT Continent,
	    MAX(Total_cases) AS Maxcases,
	    MAX(CAST(Total_deaths AS bigint)) AS Maxdeaths
FROM  cte 
GROUP BY Continent

 
--Question 6 : The number of people who are infected with the dead and who have been vaccinated
SELECT cd.continent,
       cd.population,
	   MAX(cd.total_cases) AS Total_Cases ,
	   MAX(CAST(cd.total_deaths AS bigint)) AS Total_deaths,
	   MAX(CONVERT(bigint,cv.total_vaccinations)) AS total_vaccinations
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$ AS cd
JOIN [SQL-Exploration-PortfollioProject].dbo.CovidVaccination$  AS cv
ON cd.continent= cv.continent
WHERE cd.continent IS NOT NULL
GROUP BY cd.continent,cd.population
 
 
 --Question 7 : percentage of death worldwide
SELECT SUM(new_cases) AS total_cases,
		SUM(CAST(new_deaths AS bigint)) AS total_deaths,
		((SUM(CAST(new_deaths AS bigint))/SUM(new_cases))*100) AS DeathsPercentage
FROM [SQL-Exploration-PortfollioProject].dbo.CovidDeaths$ AS  cd
WHERE continent IS NULL











	  



	   







