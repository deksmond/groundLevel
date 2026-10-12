/*============================================================
                groundLevel - Data Analytics
==============================================================
Author       : Desmond Amama
Date         : 10/06/2026
Object Name  : investments_vc
Source file  : investments_VC.csv  (54,294 rows, 39 columns)
Purpose/Desc : Staging zone containing raw values
==============================================================
                a CHANGE HISTORY
==============================================================
Author       :
Date         :
Change       :
==============================================================
Author       :
Date         :
Change       :
==============================================================*/

USE groundLevel;
GO

-- Drop if re-running setup, for safe re-reuns
IF OBJECT_ID('stg.investments_vc', 'U') IS NOT NULL
    DROP TABLE stg.investments_vc;
GO

-- Create staging schema, if it doesn't exist
IF NOT EXISTS (SELECT 1
FROM sys.schemas
WHERE name = 'stg')
    EXEC('CREATE SCHEMA stg');
GO

CREATE TABLE stg.investments_vc
(

    stg_id INT IDENTITY(1,1) NOT NULL,
    permalink NVARCHAR(200) NULL,
    company_name NVARCHAR(200) NULL,
    homepage_url NVARCHAR(500) NULL,
    category_list NVARCHAR(500) NULL,
    market_raw NVARCHAR(100) NULL,
    status NVARCHAR(20) NULL,
    country_code NCHAR(3) NULL,
    state_code NCHAR(2) NULL,
    region NVARCHAR(100) NULL,
    city NVARCHAR(100) NULL,
    funding_total_usd_raw NVARCHAR(50) NULL,
    funding_rounds TINYINT NULL,
    founded_at_raw NVARCHAR(20) NULL,
    founded_month_raw NVARCHAR(10) NULL,
    founded_quarter_raw NVARCHAR(10) NULL,
    founded_year SMALLINT NULL,
    first_funding_at_raw NVARCHAR(20) NULL,
    last_funding_at_raw NVARCHAR(20) NULL,
    seed BIGINT NULL,
    venture BIGINT NULL,
    equity_crowdfunding BIGINT NULL,
    undisclosed BIGINT NULL,
    convertible_note BIGINT NULL,
    debt_financing BIGINT NULL,
    angel BIGINT NULL,
    grant_amount BIGINT NULL,
    private_equity BIGINT NULL,
    post_ipo_equity BIGINT NULL,
    post_ipo_debt BIGINT NULL,
    secondary_market BIGINT NULL,
    product_crowdfunding BIGINT NULL,
    round_A BIGINT NULL,
    round_B BIGINT NULL,
    round_C BIGINT NULL,
    round_D BIGINT NULL,
    round_E BIGINT NULL,
    round_F BIGINT NULL,
    round_G BIGINT NULL,
    round_H BIGINT NULL,

    -- ETL audit columns 
    -- These are added by the ETL process, not sourced from the file.
    src_file NVARCHAR(100) NOT NULL DEFAULT 'investments_VC.csv',
    stg_load_dt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    stg_is_valid BIT NOT NULL DEFAULT 1,
    -- set to 0 by error handler

    -- Constraints 
    CONSTRAINT PK_stg_investments_vc PRIMARY KEY CLUSTERED (stg_id)
);
GO

-- Indexes for transform-layer queries 
CREATE NONCLUSTERED INDEX stg_indx_inv_status
    ON stg.investments_vc (status)
    INCLUDE (stg_id, country_code, founded_year);
GO

-- Country + year (regional ecosystem queries)
CREATE NONCLUSTERED INDEX stg_indx_inv_country_year
    ON stg.investments_vc (country_code, founded_year)
    INCLUDE (status, funding_total_usd_raw);
GO

-- Valid rows only (used by transform layer to skip bad records)
CREATE NONCLUSTERED INDEX stg_indx_inv_valid
    ON stg.investments_vc (stg_is_valid)
    WHERE stg_is_valid = 1;
GO

-- Verification query (run after bulk load) 
/*
SELECT
    COUNT(*)                                        AS total_rows,
    SUM(CASE WHEN status       IS NULL THEN 1 END)  AS null_status,
    SUM(CASE WHEN country_code IS NULL THEN 1 END)  AS null_country,
    SUM(CASE WHEN founded_year IS NULL THEN 1 END)  AS null_founded_year,
    SUM(CASE WHEN stg_is_valid = 0     THEN 1 END)  AS invalid_rows,
    MIN(stg_load_dt),
    MAX(stg_load_dt)
FROM stg.investments_vc;

Expectation
*/