# Data
dátová analýza v Pythone, 
ukážka SQL filtrovania, použitie CTE, dočasná tabuľka a view


# VizualizeData.ipynb

obsahuje základné možnosti zobrazenia a filtrovania dát

používa "Gapminder" dáta zabudované v Plotly

Plotly nie je súčasťou Anacondy, treba ho doinštalovať.


**Postup inštalácie Plotly:**

Vypnúť JupyterLab

pip install plotly

pip install "ipywidgets>=7.5"

jupyter labextension install jupyterlab-plotly

Zapnúť JupyterLab znovu


# AnalyseData.ipynb

obsahuje základné možnosti štatistickej analýzy aj zobrazenia

používa "Gapminder" dáta zabudované v Plotly, a tabuľky account.asc a property_prices.csv


# Covid.sql

zdroj dát: https://ourworldindata.org/covid-deaths (treba rozdeliť na dve tabuľky: Úmrtnosť a Zaočkovanosť, potom budeme spájať ak treba)

**-- Kontinenty najväčšou úmrtnosťou v pomere k celkovej populácii**

SELECT location,

		population,
   
		MAX(Total_Deaths*1.0/population*1.0)*100 AS DeathRatePopulation
  
FROM CovidData..Umrtnost

WHERE continent is null

GROUP BY location, population

ORDER BY DeathRatePopulation DESC


**-- Globálne hodnoty**

SELECT date, 

		SUM(new_cases) AS Total_Cases,
  
		SUM(cast(new_deaths as int)) AS Total_Deaths,
  
		(SUM(cast(new_deaths as int))*1.0/SUM(new_cases)*1.0)*100 AS DeathPecentage
  
FROM CovidData..Umrtnost

WHERE continent is not NULL

GROUP BY date

HAVING SUM(new_cases)*1.0 > 0

ORDER BY 1,2


**-- Celosvetovo**

SELECT 	SUM(new_cases) AS Total_Cases,

		SUM(cast(new_deaths as int)) AS Total_Deaths,
  
		(SUM(cast(new_deaths as int))*1.0/SUM(new_cases)*1.0)*100 AS DeathPecentage
  
FROM CovidData..Umrtnost

WHERE continent is not NULL

HAVING SUM(new_cases)*1.0 > 0

ORDER BY 1,2


**--JOINS**

SELECT *

FROM CovidData..Umrtnost U

JOIN CovidData..Ockovanost Va

	ON U.location = Va.location
 
	AND U.date = Va.date


**-- Celková populácia a nové očkovania**

SELECT U.continent,

		U.location,
  
		U.date,
  
		U.population,
  
		Va.new_vaccinations

FROM CovidData..Umrtnost U

JOIN CovidData..Ockovanost Va

	ON U.location = Va.location
 
	AND U.date = Va.date
 
WHERE U.continent is not NULL

ORDER BY 2,3


**-- Očkovanie a lokalita**

SELECT U.continent,

		U.location,
  
		U.date,
  
		U.population,
  
		Va.new_vaccinations,
  
		SUM(CAST(Va.new_vaccinations AS int)) OVER (PARTITION BY U.Location
  
		ORDER BY U.Location) AS RollingPeopleVaccinated

FROM CovidData..Umrtnost U

JOIN CovidData..Ockovanost Va

	ON U.location = Va.location
 
	AND U.date = Va.date
 
WHERE U.continent is not NULL

ORDER BY 2,3


**-- Populácia VS zaočkovanosť (CTE)**

WITH PopvsVac (Continent,

				location,
    
				Date,
    
				population,
    
				new_vaccinations,
    
				RollingPeopleVaccinated)
    
AS

(SELECT U.continent,

		U.location,
  
		U.date,
  
		U.population,
  
		Va.new_vaccinations,
  
		SUM(CAST(Va.new_vaccinations AS int)) OVER (PARTITION BY U.Location
  
		ORDER BY U.Location, U.Date) AS RollingPeopleVaccinated

FROM CovidData..Umrtnost U

JOIN CovidData..Ockovanost Va

	ON U.location = Va.location
 
	AND U.date = Va.date
 
WHERE U.continent is not NULL

--ORDER BY 2,3

)
SELECT *, (RollingPeopleVaccinated/population)*100

FROM PopvsVac



**-- Temp Table**

DROP TABLE IF Exists #DocasnaTabulka

CREATE TABLE #DocasnaTabulka

(

Continent nvarchar(255),

location nvarchar(255),

date datetime,

population numeric,

new_vaccinations numeric,

RollingPeopleVaccinated numeric

)

INSERT INTO #DocasnaTabulka

SELECT U.continent,

		U.location,
  
		U.date,
  
		U.population,
  
		Convert(bigint, Va.new_vaccinations),
  
		SUM(Convert(bigint, Va.new_vaccinations)) OVER (PARTITION BY U.Location
  
		ORDER BY U.Location, U.Date) AS RollingPeopleVaccinated

FROM CovidData..Umrtnost U

JOIN CovidData..Ockovanost Va

	ON U.location = Va.location
 
	AND U.date = Va.date
 
--WHERE U.continent is not NULL

--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100

FROM #DocasnaTabulka


**-- VIEW**

CREATE VIEW ViewTabulka AS

SELECT U.continent,

		U.location,
  
		U.date,
  
		U.population,
  
		Va.new_vaccinations,
  
		SUM(Convert(bigint, Va.new_vaccinations)) OVER (PARTITION BY U.Location
  
		ORDER BY U.Location, U.Date) AS RollingPeopleVaccinated

FROM CovidData..Umrtnost U

JOIN CovidData..Ockovanost Va

	ON U.location = Va.location
 
	AND U.date = Va.date
 
WHERE U.continent is not NULL

--ORDER BY 2,3


SELECT *

FROM ViewTabulka







