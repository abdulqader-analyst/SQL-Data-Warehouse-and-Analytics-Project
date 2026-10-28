
# ==============================================================================================
-- Silver_Layer ( Here all Tables are Inserted from Bronze_Layer after Transformation done in Bronze_Layer) 
-- Contains all 6 Tables 
# ==============================================================================================

-- Inserting Cleaned Data into Silver Layer for crm_cust_info

CREATE TABLE silver.crm_cust_info(
cst_id int,
cst_key text, 
cst_firstname text,
cst_lastname text,
cst_marital_status text,
cst_gndr text,
cst_create_date text
);

INSERT INTO silver.crm_cust_info(
SELECT 
cst_id,
TRIM(cst_key),
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE 
	WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
    WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
    ELSE 'N/A'
END
cst_marital_status,
CASE 
	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
    WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
    ELSE 'N/A'
END
cst_gndr,
cst_create_date
FROM (
SELECT 
	*,
    ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
)t 
);

-- Checking If the Loaded into Silver_Layer without any Loss
SELECT * FROM silver.crm_cust_info;

# ==============================================================================================

-- Inserting Cleaned Data into Silver Layer for crm_prd_info

SELECT * FROM crm_prd_info;

CREATE TABLE silver.crm_prd_info(
prd_id int,
cat_id text,
prd_key text, 
prd_nm text,
prd_cost text,
prd_line text,
prd_start_dt text,
prd_end_dt text
);


INSERT INTO silver.crm_prd_info(
SELECT 
	prd_id,
    REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
    SUBSTRING(prd_key,7,LENGTH(prd_key)) AS prd_key,
    prd_nm,
    prd_cost,
    	CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		 WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
         WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
         WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
         ELSE 'N/A'
	END AS prd_line,
    prd_start_dt,
    LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS prd_end_dt
FROM bronze.crm_prd_info
);

-- Checking If the Loaded into Silver_Layer without any Loss
SELECT * FROM silver.crm_prd_info ORDER BY prd_id;

# ==============================================================================================

-- Inserting Cleaned Data into Silver Layer for crm_sales_details 

CREATE TABLE silver.crm_sales_details(
sls_ord_num text ,
sls_prd_key text ,
sls_cust_id int ,
sls_order_dt text ,
sls_ship_dt text ,
sls_due_dt text ,
sls_sales int ,
sls_quantity int ,
sls_price int );

INSERT INTO silver.crm_sales_details(
SELECT 
	sls_ord_num,  
    sls_prd_key,  
    sls_cust_id,  
    sls_order_dt,
    sls_ship_dt, 
    sls_due_dt,  
CASE 
	WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END sls_sales,  
    sls_quantity, 
CASE 
	WHEN sls_price IS NULL OR sls_price <= 0 OR sls_price != sls_sales / sls_quantity
    THEN ABS(sls_sales / sls_quantity)
	ELSE ABS(sls_price)
END sls_price
FROM bronze.crm_sales_details
);

-- Checking If the Loaded into Silver_Layer without any Loss
SELECT * FROM silver.crm_sales_details;

# ==============================================================================================

-- Inserting Cleaned Data into Silver Layer for erp_cust_az12

CREATE TABLE silver.erp_cust_az12(
	CID text, 
	BDATE text,
	GEN text
);


INSERT INTO silver.erp_cust_az12 (
SELECT 
	CASE 
		WHEN CID LIKE 'NAS%' 
		THEN SUBSTRING(CID,4,LENGTH(CID))
		ELSE CID
	END CID,
    CASE 
		WHEN BDATE <= '01-01-1925'  THEN NULL
        ELSE BDATE
	END AS BDATE,
	CASE 
		WHEN UPPER(TRIM(GEN)) = 'M' OR TRIM(GEN) = 'Male' THEN 'Male'
		WHEN GEN = ' ' OR TRIM(GEN) = NULL THEN 'N/A' 
		ELSE 'Female'
    END GEN
FROM bronze.erp_cust_az12
);

-- Checking If the Loaded into Silver_Layer without any Loss 
SELECT *  FROM silver.erp_cust_az12;

# ==============================================================================================

-- Inserting Cleaned Data into Silver Layer for erp_loc_a101

CREATE TABLE silver.erp_loc_a101(
	CID text,
    CNTRY text
);


INSERT INTO silver.erp_loc_a101(
SELECT 
REPLACE(CID,'-','') AS CID,
CASE 
	WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
	WHEN TRIM(CNTRY)  IN ('US' , 'USA') THEN 'United States'
    WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'N/A'
    ELSE TRIM(CNTRY) 
END CNTRY
FROM bronze.erp_loc_a101
);

-- Checking If the Loaded into Silver_Layer without any Loss 
SELECT * FROM silver.erp_loc_a101;

# ==============================================================================================

-- Inserting Cleaned Data into Silver Layer for erp_px_cat_g1v2

CREATE TABLE silver.erp_px_cat_g1v2(
	ID text,
	CAT text, 
	SUBCAT text, 
	MAINTENANCE text
);

INSERT INTO silver.erp_px_cat_g1v2(
 SELECT * FROM bronze.erp_px_cat_g1v2);

-- Checking If the Loaded into Silver_Layer without any Loss 
SELECT * FROM silver.erp_px_cat_g1v2

# ==============================================================================================