
# ==============================================================================================
-- Bronze_Layer ( Here all Transformation and Calculations are done, Before Inserting into Silver_Layer ) 
-- All Six Tables are Transformed 
# ==============================================================================================

-- Final Bronze layer Transforamtion into Silver Layer before inserting Table (crm_cust_info) 

SELECT 
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname, -- Trimming spaces 
TRIM(cst_lastname) AS cst_lastname,
CASE 
	WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' -- Standardizing values 
    WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
    ELSE 'N/A'  -- Handling Missing values , setting 
END
cst_marital_status,
CASE 
	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
    WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
    ELSE 'N/A'
END
cst_gndr,
cst_create_date,
flag_last
FROM (
SELECT 
	*,
    ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
)t 

# ==============================================================================================

-- Final Bronze layer Transforamtion into Silver Layer before inserting Table (crm_prd_info)

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
FROM bronze.crm_prd_info;

# ==============================================================================================

-- Final Bronze layer Transforamtion into Silver Layer before inserting Table (crm_sales_details)

SELECT * FROM crm_sales_details;

SELECT 
	sls_ord_num,  -- No need to Transform
    sls_prd_key,  -- All sls_prd_key can be connected to crm_prd_key
    sls_cust_id,  -- All sls_cust_id in crm_cust_info, No need to change
    sls_order_dt, -- Already changed in MS Excel
    sls_ship_dt,  -- Already changed in MS Excel
    sls_due_dt,  -- Already changed in MS Excel
    sls_sales,  -- Need to change 
    sls_quantity, -- No need to change 
    sls_price -- Need to change 
FROM crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

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
FROM bronze.crm_sales_details; 

# ==============================================================================================

--  Final Bronze layer Transforamtion into Silver Layer before inserting Table (erp_cust_az12)

SELECT * FROM erp_cust_az12;

SELECT 
	CID, -- Need to chnage (Remove NAS% before ever CID , to connect with cmr_cust_info)
    BDATE, -- Need to Transform cause some Bdate is very Old like 1924
    GEN -- Standardization needed As columns contains ( F, M, Male, Female, NULL, ' ' )
FROM erp_cust_az12;

SELECT 
	CASE 
		WHEN CID LIKE 'NAS%' 
		THEN SUBSTRING(CID,4,LENGTH(CID))
		ELSE CID
	END CID,
    CASE 
		WHEN BDATE >= '1925' OR BDATE >= CURRENT_DATE() THEN NULL
        ELSE BDATE
	END AS BDATE,
	CASE 
		WHEN UPPER(TRIM(GEN)) = 'M' OR TRIM(GEN) = 'Male' OR 'Female' THEN 'Male'
		WHEN GEN = ' ' OR TRIM(GEN) = NULL THEN 'N/A' 
		ELSE 'Female'
    END GEN
FROM erp_cust_az12
WHERE GEN = 'Male';

SELECT * FROM erp_cust_az12
WHERE BDATE = '06-10-1971';

# ==============================================================================================

--  Final Bronze layer Transforamtion into Silver Layer before inserting Table (erp_loc_a101)

SELECT * FROM erp_loc_a101;

SELECT 
	CID, -- Need to Change Cause - in Between of CID 
    CNTRY -- Need to Standardize Country Names 
FROM erp_loc_a101;

SELECT 
REPLACE(CID,'-','') AS CID,
CASE 
	WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
	WHEN TRIM(CNTRY)  IN ('US' , 'USA') THEN 'United States'
    WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'N/A'
    ELSE TRIM(CNTRY) 
END CNTRY
FROM erp_loc_a101;

# ==============================================================================================

--  Final Bronze layer Transforamtion into Silver Layer before inserting Table (erp_px_cat_g1v2)

-- In this Table all Columns are clean and meet the Standards

-- SO I am directly inserting it in Silver Layer 

# ==============================================================================================

-- All Insering will Happen in Silver_Layer 
-- Refere Silver_Layer File to see the complete Process






