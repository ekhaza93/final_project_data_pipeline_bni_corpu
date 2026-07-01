-- 01_transform.sql
-- Transform stg_branches -> dim_branch
-- Cast tipe data + hitung kolom turunan: branch_age_years

TRUNCATE TABLE dim_branch;

INSERT INTO dim_branch (
    branch_id,
    branch_code,
    branch_name,
    city,
    province,
    region,
    branch_type,
    open_date,
    is_active,
    branch_age_years
)
SELECT
    branch_id,
    branch_code,
    branch_name,
    city,
    province,
    region,
    branch_type,
    open_date::DATE                                              AS open_date,

    -- is_active: TRUE kalau kolom bernilai 'True'
    CASE WHEN LOWER(is_active) = 'true' THEN TRUE ELSE FALSE END AS is_active,

    -- branch_age_years: umur cabang dari open_date sampai hari ini
    DATE_PART('year', AGE(CURRENT_DATE, open_date::DATE))::SMALLINT AS branch_age_years
FROM stg_branches
WHERE branch_id IS NOT NULL
ON CONFLICT (branch_id) DO UPDATE SET
    branch_code       = EXCLUDED.branch_code,
    branch_name       = EXCLUDED.branch_name,
    city              = EXCLUDED.city,
    province          = EXCLUDED.province,
    region            = EXCLUDED.region,
    branch_type       = EXCLUDED.branch_type,
    open_date         = EXCLUDED.open_date,
    is_active         = EXCLUDED.is_active,
    branch_age_years  = EXCLUDED.branch_age_years,
    etl_loaded_at     = NOW();
