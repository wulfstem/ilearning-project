CREATE TABLE FactTaxiDaily (
    TaxiDailyKey INT NOT NULL,
    DateKey INT NOT NULL,
    PickupZoneKey INT,
    DropoffZoneKey INT,
    TripCount INT,
    TotalPassengers INT,
    TotalDistance DECIMAL(18, 2),
    TotalFareAmount DECIMAL(18, 2),
    TotalTipAmount DECIMAL(18, 2),
    TotalTollAmount DECIMAL(18, 2),
    TotalAmount DECIMAL(18, 2),
    AvgTripDistance DECIMAL(18, 2),
    AvgFareAmount DECIMAL(18, 2),
    AvgTripDuration DECIMAL(18, 2)
);

INSERT INTO FactTaxiDaily
SELECT 
    TaxiDailyKey,
    DateKey,
    PickupZoneKey,
    DropoffZoneKey,
    TripCount,
    TotalPassengers,
    TotalDistance,
    TotalFareAmount,
    TotalTipAmount,
    TotalTollAmount,
    TotalAmount,
    AvgTripDistance,
    AvgFareAmount,
    AvgTripDuration
FROM MobilityLakehouse.dbo.facttaxidaily;