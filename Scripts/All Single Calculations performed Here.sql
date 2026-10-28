-- Transforamtion of Bronze Layer into  Silver Layer 
-- Calculations and Transformations 

-- Clean and Load  crm_cust_info ( 01 Table )

SELECT * FROM crm_cust_info ;

--                                            Check for nulls or duplicates in primary key
SELECT 
	cst_id,
    COUNT(*) AS countall
FROM crm_cust_info
GROUP BY cst_id
HAVING countall > 1 OR cst_id IS NULL;

--                                           Check for unwanted spaces 
SELECT cst_firstname 
FROM crm_cust_info;

--                                           Cleaned Unwanted spaces
SELECT 
COUNT(cst_firstname)
FROM crm_cust_info 
WHERE cst_firstname != RTRIM(cst_firstname);

--                                           Check Data standardization & consistency
SELECT DISTINCT cst_gndr
FROM crm_cust_info;

 
--                                           Using Case Statement 
SELECT  
CASE 
	WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
    WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
    ELSE 'N/A'
    END AS marital_status
FROM crm_cust_info;

SELECT  
CASE 
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
    WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
    ELSE 'N/A'
    END AS customer_gender
FROM crm_cust_info;

-- ==============================================================================
-- ==============================================================================

-- Clean and load crm_prd_info ( 02 Table )
-- USE bronze

SELECT * FROM crm_prd_info;

SELECT 
	prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM crm_prd_info;

--                                          Check for nulls and duplicates in Primary Key
SELECT 
	prd_id,
    COUNT(*) AS countall
    FROM crm_prd_info
    GROUP BY prd_id
    HAVING countall > 1 OR prd_id IS NULL;

--                                         Spliting Column by using SUBSTRING

SELECT 
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id
FROM crm_prd_info;

SELECT 
	SUBSTRING(prd_key,7,LENGTH(prd_key)) AS prd_key
FROM crm_prd_info;

--                                              Checking the Unwanted Spaces in prd_nm

SELECT 
	prd_nm
FROM crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

--                                              Check for Null or Negative number in Prd_cost

SELECT 
	prd_cost
FROM crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL  ;



--                                              Check Data standardization & consistency

SELECT 
	prd_line
FROM crm_prd_info;

--                                            Using Case When Statement

SELECT 
	CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		 WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
         WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
         WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
         ELSE 'N/A'
	END AS prd_line
FROM crm_prd_info;

--                                   Validating Dates 

SELECT 
	prd_key,
	prd_start_dt,
    prd_end_dt,
    LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)  AS prd_end_dt_test
FROM crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R' , 'AC-HE-HL-U509');

-- ==============================================================================
-- ==============================================================================

-- Clean and load  cmr_sales_details ( 03 Table )
-- USE bronze
--                                            Checking the Quality of sales 
SELECT 
	sls_sales,
    sls_quantity,
    sls_price
FROM crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL  
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <= 0  
OR sls_quantity <= 0  
OR sls_price <= 0  
ORDER BY sls_sales, sls_quantity, sls_price;

--                                        Updating new query into sales 

SELECT 
    sls_sales AS old_sls_sales,
    -- Calculates sales safely, forcing absolute values for price
    CASE 
        WHEN sls_sales IS NULL 
             OR sls_sales <= 0 
             OR ROUND(sls_sales, 2) != ROUND(sls_quantity * ABS(sls_price), 2)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales_new,
    sls_quantity,
    -- Calculates price safely, preventing division by zero if quantity is 0
    CASE 
        WHEN sls_price IS NULL 
             OR sls_price <= 0 
             OR sls_quantity = 0
             OR ROUND(sls_price, 2) != ROUND(sls_sales / NULLIF(sls_quantity, 0), 2)
        THEN ABS(sls_sales / NULLIF(sls_quantity, 0))
        ELSE ABS(sls_price)
    END AS sls_price_new,
    sls_price AS old_sls_price
FROM crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL  
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <= 0  
OR sls_quantity <= 0  
OR sls_price <= 0  
ORDER BY sls_sales, sls_quantity, sls_price;


-- ==============================================================================
-- ==============================================================================

-- Clean and load  erp_cust_az12 ( 04 Table )
-- USE bronze
                                                 -- Altering CID 
SELECT 
	CID, 
    CASE 
    WHEN CID LIKE 'NAS%' 
    THEN SUBSTRING(CID,4,LENGTH(CID))
    ELSE CID
    END New_CID
FROM bronze.erp_cust_az12; 

										         -- Replacing NUll where BDate is Lessthen 1925 and greater then Current Date
SELECT
	BDATE,
    CASE 
		WHEN BDATE >= '1925' OR BDATE >= CURRENT_DATE() THEN NULL
        ELSE BDATE
        END AS BDATE02
FROM erp_cust_az12;

                                                 --  Standardizing Gender Column                                                 
SELECT DISTINCT GEN FROM erp_cust_az12;

SELECT DISTINCT
	GEN,
	CASE WHEN UPPER(TRIM(GEN)) = 'M' OR TRIM(GEN) = 'Male' OR 'Female' THEN 'Male'
    WHEN GEN = ' ' OR TRIM(GEN) = NULL THEN 'N/A' 
    ELSE 'Female'
    END GEN02
FROM erp_cust_az12;

-- ==============================================================================
-- ==============================================================================

-- Clean and Load  erp_loc_a101 ( 05 Table )

--                                                     Replacing - in CID  
SELECT 
REPLACE(CID,'-','') AS CID
FROM erp_loc_a101;
--                                                       Standardizing Country Column
SELECT DISTINCT
	CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
		 WHEN TRIM(CNTRY)  IN ('US' , 'USA') THEN 'United States'
         WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'N/A'
         ELSE TRIM(CNTRY) 
         END CNTRY
FROM erp_loc_a101
ORDER BY CNTRY;

-- ==============================================================================
-- ==============================================================================

-- Clean and Load  erp_px_cat_g1v2 ( 06 Table )

SELECT * FROM erp_px_cat_g1v2
WHERE ID NOT IN (SELECT cat_id FROM silver.crm_prd_info)



 








