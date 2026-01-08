CREATE TABLE DimFX (
    FXKey INT NOT NULL,
    Date DATE NOT NULL,
    CurrencyFrom VARCHAR(10) NOT NULL,
    CurrencyTo VARCHAR(10) NOT NULL,
    ExchangeRate DECIMAL(10, 6) NOT NULL
);

INSERT INTO DimFX
SELECT 
    FXKey,
    Date,
    CurrencyFrom,
    CurrencyTo,
    ExchangeRate
FROM MobilityLakehouse.dbo.dimfx;