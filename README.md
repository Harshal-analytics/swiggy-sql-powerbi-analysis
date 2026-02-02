# Swiggy Sales & Performance Analysis Dashboard

# Project Overview
This project analyzes Swiggy order data using **SQL-based ETL, star schema data modeling, and Power BI dashboards** to derive actionable business insights.  
It demonstrates end-to-end **data analytics workflow**, including data extraction, transformation, loading, KPI calculation, and visualization.

---

# Tools & Technologies Used
- **SQL** (MySQL / SQL Server) – for data cleaning, ETL, and KPI queries
- **Power BI** – for creating interactive dashboards
- **DAX** – for dynamic KPI measures
- **Star Schema** – fact and dimension table modeling

---

# ETL Process
1. **Extract:** Raw dataset imported into SQL tables (`raw_orders` etc.)
2. **Transform:** Data cleaned, duplicates removed, derived columns created (order value groups, rating groups, etc.)
3. **Load:** Dimension tables (`dim_customer`, `dim_restaurant`, `dim_location`, `dim_category`, `dim_dish`) and `fact_orders` populated with clean data and foreign keys.

> ETL ensures data integrity, consistency, and readiness for dashboard visualization.

---

# Data Model
- **Fact Table:** `fact_orders` – contains order-level metrics such as order amount, quantity, rating, delivery time.
- **Dimension Tables:**  
  - `dim_customer` – customer details  
  - `dim_restaurant` – restaurant details  
  - `dim_location` – geographic info  
  - `dim_category` – cuisine/category info  
  - `dim_dish` – dish-level info  

This is a **star schema model** enabling multi-dimensional analysis.

---

# Key KPIs
- Total Orders  
- Total Revenue  
- Average Order Value (AOV)  
- Average Customer Rating  
- Revenue & Orders by City  
- Top Restaurants & Top Selling Dishes  
- Category-wise Performance 
