/*
==============================================================================
DDL Scripts : Create Gold Views
===============================================================================
Script Purpose:
      This script creates views for the gold layer in the data warehouse
      The Gold layer represents the final dimension and fact tables (star schema)

      Each view performs transformations and combine data from the silver layer
      to produce a clean, enriched and business ready dataset.

Usage:
    -These views can be queried directly for analytics and reporting.
===================================================================================
*/

-- ==============================================================================
-- Create Dimensions : gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
   DROP VIEW gold.dim_customers;
GO 
CREATE VIEW gold.dim_customers AS
SELECT 
       ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
       cu.cst_id AS customer_id,
       cu.cst_key AS customer_number,
       cu.cst_firstname AS first_name,
       cu.cst_lastname AS last_name,
       cl.cntry AS country,
       cu.cst_marital_Status AS marital_status,
       CASE WHEN cst_gndr != 'n/a' THEN cst_gndr
            ELSE COALESCE(gen, 'n/a')
       END AS gender,
       ca.bdate AS birthdate,
       cu.cst_create_Date AS create_date      
FROM silver.crm_cust_info cu
LEFT JOIN silver.erp_cust_az12 ca
ON     cu.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 cl
ON     cu.cst_key  = cl.cid; 


-- ===================================================================================
-- Create Dimesions :gold.dim_products
-- ==================================================================================
IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
   DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
SELECT  
        ROW_NUMBER() OVER(ORDER BY pd.prd_start_dt, pd.prd_key) AS Product_key,
        pd.prd_id AS product_id,
        pd.prd_key AS product_number,
        pd.prd_nm AS product_name,
        pd.cat_id AS category_id,
        pc.cat AS category,
        pc.subcat AS subcategory,
        pc.maintenance,
        pd.prd_cost AS product_cost,
        pd.prd_line AS product_line,
        pd.prd_start_dt AS start_date
FROM silver.crm_prd_info pd
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON  pd.cat_id = pc.id
WHERE prd_end_dt IS NULL;

-- ================================================================================
-- Create Facts:gold.fact_sales
-- ===============================================================================
IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
  DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS 
SELECT sls_ord_num AS order_number,
       pr.product_number,
       cu.customer_id,
       sls_order_dt AS order_date,
       sls_ship_dt AS shipping_date,
       sls_due_dt AS due_date,
       sls_sales AS sales_amount,
       sls_quantity AS quantity,
       sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_customers cu
ON   cu.customer_id = sd.sls_cust_id
LEFT JOIN gold.dim_products pr
ON   sd.sls_prd_key = pr.product_number;


