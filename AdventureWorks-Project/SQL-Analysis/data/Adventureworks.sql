CREATE DATABASE AdventureWorksDW;
USE AdventureWorksDW;

CREATE TABLE dim_customer (
    CustomerKey INT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Gender VARCHAR(10),
    DateFirstPurchase DATE
);
select * from dim_customer;

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
select * from dim_date;

CREATE TABLE dim_product_category (
    ProductCategoryKey INT PRIMARY KEY,
    EnglishProductCategoryName VARCHAR(100)
);
select * from dim_product_category;

CREATE TABLE dim_product_subcategory (
    ProductSubcategoryKey INT PRIMARY KEY,
    EnglishProductSubcategoryName VARCHAR(100),
    ProductCategoryKey INT
);
select * from dim_product_subcategory;


CREATE TABLE dim_product (
    ProductKey INT PRIMARY KEY,
    EnglishProductName VARCHAR(255),
    ProductSubcategoryKey INT,
    UnitPrice DECIMAL(10,2),
    UnitCost DECIMAL(10,2)
);

select * from dim_Product;

CREATE TABLE dim_sales_territory (
    SalesTerritoryKey INT PRIMARY KEY,
    SalesTerritoryRegion VARCHAR(100),
    SalesTerritoryCountry VARCHAR(100),
    SalesTerritoryGroup VARCHAR(100)
);

select * from dim_sales_territory;

CREATE TABLE fact_internet_sales (
    SalesOrderNumber VARCHAR(50),
    ProductKey INT,
    CustomerKey INT,
    OrderDateKey INT,
    OrderQuantity INT,
    UnitDiscount DECIMAL(10,2),
    SalesTerritoryKey INT
);

select * from fact_internet_sales;

CREATE TABLE fact_internet_sales_new (
    SalesOrderNumber VARCHAR(50),
    ProductKey INT,
    CustomerKey INT,
    OrderDateKey INT,
    OrderQuantity INT,
    DiscountAmount DECIMAL(10,2),
    SalesTerritoryKey INT
);
select * from fact_internet_sales_new;

-- Union of Fact Internet Sales & Fact Internet Sales New
CREATE OR REPLACE VIEW vw_fact_sales AS
SELECT * FROM fact_internet_sales
UNION ALL
SELECT * FROM fact_internet_sales_new;
select * from vw_fact_sales;

-- Lookup Product Name from Product sheet to Sales sheet
SELECT
    f.SalesOrderNumber,
    f.ProductKey,
    p.EnglishProductName
FROM vw_fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey;
    
  -- Lookup Customer Full Name & Unit Price  
SELECT
    f.SalesOrderNumber,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName,
    p.UnitPrice
FROM vw_fact_sales f
JOIN dim_customer c
    ON f.CustomerKey = c.CustomerKey
JOIN dim_product p
    ON f.ProductKey = p.ProductKey;

-- Date Calculations from OrderDateKey
SELECT
    STR_TO_DATE(f.OrderDateKey, '%Y%m%d') AS OrderDate,
    YEAR(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS Year,
    MONTH(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS MonthNo,
    MONTHNAME(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS MonthFullName,
    CONCAT('Q', QUARTER(STR_TO_DATE(f.OrderDateKey, '%Y%m%d'))) AS Quarter,
    DATE_FORMAT(STR_TO_DATE(f.OrderDateKey, '%Y%m%d'), '%Y-%b') AS YearMonth,
    WEEKDAY(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) + 1 AS WeekdayNo,
    DAYNAME(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS WeekdayName,
    CASE
        WHEN MONTH(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) >= 4
            THEN MONTH(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) - 3
        ELSE MONTH(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) + 9
    END AS FinancialMonth,
    CONCAT('FQ',
        CASE
            WHEN MONTH(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) BETWEEN 4 AND 6 THEN 1
            WHEN MONTH(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) BETWEEN 7 AND 9 THEN 2
            WHEN MONTH(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) BETWEEN 10 AND 12 THEN 3
            ELSE 4
        END
    ) AS FinancialQuarter
FROM vw_fact_sales f;

-- Calculate Sales Amount
SELECT
    f.SalesOrderNumber,
    (p.UnitPrice * f.OrderQuantity) - f.UnitDiscount AS SalesAmount
FROM vw_fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey;
    
 -- Calculate Production Cost
 SELECT
    f.SalesOrderNumber,
    p.UnitCost * f.OrderQuantity AS ProductionCost
FROM vw_fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey;

   -- Calculate Profit 
   SELECT
    f.SalesOrderNumber,
    ((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount)
    -
    (p.UnitCost * f.OrderQuantity) AS Profit
FROM vw_fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey;

-- Month vs Sales (Year Filter)
SELECT
    MONTHNAME(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS Month,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS TotalSales
FROM vw_fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
WHERE YEAR(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) = 2013
GROUP BY Month;

-- Yearwise Sales
SELECT
    YEAR(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS Year,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS TotalSales
FROM vw_fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
GROUP BY Year;

-- Monthwise Sales
SELECT
    DATE_FORMAT(STR_TO_DATE(f.OrderDateKey, '%Y%m%d'), '%Y-%m') AS YearMonth,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS TotalSales
FROM vw_fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
GROUP BY YearMonth;

-- Quarterwise Sales
SELECT
    CONCAT('Q', QUARTER(STR_TO_DATE(f.OrderDateKey, '%Y%m%d'))) AS Quarter,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS TotalSales
FROM vw_fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
GROUP BY Quarter;

-- Sales vs Production Cost
SELECT
    YEAR(STR_TO_DATE(f.OrderDateKey, '%Y%m%d')) AS Year,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS SalesAmount,
    SUM(p.UnitCost * f.OrderQuantity) AS ProductionCost
FROM vw_fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
GROUP BY Year;

-- By Product
SELECT
    p.EnglishProductName,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS Sales
FROM vw_fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName;

-- By Customer
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS Customer,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS Sales
FROM vw_fact_sales f
JOIN dim_customer c
    ON f.CustomerKey = c.CustomerKey
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
GROUP BY Customer;

-- By Region
SELECT
    t.SalesTerritoryRegion,
    SUM((p.UnitPrice * f.OrderQuantity) - f.UnitDiscount) AS Sales
FROM vw_fact_sales f
JOIN dim_sales_territory t
    ON f.SalesTerritoryKey = t.SalesTerritoryKey
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
GROUP BY t.SalesTerritoryRegion;

-- Dashboard
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

