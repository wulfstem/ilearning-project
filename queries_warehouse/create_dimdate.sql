CREATE TABLE DimDate (
    DateKey INT NOT NULL,
    Date DATE,
    Year INT,
    Quarter INT,
    Month INT,
    MonthName VARCHAR(20),
    Day INT,
    DayOfWeek INT,
    DayName VARCHAR(20),
    IsWeekend BIT,
    IsHoliday BIT,
    WeekOfYear INT
);

INSERT INTO DimDate
SELECT 
    DateKey,
    Date,
    Year,
    Quarter,
    Month,
    MonthName,
    Day,
    DayOfWeek,
    DayName,
    IsWeekend,
    IsHoliday,
    WeekOfYear
FROM MobilityLakehouse.dbo.dimdate;