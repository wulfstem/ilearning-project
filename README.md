# Microsoft Fabric Data Engineering Project

Final project for the "Software Engineer" internship in the Data Group at Itransition.

This project demonstrates a complete data engineering workflow using **Microsoft Fabric**, integrating mobility, environmental, and economic data to analyze urban patterns in New York City.

## Project Overview

**Goal:** Build a unified analytics platform that combines:

- **NYC Taxi Trip Data** - Urban mobility patterns across 265 zones
- **Air Quality Data (OpenAQ)** - PM2.5 pollution measurements from NYC monitoring stations
- **Economic Data** - US GDP and USD/EUR exchange rates

**Key Questions:**

- How does taxi traffic relate to air pollution levels?
- What are peak travel times and revenue trends by borough and zone?
- How do economic indicators correlate with urban mobility?

## Architecture

### Medallion Architecture (Bronze → Silver → Gold)

```
Lakehouse
├── Bronze Layer (Raw Data)
│   ├── nyc_taxi/          # Monthly parquet files (2019-2024)
│   ├── openaq/            # Air quality locations
│   ├── ecb_fx/            # Daily USD/EUR exchange rates
│   └── worldbank_gdp/     # Annual GDP data
│
├── Silver Layer (Cleaned Data)
│   ├── silver_nyc_taxi    # Standardized taxi trips with date columns
│   ├── silver_openaq      # Air quality locations
│   ├── silver_ecb_fx_rates # Clean FX rates with date dimensions
│   └── silver_gdp         # GDP with year-over-year growth
│
└── Gold Layer (Star Schema Warehouse)
    ├── DimDate            # 2,192 days (2019-2024)
    ├── DimZone            # 265 NYC taxi zones
    ├── DimFX              # 1,538 trading days
    ├── DimGDP             # 6 years of US GDP
    ├── FactTaxiDaily      # 14.8M daily zone-level aggregates
    └── FactAirQualityDaily # 2,192 daily air quality measurements
```

## Data Warehouse - Star Schema

### Dimension Tables

#### **DimDate** (2,192 rows)

Calendar dimension covering 2019-2024 with full date attributes.

| Column                    | Type    | Description                   |
| ------------------------- | ------- | ----------------------------- |
| DateKey                   | INT     | Primary key (YYYYMMDD format) |
| Date                      | DATE    | Actual date                   |
| Year, Quarter, Month, Day | INT     | Date components               |
| MonthName, DayName        | VARCHAR | Text representations          |
| DayOfWeek                 | INT     | 1=Monday, 7=Sunday            |
| IsWeekend, IsHoliday      | BIT     | Boolean flags                 |
| WeekOfYear                | INT     | ISO week number               |

#### **DimZone** (265 rows)

NYC taxi zones with borough information.

| Column      | Type         | Description                                            |
| ----------- | ------------ | ------------------------------------------------------ |
| ZoneKey     | INT          | Primary key                                            |
| LocationID  | INT          | TLC location ID                                        |
| ZoneName    | VARCHAR(100) | Zone name (e.g., "Alphabet City")                      |
| Borough     | VARCHAR(50)  | Manhattan, Brooklyn, Queens, Bronx, Staten Island, EWR |
| ServiceZone | VARCHAR(50)  | Yellow Zone, Boro Zone, Airports                       |

#### **DimFX** (1,538 rows)

Daily USD/EUR exchange rates for all trading days 2019-2024.

| Column       | Type          | Description                |
| ------------ | ------------- | -------------------------- |
| FXKey        | INT           | Primary key                |
| Date         | DATE          | Trading date               |
| CurrencyFrom | VARCHAR(10)   | "USD"                      |
| CurrencyTo   | VARCHAR(10)   | "EUR"                      |
| ExchangeRate | DECIMAL(10,6) | USD to EUR conversion rate |

#### **DimGDP** (6 rows)

Annual US GDP 2019-2024.

| Column      | Type          | Description     |
| ----------- | ------------- | --------------- |
| GDPKey      | INT           | Primary key     |
| Year        | INT           | Year            |
| CountryName | VARCHAR(100)  | "United States" |
| GDP         | DECIMAL(18,2) | GDP in USD      |

**Sample Data:**
| Year | GDP (Trillions USD) |
|------|---------------------|
| 2019 | $21.38T |
| 2020 | $21.06T |
| 2021 | $23.32T |
| 2022 | $25.60T |
| 2023 | $27.29T |
| 2024 | $28.75T |

### Fact Tables

#### **FactTaxiDaily** (14,827,172 rows)

Daily aggregated taxi metrics by pickup and dropoff zone.

| Column          | Type    | Description                      |
| --------------- | ------- | -------------------------------- |
| TaxiDailyKey    | INT     | Primary key                      |
| DateKey         | INT     | FK to DimDate                    |
| PickupZoneKey   | INT     | FK to DimZone (pickup location)  |
| DropoffZoneKey  | INT     | FK to DimZone (dropoff location) |
| TripCount       | INT     | Number of trips                  |
| TotalPassengers | INT     | Sum of passengers                |
| TotalDistance   | DECIMAL | Total miles traveled             |
| TotalFareAmount | DECIMAL | Total fare revenue               |
| TotalTipAmount  | DECIMAL | Total tips                       |
| TotalTollAmount | DECIMAL | Total tolls                      |
| TotalAmount     | DECIMAL | Total trip cost                  |
| AvgTripDistance | DECIMAL | Average trip distance            |
| AvgFareAmount   | DECIMAL | Average fare                     |
| AvgTripDuration | DECIMAL | Average trip time (minutes)      |

#### **FactAirQualityDaily** (2,192 rows)

Daily PM2.5 air quality measurements from NYC monitoring stations.

| Column             | Type         | Description                 |
| ------------------ | ------------ | --------------------------- |
| AirQualityDailyKey | INT          | Primary key                 |
| DateKey            | INT          | FK to DimDate               |
| LocationID         | BIGINT       | OpenAQ location identifier  |
| LocationName       | VARCHAR(200) | Monitoring station name     |
| AvgPM25            | DECIMAL      | Average daily PM2.5 (μg/m³) |
| MaxPM25            | DECIMAL      | Maximum PM2.5 reading       |
| MinPM25            | DECIMAL      | Minimum PM2.5 reading       |
| MeasurementCount   | INT          | Number of hourly readings   |

## Data Pipeline

### Phase 1: Data Ingestion (Bronze)

- **Data Factory Pipelines**: Automated download of 72 monthly NYC Taxi parquet files (2019-2024)
  - Parent pipeline loops through years
  - Child pipeline downloads 12 months per year
  - Sequential execution to avoid concurrent write conflicts
- **Dataflows Gen2**: World Bank GDP, and ECB exchange rates
- **Notebook**: OpenAQ (could not use Dataflows Gen2 because of needed API key)
- **Storage**: Raw data lands in Lakehouse Bronze layer

### Phase 2: Data Transformation (Silver)

- **PySpark Notebooks**: Schema standardization, data cleaning, enrichment
- **Transformations Applied**:
  - Added date/time dimensions (pickup_year, pickup_month, pickup_day, dayofweek)
  - Calculated derived metrics (trip_duration_minutes, speed_mph)
  - Standardized column names (lowercase)
  - Data quality validation and deduplication
  - Partitioned by year and month for optimal performance
- **Output**: Delta tables in Lakehouse Silver layer (35.6M taxi records processed)

### Phase 3: Data Modeling (Gold)

- **Star Schema Design**: 4 dimension tables + 2 fact tables in Fabric Warehouse
- **Aggregations**:
  - Taxi data aggregated from 35.6M trips → 14.8M daily zone pairs
  - Air quality data at daily grain
- **Population Method**:
  1. Created Delta tables in Lakehouse using PySpark notebooks
  2. Inserted from Lakehouse to Warehouse using SQL

### Phase 4: Analytics & Visualization

- Star schema optimized for Power BI
- SQL-ready for ad-hoc analysis

## Data Sources

| Source                                                                            | Type       | Time Range | Records            | Update Frequency |
| --------------------------------------------------------------------------------- | ---------- | ---------- | ------------------ | ---------------- |
| [NYC TLC Taxi Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page) | Parquet    | 2019-2024  | 35.6M trips        | Monthly          |
| [OpenAQ](https://docs.openaq.org)                                                 | API (JSON) | 2024       | 57 locations       | Real-time        |
| [ECB Exchange Rates](https://data.ecb.europa.eu)                                  | API (CSV)  | 2019-2024  | 1,538 trading days | Daily            |
| [World Bank GDP](https://api.worldbank.org)                                       | API (JSON) | 2019-2024  | 6 years            | Annual           |

## Technologies Used

- **Microsoft Fabric**
  - Lakehouse (Delta Lake storage with partitioning)
  - Data Factory (Pipelines & Dataflows Gen2)
  - Notebooks (PySpark for transformations)
  - Warehouse (SQL analytics engine)
- **Languages**: Python (PySpark), SQL
- **Data Formats**: Delta Lake, Parquet, CSV, JSON
- **Architecture Pattern**: Medallion (Bronze-Silver-Gold)

## Key Achievements

**Data Integration** - Successfully integrated 4 heterogeneous data sources (Parquet, JSON APIs, CSV)  
**Scale** - Processed 35.6M taxi trip records → 14.8M daily aggregates  
**Star Schema Design** - Built production-ready dimensional model with 4 dimensions + 2 facts  
**Pipeline Automation** - Implemented nested ForEach loops for multi-year batch ingestion  
**Performance Optimization** - Partitioned data by year/month, generated surrogate keys efficiently  
**Cross-Domain Analytics** - Enabled correlation analysis across mobility, environment, and economy

## Data Highlights

- **Time Range**: 2019-2024 (6 years, 2,192 days)
- **Geographic Coverage**: 265 NYC taxi zones across 5 boroughs + airports
- **Volume**: 35.6M raw taxi trips → 14.8M daily zone-pair aggregates
- **Economic Context**: $21.38T to $28.75T GDP growth (34.5% increase)
- **Environmental Monitoring**: Daily PM2.5 tracking from multiple NYC stations

## Author

**Ervinas Vilkaitis**  
Software Engineer Intern - Data Group  
Itransition  
_January 2026_
