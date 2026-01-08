CREATE TABLE DimZone (
    ZoneKey INT NOT NULL,
    LocationID INT NOT NULL,
    ZoneName VARCHAR(100),
    Borough VARCHAR(50),
    ServiceZone VARCHAR(50)
);

INSERT INTO DimZone
SELECT 
    ZoneKey,
    LocationID,
    ZoneName,
    Borough,
    ServiceZone
FROM MobilityLakehouse.dbo.dimzone;