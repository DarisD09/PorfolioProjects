Select *
From PorfolioProject..CovidDeaths
where continent is not null
Order By 3,4

--Select *
--From PorfolioProject..CovidVaccionations
--Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PorfolioProject..CovidDeaths
Order By 1,2


-- Looking at Total Cases vs Total Deaths in the Dominican Republic 
-- From 01/03/2020 to 04/06/2023

Select Location, date, total_cases,total_deaths, CONVERT(DECIMAL(18, 2), 
(CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases))) as [DeathsOverTotal_In_DR] 
From PorfolioProject..CovidDeaths
Where location = 'Dominican Republic' And continent is not null
Order By 1,2


-- Total cases vs Population

Select Location, date, total_cases, population, (population/total_cases)*100 as [TotalOverPopulationl] 
From PorfolioProject..CovidDeaths
Where location = 'Dominican Republic' And continent is not null
Order By 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 As PercentPopulationInfected 
From PorfolioProject..CovidDeaths
Group By Location, population
Order By PercentPopulationInfected


-- Countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) As TotalDeathCount
From PorfolioProject..CovidDeaths
where continent is not null
Group By Location
Order By TotalDeathCount desc


-- Break down by Continent

Select continent, Max(cast(total_deaths as int)) As TotalDeathCount
From PorfolioProject..CovidDeaths
where continent is not null
Group By continent
Order By TotalDeathCount desc



-- Global Numbers

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(nullif(new_cases,0))*100 as DeathPercentage
From PorfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order By 1,2


-- Total Population vs Vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition By dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccionations vac
    On dea.Location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


With PopvsVac (continet, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition By dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccionations vac
    On dea.Location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition By dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccionations vac
    On dea.Location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Store data for later visualization 

create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition By dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccionations vac
    On dea.Location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3


Create view DeathsOverTotal_In_DR as
Select Location, date, total_cases,total_deaths, CONVERT(DECIMAL(18, 2), 
(CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases))) as DeathsOverTotal_In_DR 
From PorfolioProject..CovidDeaths
Where location = 'Dominican Republic' And continent is not null
--Order By 1,2



Create view TotalOverPopulationl_In_DR as
Select Location, date, total_cases, population, (population/total_cases)*100 as [TotalOverPopulationl_In_DR] 
From PorfolioProject..CovidDeaths
Where location = 'Dominican Republic' And continent is not null
--Order By 1,2


Create view TotalDeathCount as
Select Location, Max(cast(total_deaths as int)) As TotalDeathCount
From PorfolioProject..CovidDeaths
where continent is not null
Group By Location
--Order By TotalDeathCount desc



Create view TotalOverPopulation as
Select Location, date, total_cases, population, (population/total_cases)*100 as [TotalOverPopulationl] 
From PorfolioProject..CovidDeaths
Where location = 'Dominican Republic' And continent is not null
--Order By 1,2


Select *
From PercentPopulationVaccinated