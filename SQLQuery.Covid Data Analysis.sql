--Covid 19 Data Exploration 
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select *
From PortfolioProject.dbo.covid_deaths
Where continent is not null 
order by 3,4;

-- Retrieve the Data that we are using for analysis

Select location, date, population, total_cases, new_cases, total_deaths
From PortfolioProject.dbo.covid_deaths
Where continent is not null 
order by 1,2;

-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject.dbo.covid_deaths
Where continent is not null 
order by 1,2;

-- Using The same query to find a specific country's death percentage

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject.dbo.covid_deaths
Where location like '%Pakistan%'
and continent is not null 
order by 1,2;

-- Total Cases vs Population As population infected percentage

Select location, date, Population, total_cases,  (total_cases/population)*100 as Population_infected_percentage
From PortfolioProject.dbo.covid_deaths
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Population_infected_percentage
From PortfolioProject.dbo.covid_deaths
Group by Location, Population
order by Population_infected_percentage desc;

-- Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as Total_Death_Count
From PortfolioProject.dbo.covid_deaths
Where continent is not null 
Group by Location
order by Total_Death_Count desc;


-- contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as Total_Death_Count
From PortfolioProject.dbo.covid_deaths
Where continent is not null 
Group by continent
order by Total_Death_Count desc;

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From PortfolioProject.dbo.covid_deaths
where continent is not null 
order by 1,2

-- Population vs Vaccinations
-- Percentage of Population that has recieved Covid Vaccine (at least one dose)

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as People_Vaccinated
From PortfolioProject.dbo.covid_deaths d
Join PortfolioProject.dbo.covid_vaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, People_Vaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as People_Vaccinated
From PortfolioProject.dbo.covid_deaths d
Join PortfolioProject.dbo.covid_vaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
)
Select *, (People_Vaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #population_vaccination_percentage
Create Table #population_vaccination_percentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
People_Vaccinated numeric
)

Insert into #population_vaccination_percentage
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Cast(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.location, d.Date) as People_Vaccinated
From PortfolioProject.dbo.covid_deaths d
Join PortfolioProject.dbo.covid_vaccinations v
	On d.location = v.location
	and d.date = v.date;

Select *, (People_Vaccinated/Population)*100
From #population_vaccination_percentage


-- Creating View to store data for later visualizations

Create View population_vaccination_percentage as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Cast(v.new_vaccinations as int)) OVER (Partition by d.Location Order by d.location, d.Date) as People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.covid_deaths d
Join PortfolioProject.dbo.covid_vaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null;