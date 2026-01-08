DROP TABLE IF EXISTS FactAirQualityDaily;

CREATE TABLE FactAirQualityDaily (
    AirQualityDailyKey INT NOT NULL,
    DateKey INT NOT NULL,
    LocationID BIGINT,
    LocationName VARCHAR(200),
    AvgPM25 DECIMAL(10, 2),
    MaxPM25 DECIMAL(10, 2),
    MinPM25 DECIMAL(10, 2),
    MeasurementCount INT
);

INSERT INTO FactAirQualityDaily
SELECT 
    AirQualityDailyKey,
    DateKey,
    LocationID,
    LocationName,
    AvgPM25,
    MaxPM25,
    MinPM25,
    MeasurementCount
FROM MobilityLakehouse.dbo.factairqualitydaily;