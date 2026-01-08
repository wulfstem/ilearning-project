CREATE TABLE DimGDP (
    GDPKey INT NOT NULL,
    Year INT NOT NULL,
    CountryName VARCHAR(100),
    GDP DECIMAL(18, 2)
);

INSERT INTO DimGDP
SELECT 
    GDPKey,
    Year,
    CountryName,
    GDP
FROM MobilityLakehouse.dbo.dimgdp;