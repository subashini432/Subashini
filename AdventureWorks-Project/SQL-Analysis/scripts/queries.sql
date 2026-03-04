/* =====================================================
   AdventureWorks Data Warehouse Project
   Author: Subashini
   Description: Data Warehouse schema + Sales Analysis
   ===================================================== */


/* =========================
   1️⃣ CREATE DATABASE
   ========================= */

CREATE DATABASE AdventureWorksDW;
USE AdventureWorksDW;


/* =========================
   2️⃣ DIMENSION TABLES
   ========================= */

CREATE TABLE dim_customer (
    CustomerKey INT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Gender VARCHAR(10),
    DateFirstPurchase DATE
);

CREATE TABLE dim_date (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    DayNumberOfWeek INT,
    EnglishDayNameOfWeek VARCHAR(20),
    MonthNumberOfYear INT,
    EnglishMonthName VARCHAR(20),
    CalendarQuarter INT,
    CalendarYear INT
);

CREATE TABLE dim_product_category (
    ProductCategoryKey INT PRIMARY KEY,
    EnglishProductCategoryName VARCHAR(100)
);

CREATE TABLE dim_product_subcategory (
    ProductSubcategoryKey INT PRIMARY KEY,
    EnglishProductSubcategoryName VARCHAR(100),
    ProductCategoryKey INT
);

CREATE TABLE dim_product (
    ProductKey INT PRIMARY KEY,
    EnglishProductName VARCHAR(255),
    ProductSubcategoryKey INT,
    UnitPrice DECIMAL(10,2),
    UnitCost DECIMAL(10,2)
);

CREATE TABLE dim_sales_territory (
    SalesTerritoryKey INT PRIMARY KEY,
    SalesTerritoryRegion VARCHAR(100),
    SalesTerritoryCountry VARCHAR(100),
    SalesTerritoryGroup VARCHAR(100)
);


/* =========================
   3️⃣ FACT TABLES
   ========================= */

CREATE TABLE fact_internet_sales (
    SalesOrderNumber VARCHAR(50),
    ProductKey INT,
    CustomerKey INT,
    OrderDateKey INT,
    OrderQuantity INT,
    UnitDiscount DECIMAL(10,2),
    SalesTerritoryKey INT
);

CREATE TABLE fact_internet_sales_new (
    SalesOrderNumber VARCHAR(50),
    ProductKey INT,
    CustomerKey INT,
    OrderDateKey INT,
    OrderQuantity INT,
    DiscountAmount DECIMAL(10,2),
    SalesTerritoryKey INT
);


/* =========================
   4️⃣ COMBINED FACT VIEW
   ========================= */

CREATE OR REPLACE VIEW vw_fact_sales AS
SELECT * FROM fact_internet_sales
UNION ALL
SELECT * FROM fact_internet_sales_new;


/* =========================
   5️⃣ SALES CALCULATIONS
   ========================= */

-- Sales Amount
SELECT
    f.SalesOrderNumber,
    (p.UnitPrice * f.OrderQuantity) - f.UnitDiscount AS SalesAmount
FROM vw_fact_sales f
JOIN dim_product p ON f.ProductKey = p.ProductKey;

-- Production Cost
SELECT
    f.SalesOrderNumber,
    p.UnitCost * f.OrderQuantity AS ProductionCost
FROM vw_fact_sales f
JOIN dim_product p ON f.ProductKey = p.ProductKey;

-- Profit
SELECT
    f.SalesOrderNumber,
    ((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount)
      - (p.UnitCost * f.OrderQuantity) AS Profit
FROM vw_fact_sales f
JOIN dim_product p ON f.ProductKey = p.ProductKey;


/* =========================
   6️⃣ TIME-BASED ANALYSIS
   ========================= */

-- Year-wise Sales
SELECT
    YEAR(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS Year,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS TotalSales
FROM vw_fact_sales f
JOIN dim_product p ON f.ProductKey = p.ProductKey
GROUP BY Year;

-- Month-wise Sales
SELECT
    DATE_FORMAT(STR_TO_DATE(f.OrderDateKey, '%Y%m%d'), '%Y-%m') AS YearMonth,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS TotalSales
FROM vw_fact_sales f
JOIN dim_product p ON f.ProductKey = p.ProductKey
GROUP BY YearMonth;

-- Quarter-wise Sales
SELECT
    CONCAT('Q', QUARTER(STR_TO_DATE(f.OrderDateKey, '%Y%m%d'))) AS Quarter,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS TotalSales
FROM vw_fact_sales f
JOIN dim_product p ON f.ProductKey = p.ProductKey
GROUP BY Quarter;


/* =========================
   7️⃣ BUSINESS ANALYSIS
   ========================= */

-- Sales by Product
SELECT
    p.EnglishProductName,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS Sales
FROM vw_fact_sales f
JOIN dim_product p ON f.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName;

-- Sales by Customer
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS Customer,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS Sales
FROM vw_fact_sales f
JOIN dim_customer c ON f.CustomerKey = c.CustomerKey
JOIN dim_product p ON f.ProductKey = p.ProductKey
GROUP BY Customer;

-- Sales by Region
SELECT
    t.SalesTerritoryRegion,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS Sales
FROM vw_fact_sales f
JOIN dim_sales_territory t ON f.SalesTerritoryKey = t.SalesTerritoryKey
JOIN dim_product p ON f.ProductKey = p.ProductKey
GROUP BY t.SalesTerritoryRegion;


/* =========================
   8️⃣ FINAL DASHBOARD VIEW
   ========================= */

CREATE OR REPLACE VIEW vw_dashboard_sales AS
SELECT
    STR_TO_DATE(f.OrderDateKey, '%Y%m%d') AS OrderDate,
    YEAR(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS Year,
    MONTHNAME(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS Month,
    CONCAT('Q', QUARTER(STR_TO_DATE(f.OrderDateKey, '%Y%m%d'))) AS Quarter,

    p.EnglishProductName,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    t.SalesTerritoryRegion AS Region,

    f.OrderQuantity,
    p.UnitPrice,
    p.UnitCost,
    f.UnitDiscount,

    (p.UnitPrice * f.OrderQuantity) - f.UnitDiscount AS SalesAmount,
    (p.UnitCost * f.OrderQuantity) AS ProductionCost,
    ((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount)
      - (p.UnitCost * f.OrderQuantity) AS Profit
FROM vw_fact_sales f
JOIN dim_product p ON f.ProductKey = p.ProductKey
JOIN dim_customer c ON f.CustomerKey = c.CustomerKey
JOIN dim_sales_territory t ON f.SalesTerritoryKey = t.SalesTerritoryKey;
