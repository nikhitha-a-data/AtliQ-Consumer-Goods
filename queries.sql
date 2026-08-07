/* ============================================================================
   AtliQ Consumer Goods: Ad-Hoc Business Request Solutions
   Database: MySQL / Standard SQL
   ============================================================================ */


-- ----------------------------------------------------------------------------
-- Request 1: APAC Markets for 'Atliq Exclusive'
-- Business Question: Provide a list of markets in which customer "Atliq Exclusive" 
-- operates its business in the APAC region.
-- ----------------------------------------------------------------------------
SELECT DISTINCT 
    market
FROM dim_customer
WHERE customer = 'Atliq Exclusive'
  AND region = 'APAC'
ORDER BY market;


-- ----------------------------------------------------------------------------
-- Request 2: Unique Products Growth (2020 vs 2021)
-- Business Question: What is the percentage of unique product growth in 2021 
-- compared to 2020?
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END) AS unique_products_2020,
    COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN product_code END) AS unique_products_2021,
    ROUND(
        (
            SUM(CASE WHEN fiscal_year = 2021 THEN 1 ELSE 0 END) -
            SUM(CASE WHEN fiscal_year = 2020 THEN 1 ELSE 0 END)
        ) * 100.0 / SUM(CASE WHEN fiscal_year = 2020 THEN 1 ELSE 0 END),
        2
    ) AS percentage_chg
FROM (
    SELECT DISTINCT product_code, fiscal_year
    FROM fact_sales_monthly
    WHERE fiscal_year IN (2020, 2021)
) t;


-- ----------------------------------------------------------------------------
-- Request 3: Segment-wise Product Count
-- Business Question: Provide a report showing unique product counts for each 
-- segment, sorted in descending order.
-- ----------------------------------------------------------------------------
SELECT 
    segment,
    COUNT(DISTINCT product) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;


-- ----------------------------------------------------------------------------
-- Request 4: Segment with Highest Increase in Unique Products (2020 to 2021)
-- Business Question: Which segment had the highest increase in unique products 
-- in 2021 compared to 2020?
-- ----------------------------------------------------------------------------
SELECT 
    t1.segment,
    COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN t1.product END) AS r1,
    COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN t1.product END) AS r2,
    COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN t1.product END) - 
    COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN t1.product END) AS diffrence
FROM dim_product t1
JOIN fact_sales_monthly t2
    ON t1.product_code = t2.product_code
GROUP BY t1.segment
ORDER BY diffrence DESC 
LIMIT 1;


-- ----------------------------------------------------------------------------
-- Request 5: Highest and Lowest Manufacturing Cost Products
-- Business Question: Get the products with the highest and lowest manufacturing 
-- costs.
-- ----------------------------------------------------------------------------
WITH An AS (
    SELECT 
        t1.product_code,
        t2.product,
        t1.manufacturing_cost,
        ROW_NUMBER() OVER (ORDER BY manufacturing_cost DESC) AS high,
        ROW_NUMBER() OVER (ORDER BY manufacturing_cost ASC) AS low
    FROM fact_manufacturing_cost t1
    JOIN dim_product t2
        ON t1.product_code = t2.product_code
)
SELECT 
    product_code,
    product,
    manufacturing_cost
FROM An
WHERE high = 1 OR low = 1;


-- ----------------------------------------------------------------------------
-- Request 6: Top 5 Customers in India by Pre-Invoice Discount (2021)
-- Business Question: Generate a report of top 5 customers in India who received 
-- the highest average pre-invoice discount % for fiscal year 2021.
-- ----------------------------------------------------------------------------
SELECT 
    t1.customer_code,
    t2.customer,
    AVG(t1.pre_invoice_discount_pct) AS average_invoice 
FROM fact_pre_invoice_deductions t1
JOIN dim_customer t2
    ON t1.customer_code = t2.customer_code
WHERE t1.fiscal_year = 2021 
  AND t2.market = 'India'
GROUP BY t1.customer_code, t2.customer
ORDER BY average_invoice DESC 
LIMIT 5;


-- ----------------------------------------------------------------------------
-- Request 7: Monthly Gross Sales for 'Atliq Exclusive'
-- Business Question: Get the monthly gross sales report for 'Atliq Exclusive' 
-- to analyze high and low sales months.
-- ----------------------------------------------------------------------------
SELECT 
    MONTH(t2.date) AS month_no,
    MONTHNAME(t2.date) AS Month_wise,
    t2.fiscal_year AS year_wise,
    ROUND(SUM(t2.sold_quantity * t3.gross_price), 2) AS gross_sale
FROM dim_customer t1
JOIN fact_sales_monthly t2
    ON t1.customer_code = t2.customer_code
JOIN fact_gross_price t3
    ON t2.product_code = t3.product_code
   AND t2.fiscal_year = t3.fiscal_year
WHERE t1.customer = 'Atliq Exclusive'
GROUP BY 
    MONTH(t2.date),
    MONTHNAME(t2.date),
    t2.fiscal_year
ORDER BY 
    t2.fiscal_year,
    month_no;


-- ----------------------------------------------------------------------------
-- Request 8: Quarter with Highest Quantity Sold in FY 2020
-- Business Question: In which quarter of 2020 was the highest total quantity 
-- sold? (AtliQ's fiscal year starts in September).
-- ----------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN MONTH(date) IN (9,10,11) THEN 'Q1'
        WHEN MONTH(date) IN (12,1,2) THEN 'Q2'
        WHEN MONTH(date) IN (3,4,5) THEN 'Q3'
        ELSE 'Q4'
    END AS fiscal_quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
WHERE fiscal_year = 2020
GROUP BY fiscal_quarter
ORDER BY total_sold_quantity DESC
LIMIT 1;


-- ----------------------------------------------------------------------------
-- Request 9: Gross Sales & Contribution % by Channel (FY 2021)
-- Business Question: Which channel brought the most gross sales in FY 2021, and 
-- what is its percentage contribution?
-- ----------------------------------------------------------------------------
SELECT 
    t1.channel,
    ROUND(SUM(t2.sold_quantity * t3.gross_price) / 1000000, 2) AS gross_sales_mln,
    ROUND(
        SUM(t2.sold_quantity * t3.gross_price) / 
        SUM(SUM(t2.sold_quantity * t3.gross_price)) OVER () * 100, 
        2
    ) AS percentage
FROM dim_customer t1
JOIN fact_sales_monthly t2
    ON t1.customer_code = t2.customer_code
JOIN fact_gross_price t3
    ON t2.product_code = t3.product_code
   AND t2.fiscal_year = t3.fiscal_year
WHERE t2.fiscal_year = 2021
GROUP BY t1.channel
ORDER BY SUM(t2.sold_quantity * t3.gross_price) DESC;


-- ----------------------------------------------------------------------------
-- Request 10: Top 3 Sold Products per Division by Quantity (FY 2021)
-- Business Question: Get the top 3 products in each division by total sold 
-- quantity in FY 2021.
-- ----------------------------------------------------------------------------
WITH An AS (
    SELECT 
        t1.division,
        t1.product_code,
        t1.product,
        SUM(sold_quantity) AS total_sold 
    FROM dim_product t1
    JOIN fact_sales_monthly t2
        ON t1.product_code = t2.product_code
    WHERE t2.fiscal_year = 2021
    GROUP BY 
        t1.division,
        t1.product_code,
        t1.product
)
SELECT *
FROM (
    SELECT 
        division,
        product_code,
        product,
        total_sold,
        DENSE_RANK() OVER (
            PARTITION BY division
            ORDER BY total_sold DESC
        ) AS dnk
    FROM An
) ranked
WHERE dnk <= 3;