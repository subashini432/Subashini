# Sales Analysis Portfolio - Project Overview

## 1. Project Objective
The purpose of this project is to perform a complete **sales data analysis** using Excel.  
Key goals:
- Clean and structure raw sales data  
- Analyze sales performance by region, product, and customer  
- Build interactive dashboards for visualization  
- Automate repetitive tasks using VBA  

---

## 2. Dataset
- File: `Dataset/sales_data.xlsx`  
- Contains the following columns:  
  - Order ID  
  - Customer Name  
  - Region  
  - Product Name  
  - Quantity  
  - Sales  
  - Profit  
  - Return Status  
  - Ship Mode  

> The dataset was used to demonstrate real-world sales analysis and reporting.

---

## 3. Data Preparation
Steps performed before analysis:
1. **Removed duplicates** and corrected inconsistent data entries  
2. **Standardized column names** and data formats  
3. **Created helper columns**:  
   - Return Status (`IF` + `XLOOKUP`)  
   - Manager mapping based on Region (`XLOOKUP`)  
   - Profit calculations (Sales – Cost)  

**Screenshot reference:**  
![Raw Data Structure](../images/01_raw_data_structure.png)  

---

## 4. Key Formulas & Functions Used
- **XLOOKUP / INDEX-MATCH** → Lookup manager names, return status  
- **IF / IFERROR / Nested IFs** → Conditional logic for returns and profit checks  
- **SUMIFS / COUNTIFS** → Aggregate data by region, product, and ship mode  
- **DATE functions** → Extract month, year for trend analysis  

**Screenshot reference:**  
![Manager XLOOKUP](../images/02_manager_xlookup.png)  
![Return Status Formula](../images/03_return_status_formula.png)  

---

## 5. Dashboards
Built **interactive dashboards** for key business insights:  
1. **Sales Overview** – Total sales and profit trends  
2. **Sales by Ship Mode** – Analysis of delivery methods  
3. **Top 5 States by Sales** – Highlight high-performing regions  
4. **Least 3 Products by Profit** – Identify low-performing products  
5. **Top 10 Cities by Sales** – City-level performance visualization  

**Screenshot references:**  
- ![Dashboard Overview](../images/04_dashboard_main.png)  
- ![Dashboard Ship Mode](../images/05_dashboard_shipmode.png)  
- ![Top 5 States](../images/06_dashboard_top5_states.png)  
- ![Least 3 Products](../images/07_dashboard_least3_products.png)  
- ![Top 10 Cities](../images/08_dashboard_top10_cities.png)  

---

## 6. Automation with VBA
- **Macros** were created to automate formatting and reporting tasks  
- **UserForms / Buttons** added for easy interaction with dashboards  

**Screenshot reference:**  
![VBA Automation](../images/09_vba_automation.png)  

---

## 7. Insights & Conclusions
- **Top-selling products** and **high-performing regions** identified  
- **Areas needing improvement** highlighted (low sales, low profit products)  
- Demonstrates ability to **handle end-to-end Excel projects**, from data cleaning to dashboards and automation  
- Suitable for showcasing skills as a **Data Analyst**  

---

> This project highlights advanced Excel skills, data modeling, dashboard creation, and automation using VBA — all essential for real-world data analysis.
