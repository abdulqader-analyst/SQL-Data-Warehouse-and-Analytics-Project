
# ==============================================================================================
-- Gold_Layer ( Creating Gold View and Gold_Layer for Dimensions and Facts ) 
-- PNG ( Gold_Layer_Data_Catalog ) is attached for description and Information about Dimensions and Facts
-- PNG ( Data_Model_Relationship ) is attached for relationship between Dimensions and Facts
# ==============================================================================================

# ==============================================================================================
-- SECTION 1 : GOLD VIEW 
# ==============================================================================================

# Creating Gold View for Customers Dimension

CREATE VIEW gold.dim_customers AS 
SELECT 
	ROW_NUMBER() OVER(ORDER BY cst_id) AS Customer_Key,
	CI.cst_id AS Customer_id,
    CI.cst_key AS Customer_number,
    CI.cst_firstname AS First_name,
    CI.cst_lastname AS Last_name,
    LO.CNTRY AS Country,
    CI.cst_marital_status AS Marital_status,
	CASE WHEN CI.cst_gndr != 'N/A' THEN CI.cst_gndr -- CRM is the Master for Gender Info
    ELSE COALESCE(CA.GEN, 'N/A') -- If ERP is Null Then will use 'N/A'
    END AS Gender,
	CA.BDATE AS Birth_date,
    CI.cst_create_date AS Create_date
FROM silver.crm_cust_info  AS CI
LEFT JOIN silver.erp_cust_az12 AS CA
ON CA.CID = CI.cst_key 
LEFT JOIN silver.erp_loc_a101 AS LO
ON CI.cst_key = LO.CID;

-- Checking if all Data Load in Gold View
SELECT * FROM gold.dim_customers;
# ==============================================================================================

# Creating Gold View for Products Dimensions 

CREATE VIEW gold.dim_products AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY PI.prd_start_dt, PI.prd_key ) AS Product_key,
	PI.prd_id AS Product_id,
	PI.prd_key AS Product_number,
    PI.prd_nm AS Product_name,
    PI.cat_id AS Category_id,
	PC.CAT AS Category,
    PC.SUBCAT AS Subcategory,
    PC.MAINTENANCE AS Maintenance,
    PI.prd_cost AS Product_cost,
    PI.prd_line AS Product_line,
    PI.prd_start_dt AS Start_date
FROM silver.crm_prd_info AS PI
LEFT JOIN silver.erp_px_cat_g1v2 AS PC
ON PI.cat_id = PC.ID
WHERE prd_end_dt IS NULL; -- Filter out all Historical Data 

-- Checking if all Data Load in Gold View
SELECT * FROM gold.dim_products;
# ==============================================================================================

# Creating Gold View for Sales_Details Fact

CREATE VIEW gold.facts_sales AS 
SELECT 
	SD.sls_ord_num AS Order_number,
    PR.Product_key, -- Using Product_key from gold.dim_products
    C.Customer_id, -- Using Product_key from gold.dim_customers
    SD.sls_order_dt AS Order_date,
    SD.sls_ship_dt AS Ship_date,
    SD.sls_due_dt AS Due_date,
    SD.sls_sales AS Sales_amount,
    SD.sls_quantity AS Quantity,
    SD.sls_price AS Price
FROM silver.crm_sales_details AS SD
LEFT JOIN gold.dim_products AS PR
ON SD.sls_prd_key = PR.Product_number
LEFT JOIN gold.dim_customers AS C
ON SD.sls_cust_id = C.Customer_id;

-- Checking if all Data Load in Gold View
SELECT * FROM gold.facts_sales;

# ==============================================================================================
# ==============================================================================================



# ==============================================================================================
-- SECTION 2 : GOLD LAYER
# ==============================================================================================

# Preparing Gold Layer (Customer)

# Joining Tables with Master Table (silver.crm_cust_info)
# Gave Friendly Colum Names 

SELECT 
	ROW_NUMBER() OVER(ORDER BY cst_id) AS Customer_Key,
	CI.cst_id AS Customer_id,
    CI.cst_key AS Customer_number,
    CI.cst_firstname AS First_name,
    CI.cst_lastname AS Last_name,
    LO.CNTRY AS Country,
    CI.cst_marital_status AS Marital_status,
	CASE WHEN CI.cst_gndr != 'N/A' THEN CI.cst_gndr -- CRM is the Master for Gender Info
    ELSE COALESCE(CA.GEN, 'N/A') -- If ERP is Null Then will use 'N/A'
    END AS Gender,
	CA.BDATE AS Birth_date,
    CI.cst_create_date AS Create_date
FROM silver.crm_cust_info  AS CI
LEFT JOIN silver.erp_cust_az12 AS CA
ON CA.CID = CI.cst_key 
LEFT JOIN silver.erp_loc_a101 AS LO
ON CI.cst_key = LO.CID;

# ===============================================================
# After Joining we have an Issue (Gender from both Tables) 
# (Q) - Which Table colum to Choose ?
# We do Data Integration here ( Refer to Data Integration File )
# ===============================================================

# Tables Used for Gold_Layer Dimension preparation 

SELECT * FROM silver.erp_cust_az12 LIMIT 10;

SELECT * FROM silver.crm_cust_info LIMIT 10;

SELECT * FROM silver.erp_loc_a101 LIMIT 10 ;

# ==============================================================================================

# Preparing Gold Layer (Products)

# Joining Tables with Master Table (silver.crm_prd_info)
# Gave Friendly Colum Names 

SELECT 
	ROW_NUMBER() OVER (ORDER BY PI.prd_start_dt, PI.prd_key ) AS Product_key,
	PI.prd_id AS Product_id,
	PI.prd_key AS Product_number,
    PI.prd_nm AS Product_name,
    PI.cat_id AS Category_id,
	PC.CAT AS Category,
    PC.SUBCAT AS Subcategory,
    PC.MAINTENANCE AS Maintenance,
    PI.prd_cost AS Product_cost,
    PI.prd_line AS Product_line,
    PI.prd_start_dt AS Start_date
FROM silver.crm_prd_info AS PI
LEFT JOIN silver.erp_px_cat_g1v2 AS PC
ON PI.cat_id = PC.ID
WHERE prd_end_dt IS NULL -- Filter out all Historical Data 
# ==========================================

# Tables Used for Gold_Layer Dimension preparation 

SELECT * FROM silver.crm_prd_info LIMIT 10;

SELECT * FROM silver.erp_px_cat_g1v2 LIMIT 10;

# ==============================================================================================

# Preparing Gold Layer (Sales_Details )

# Joining Tables with Master Table (silver.crm_prd_info)
# Gave Friendly Colum Names 

SELECT 
	SD.sls_ord_num AS Order_number,
    PR.Product_key,
    C.Customer_id,
    SD.sls_order_dt AS Order_date,
    SD.sls_ship_dt AS Ship_date,
    SD.sls_due_dt AS Due_date,
    SD.sls_sales AS Sales_amount,
    SD.sls_quantity AS Quantity,
    SD.sls_price AS Price
FROM silver.crm_sales_details AS SD
LEFT JOIN gold.dim_products AS PR
ON SD.sls_prd_key = PR.Product_number
LEFT JOIN gold.dim_customers AS C
ON SD.sls_cust_id = C.Customer_id;
# ======================================

# Tables Used for Gold_Layer Fact preparation 

SELECT * FROM silver.crm_sales_details;

# ==============================================================================================
# ==============================================================================================




















