create database zepto
use zepto

CREATE TABLE zepto (
    sku_id INT IDENTITY(1,1) PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp DECIMAL(8,2),
    discountPercent DECIMAL(5,2),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(8,2),
    weightInGms INT,
    outOfStock BIT,
    quantity INT
);

SELECT * FROM ZEPTO

SELECT COUNT(*) AS total_rows FROM zepto;

BULK INSERT zepto
FROM 'C:\data\zepto.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);


SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('zepto', 'zepto_v2');

INSERT INTO dbo.zepto (
    category,
    name,
    mrp,
    discountPercent,
    availableQuantity,
    discountedSellingPrice,
    weightInGms,
    outOfStock,
    quantity
)
SELECT
    category,
    name,
    mrp,
    discountPercent,
    availableQuantity,
    discountedSellingPrice,
    weightInGms,
    outOfStock,
    quantity
FROM dbo.zepto_v2;

SELECT * FROM zepto

------SELECT TOP 10 ROWS FROM THE TABLE------------
select TOP 10*
from zepto
 ----------find null values----------
 SELECT * FROM zepto 
 WHERE name is NULL 
 or
 category is NULL
  or
 mrp is NULL
  or
 discountpercent is NULL
  or
 availableQuantity is NULL
  or
 discountedSellingPrice is NULL
  or
 weightInGms is NULL
  or
 outOfStock is NULL;

 --------------------------different product categories--------------------------------------------------
 SELECT DISTINCT CATEGORY 
 FROM zepto
 order by category;
 ------------------------PRODUCTS WHICH ARE IN STOCK AND NOT IN STOCK 0 as false and 1 as true-------------------------------------
 select outofStock, COUNT(sku_id)
 from zepto
 GROUP BY outofStock;
 ----------------------------------PRODUCTS NAMES PRESENT MULTIPLE TIMES----------------------------------------------------
 SELECT name,COUNT(sku_id) as "NUMBER OF SKUs"
 FROM zepto
 GROUP BY name 
 HAVING count(sku_id)>1 
 ORDER BY count(sku_id) DESC;

 -----------------------data cleaning-----------
 ----------select product where the price= 0-----------------------
SELECT * FROM zepto
where mrp=0 or discountedSellingPrice =0;

DELETE FROM zepto 
where mrp=0;

-------------convert paisa to rupees-----------------------------
UPDATE zepto
set mrp=mrp /100.00,
discountedSellingPrice=discountedSellingPrice/100.00;

SELECT mrp,discountedSellingPrice FROM zepto 
--------------------------BUSINESS QUERIES-------------------------
----------select top 10 best valued products based on discount percentage------------
SELECT TOP 10
name,
mrp,
discountedSellingPrice
FROM zepto
ORDER BY discountedSellingPrice DESC;
-------------PRODUCTS WITH HIGH MRP BUT OUT OF STOCK-----------------------------
SELECT DISTINCT name,mrp
from zepto
where outOfStock=0 and mrp>300
ORDER BY mrp ASC;
---------------CALCULATE ESTIMATED REVINUUE FOR EACH CATEGORY-----------------
SELECT Category,
SUM (discountedSellingPrice * availableQuantity) as Total_Revenue 
from zepto 
GROUP BY category
ORDER BY total_revenue;
--------------------find the product where MRP IS 500RS AND DISCOUNT IS LESS THAN 10%----------
SELECT DISTINCT name,mrp,discountPercent
from zepto
where mrp>500 and discountPercent<10
ORDER BY mrp ASC,discountPercent ASC;
-------------IDENTIFY TOP 5 CATEGORIES OFFERING THBE HIGHEST AVERAGE DISCOUNT PERCENTAGE------------
SELECT category,
ROUND(AVG(discountPercent),2) as avg_Discount
from zepto
GROUP  BY category
ORDER BY avg_Discount ASC

----------------Top 3 discounted products per category---------------------
WITH ranked_products AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY category
               ORDER BY discountPercent DESC
           ) AS rn
    FROM zepto
)
SELECT *
FROM ranked_products
WHERE rn <= 3;
-----------top 10 best valued products --------------
SELECT TOP 10
       name, mrp, discountPercent, discountedSellingPrice
FROM ZEPTO
WHERE outOfStock = 0
ORDER BY discountPercent DESC;
-------------average mrp by category--------------
SELECT category, AVG(mrp) AS avg_mrp
FROM ZEPTO
GROUP BY category;
------------total inventory value by category-----------
SELECT category, AVG(mrp) AS avg_mrp
FROM ZEPTO
GROUP BY category;

