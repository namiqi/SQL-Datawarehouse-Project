# Data Warehouse Project: Gold Layer Documentation
## Overview
#### The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension tables and fact tables specifically architected to provide a "Single Source of Truth."

#### By transforming raw technical data from CRM and ERP systems into a refined Star Schema, this layer ensures high performance, data integrity, and ease of use for Business Intelligence (BI) tools.

# Key Features of the Gold Layer:
Star Schema Design: Optimized for complex analytical queries and reporting.

**Surrogate Keys:** Implemented for reliable relationships and historical tracking (SCD Type 2).

**Data Harmonization:** Resolved cross-system formatting issues (e.g., matching hyphens to underscores).

**Business-Friendly Naming:** Standardized column names to ensure clarity for non-technical stakeholders.

---
## 1. gold.dim_customers

**Purpose:** This view provides a unified, cleaned, and enriched representation of customer data, integrating CRM info with geographic details from the ERP system.

| Column Name | Data Type | Description |
| --- | --- | --- |
| `customer_key` | INT | Surrogate key (Primary Key) generated via `ROW_NUMBER()` for the Star Schema. |
| `customer_id` | INT | Unique numerical identifier from the source CRM system. |
| `customer_number` | NVARCHAR | Alphanumeric business identifier used for tracking. |
| `first_name` | NVARCHAR | Customer's first name, cleaned and trimmed. |
| `last_name` | NVARCHAR | Customer's last name or family name. |
| `country` | NVARCHAR | Country of residence (mapped from ERP system). |
| `marital_status` | NVARCHAR | Marital status (e.g., Married, Single). |
| `gender` | NVARCHAR | Gender of the customer. |
| `birthdate` | DATE | Customer's date of birth. |
| `create_date` | DATETIME | Timestamp when the record was first created in the warehouse. |

---

## 2. gold.dim_products

**Purpose:** This view integrates product details from the CRM and Category hierarchies from the ERP system, ensuring data harmonization between different naming conventions.

| Column Name | Data Type | Description |
| --- | --- | --- |
| `product_key` | INT | Surrogate key (Primary Key) used for joining with the Fact Sales table. |
| `product_id` | INT | Original product ID from the CRM system. |
| `product_number` | NVARCHAR | Cleaned product code (removes prefixes used for category mapping). |
| `product_name` | NVARCHAR | Full descriptive name of the product. |
| `category_id` | NVARCHAR | Extracted identifier used to bridge CRM and ERP data. |
| `category` | NVARCHAR | Broadest product group (e.g., Accessories, Clothing). |
| `subcategory` | NVARCHAR | Specific product group (e.g., Helmets, Jerseys). |
| `maintenance` | NVARCHAR | Flag indicating if the product requires maintenance (Yes/No). |
| `product_cost` | DECIMAL | The cost of the product at the time of the active record. |
| `product_line` | NVARCHAR | The target market or category line for the product. |
| `start_date` | DATE | The date this version of the product became active. |

---

## 3. gold.fact_sales

**Purpose:** The central transaction table that links business metrics (sales, quantity) to the Dimension tables via Surrogate Keys.

| Column Name | Data Type | Description |
| --- | --- | --- |
| `order_number` | NVARCHAR | Unique identifier for the sales order. |
| `order_date` | DATE | The date the transaction occurred. |
| `shipping_date` | DATE | The date the product was shipped. |
| `due_date` | DATE | The date payment or delivery was due. |
| `customer_key` | INT | Foreign Key linking to `gold.dim_customers`. |
| `product_key` | INT | Foreign Key linking to `gold.dim_products`. |
| `sales_amount` | DECIMAL | Total revenue generated from the line item. |
| `quantity` | INT | Number of units sold. |
| `price` | DECIMAL | Unit price of the product at the time of sale. |

