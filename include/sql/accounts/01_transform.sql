-- 01_transform.sql
-- Transform stg_accounts -> dim_accounts
-- Cast tipe data + hitung kolom turunan: account_age_years, is_closed, interest_rate_segment

TRUNCATE TABLE dim_accounts;

INSERT INTO dim_accounts (
    account_id,
    account_no,
    account_type,
    product_name,
    currency,
    open_date,
    close_date,
    status,
    interest_rate,
    customer_id,
    branch_id,
    account_age_years,
    is_closed,
    interest_rate_segment
)
SELECT
    account_id,
    account_no,
    account_type,
    product_name,
    currency,
    open_date::DATE                                             AS open_date,
    NULLIF(close_date, '')::DATE                                 AS close_date,
    status,
    interest_rate,
    customer_id,
    branch_id,

    -- account_age_years: umur akun dari open_date sampai close_date (kalau sudah tutup)
    -- atau sampai hari ini (kalau masih aktif/dormant)
    DATE_PART(
        'year',
        AGE(COALESCE(NULLIF(close_date, '')::DATE, CURRENT_DATE), open_date::DATE)
    )::SMALLINT                                                  AS account_age_years,

    -- is_closed: TRUE kalau status CLOSED
    (status = 'CLOSED')                                          AS is_closed,

    -- interest_rate_segment: kategori suku bunga
    CASE
        WHEN interest_rate IS NULL                       THEN NULL
        WHEN interest_rate < 2.5                          THEN 'Low'
        WHEN interest_rate BETWEEN 2.5 AND 5.0            THEN 'Medium'
        WHEN interest_rate BETWEEN 5.01 AND 7.0           THEN 'High'
        ELSE 'Very High'
    END                                                          AS interest_rate_segment
FROM stg_accounts
WHERE account_id IS NOT NULL
ON CONFLICT (account_id) DO UPDATE SET
    account_no             = EXCLUDED.account_no,
    account_type           = EXCLUDED.account_type,
    product_name           = EXCLUDED.product_name,
    currency                = EXCLUDED.currency,
    open_date               = EXCLUDED.open_date,
    close_date               = EXCLUDED.close_date,
    status                   = EXCLUDED.status,
    interest_rate            = EXCLUDED.interest_rate,
    customer_id              = EXCLUDED.customer_id,
    branch_id                = EXCLUDED.branch_id,
    account_age_years        = EXCLUDED.account_age_years,
    is_closed                = EXCLUDED.is_closed,
    interest_rate_segment    = EXCLUDED.interest_rate_segment,
    etl_loaded_at             = NOW();