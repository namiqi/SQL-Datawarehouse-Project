# 📊 Data Warehouse Project: End-to-End Medallion Architecture

## 🚀 Overview

This project demonstrates the design and implementation of a professional-grade Data Warehouse using the **Medallion Architecture** (Bronze, Silver, Gold). Using SQL Server, I transformed raw, fragmented data from CRM and ERP systems into a clean, integrated **Star Schema** optimized for Business Intelligence and reporting.

---

## 🏗️ Data Architecture

The data follows a structured flow to ensure quality and reliability:

* **Bronze Layer:** Raw data ingestion from source systems (CRM & ERP).
* **Silver Layer:** Data cleaning, standardization (dates, currency), and handling of nulls.
* **Gold Layer:** Final business logic layer featuring Integrated Dimensions and a Fact table linked via Surrogate Keys.

<img width="1002" height="584" alt="chrome_UKSz5KyBQP" src="https://github.com/user-attachments/assets/63f7c77c-6dd4-453c-8f71-08957b736347" />


---

## 🛠️ Key Features & Solutions

During development, I solved several real-world data engineering challenges:

* **⚡ Star Schema Design:** Built a central `fact_sales` table surrounded by `dim_customers` and `dim_products`.
* **🔗 Data Harmonization:** Bridged disparate systems by fixing join keys (e.g., resolving hyphen vs. underscore mismatches between CRM and ERP data).
* **🔑 Surrogate Keys:** Implemented `ROW_NUMBER()` logic to create durable keys for the Data Warehouse, moving away from unstable business IDs.
* **🧼 Data Scrubbing:** Standardized naming conventions across all layers to ensure business-readiness.

---

## 📖 Data Dictionary (Gold Layer)

The following tables represent the final analytical output:

### 1️⃣ gold.dim_customers

| Column | Description |
| --- | --- |
| `customer_key` | **Surrogate Key** for the star schema. |
| `customer_id` | Original CRM identifier. |
| `country` | Integrated geographic data from ERP. |

### 2️⃣ gold.dim_products

| Column | Description |
| --- | --- |
| `product_key` | **Surrogate Key** for joining to Sales. |
| `category` | Product category (Integrated from ERP via Lookup). |

### 3️⃣ gold.fact_sales

| Column | Description |
| --- | --- |
| `order_number` | Unique transaction ID. |
| `sales_amount` | Primary measure for revenue analysis. |

---

## 💻 Tech Stack

* **Database:** SQL Server (T-SQL)
* **Design:** Miro (Architecture Mapping)
* **Documentation:** GitHub / Markdown
* **Modeling:** Star Schema / Dimensional Modeling

---

## 📈 Final Result

The result is a "Single Source of Truth" where sales performance can be analyzed instantly by customer demographics or product categories.

