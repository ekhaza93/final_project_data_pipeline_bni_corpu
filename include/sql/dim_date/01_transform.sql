-- 01_transform.sql
-- Transform stg_dim_date -> dim_date
-- Cast tipe data (full_date, is_weekend, is_holiday)

TRUNCATE TABLE dim_date;

INSERT INTO dim_date (
    date_id,
    full_date,
    year,
    quarter,
    month,
    month_name,
    week_of_year,
    day_of_month,
    day_of_week,
    day_name,
    is_weekend,
    is_holiday
)
SELECT
    date_id,
    full_date::DATE                                              AS full_date,
    year,
    quarter,
    month,
    month_name,
    week_of_year,
    day_of_month,
    day_of_week,
    day_name,
    CASE WHEN LOWER(is_weekend) = 'true' THEN TRUE ELSE FALSE END AS is_weekend,
    CASE WHEN LOWER(is_holiday) = 'true' THEN TRUE ELSE FALSE END AS is_holiday
FROM stg_dim_date
WHERE date_id IS NOT NULL
ON CONFLICT (date_id) DO UPDATE SET
    full_date       = EXCLUDED.full_date,
    year            = EXCLUDED.year,
    quarter         = EXCLUDED.quarter,
    month           = EXCLUDED.month,
    month_name      = EXCLUDED.month_name,
    week_of_year    = EXCLUDED.week_of_year,
    day_of_month    = EXCLUDED.day_of_month,
    day_of_week     = EXCLUDED.day_of_week,
    day_name        = EXCLUDED.day_name,
    is_weekend      = EXCLUDED.is_weekend,
    is_holiday      = EXCLUDED.is_holiday,
    etl_loaded_at   = NOW();
