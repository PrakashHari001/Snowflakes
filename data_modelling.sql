USE WAREHOUSE LOGISTICS_WH;
USE DATABASE LOGISTICS_DB;

CREATE OR REPLACE SCHEMA ANALYTICS_SCHEMA;
USE SCHEMA ANALYTICS_SCHEMA;

CREATE OR REPLACE TABLE DIM_VEHICLE (
    vehicle_key INTEGER AUTOINCREMENT,
    vehicleId STRING,
    vehicleType STRING,
    capacity NUMBER,
    availabilityStatus STRING
);

CREATE OR REPLACE TABLE DIM_DRIVER (
    driver_key INTEGER AUTOINCREMENT,
    driverId STRING,
    driverName STRING,
    licenseNumber STRING,
    contactNumber STRING
);

CREATE OR REPLACE TABLE DIM_WAREHOUSE (
    warehouse_key INTEGER AUTOINCREMENT,
    warehouseId STRING,
    warehouseName STRING,
    city STRING,
    storageCapacity NUMBER
);

CREATE OR REPLACE TABLE DIM_DATE (
    date_key INTEGER,
    full_date DATE,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    quarter INTEGER
);

CREATE OR REPLACE TABLE FACT_SHIPMENT (
    shipment_key INTEGER AUTOINCREMENT,
    shipmentId STRING,
    vehicleId STRING,
    driverId STRING,
    shipmentStatus STRING,
    sourceLocation STRING,
    destinationLocation STRING,
    dispatch_date_key INTEGER,
    shipmentWeight NUMBER,
    deliveryAlert STRING
);



INSERT INTO DIM_VEHICLE (
    vehicleId,
    vehicleType,
    capacity,
    availabilityStatus
)
SELECT
    vehicleId,
    vehicleType,
    capacity,
    availabilityStatus
FROM LOGISTICS_DB.SUPPLY_CHAIN_SCHEMA.VEHICLE;
SELECT * FROM DIM_VEHICLE LIMIT 10;



INSERT INTO DIM_DRIVER (
    driverId,
    driverName,
    licenseNumber,
    contactNumber
)
SELECT
    driverId,
    driverName,
    licenseNumber,
    contactNumber
FROM LOGISTICS_DB.SUPPLY_CHAIN_SCHEMA.DRIVER;




INSERT INTO DIM_WAREHOUSE (
    warehouseId,
    warehouseName,
    city,
    storageCapacity
)
SELECT
    warehouseId,
    warehouseName,
    city,
    storageCapacity
FROM LOGISTICS_DB.SUPPLY_CHAIN_SCHEMA.WAREHOUSE;




INSERT INTO DIM_DATE
SELECT DISTINCT
    TO_NUMBER(TO_CHAR(dispatchDate, 'YYYYMMDD')) AS date_key,
    dispatchDate,
    YEAR(dispatchDate),
    MONTH(dispatchDate),
    DAY(dispatchDate),
    QUARTER(dispatchDate)
FROM LOGISTICS_DB.SUPPLY_CHAIN_SCHEMA.SHIPMENT;




INSERT INTO FACT_SHIPMENT (
    shipmentId,
    vehicleId,
    driverId,
    shipmentStatus,
    sourceLocation,
    destinationLocation,
    dispatch_date_key,
    shipmentWeight,
    deliveryAlert
)
SELECT
    shipmentId,
    vehicleId,
    driverId,
    shipmentStatus,
    sourceLocation,
    destinationLocation,
    TO_NUMBER(TO_CHAR(dispatchDate, 'YYYYMMDD')),
    shipmentWeight,
    deliveryAlert
FROM LOGISTICS_DB.SUPPLY_CHAIN_SCHEMA.SHIPMENT;

SHOW TABLES;

SELECT
    f.shipmentId,
    v.vehicleType,
    d.driverName,
    f.shipmentStatus,
    f.sourceLocation,
    f.destinationLocation
FROM FACT_SHIPMENT f
JOIN DIM_VEHICLE v
ON f.vehicleId = v.vehicleId
JOIN DIM_DRIVER d
ON f.driverId = d.driverId
LIMIT 20;

SELECT
    shipmentStatus,
    COUNT(*) AS total_shipments
FROM FACT_SHIPMENT
GROUP BY shipmentStatus;

SELECT
    vehicleId,
    SUM(fuelCost) AS total_fuel_cost
FROM LOGISTICS_DB.SUPPLY_CHAIN_SCHEMA.FUEL_TRANSACTION
GROUP BY vehicleId
ORDER BY total_fuel_cost DESC;

CREATE OR REPLACE VIEW VW_DELIVERY_PERFORMANCE AS
SELECT
    shipmentStatus,
    COUNT(*) AS shipment_count
FROM FACT_SHIPMENT
GROUP BY shipmentStatus;
SELECT * FROM VW_DELIVERY_PERFORMANCE;

CREATE OR REPLACE VIEW MV_FUEL_COST AS
SELECT
    vehicleId,
    SUM(fuelCost) AS total_fuel_cost
FROM LOGISTICS_DB.SUPPLY_CHAIN_SCHEMA.FUEL_TRANSACTION
GROUP BY vehicleId;
SELECT * FROM MV_FUEL_COST;

SELECT shipmentId, COUNT(*)
FROM FACT_SHIPMENT
GROUP BY shipmentId
HAVING COUNT(*) > 1;

SELECT *
FROM FACT_SHIPMENT
WHERE shipmentWeight <= 0;

SELECT COUNT(*) FROM FACT_SHIPMENT;
SELECT COUNT(*) FROM DIM_DRIVER;
SELECT COUNT(*) FROM DIM_VEHICLE;
SELECT COUNT(*) FROM DIM_WAREHOUSE;
