# 🛒 AtliQ Consumer Goods: Sales & Ad-Hoc Analytics Pipeline

**Tech Stack:** MySQL | Power BI | DAX | Power Query | Star Schema  
**Source File:** [`Atliq_Consumer_Goods_Sales_Analytics.pbix`](./Atliq_Consumer_Goods_Sales_Analytics.pbix) *(Download to view interactive model locally)*

---

## 📌 Executive Summary
Built an enterprise analytics solution analyzing **$1.7B in Net Sales** across global electronics channels. The project combines a 2-page Power BI executive dashboard with optimized MySQL queries solving 10 critical ad-hoc business requests.

---

## 💡 Key Technical Highlights
* **SQL Business Logic:** Engineered queries using CTEs, window functions (`DENSE_RANK`, `ROW_NUMBER`), conditional aggregation, and multi-table joins to analyze customer growth, segment trends, and quarterly sales.
* **Star Schema Data Model:** Modeled transactional sales logs (`fact_sales_monthly`) linked to core dimension tables (`dim_customer`, `dim_product`, `dim_market`).
* **Core Metrics Tracked:** Monitored **$1.7B Net Sales**, **61% Gross Margin**, **334 Products**, and **13.5% Peak Discount Rates**.
* **Margin Leakage Analysis:** Identified high-volume accounts taking excessive promotional discounts (e.g., Amazon) to protect recurring profit margins.

---

## 📜 SQL Ad-Hoc Analytics Scripts
View the complete SQL queries used for multi-year growth calculations, customer rankings, and product segment breakdowns:
* 📄 **[`queries.sql`](./queries.sql)** — Includes CTEs, window functions, and rank algorithms for executive request fulfillment.

---

## 📊 Power BI Dashboard Views

### 1. Enterprise Sales Performance
![Enterprise Sales Performance](./Enterprise_Sales_Performance.png)

### 2. Division & Margin Analysis
![Division and Margin Analysis](./Division_Margin_Analysis.png)
