-- 01_transform.sql
-- Transform stg_channels -> dim_channels
-- Cast tipe data

TRUNCATE TABLE dim_channels;

INSERT INTO dim_channels (
    channel_id,
    channel_code,
    channel_name,
    channel_category,
    is_digital,
    description
)
SELECT
    channel_id,
    channel_code,
    channel_name,
    channel_category,

    -- is_digital: TRUE kalau kolom bernilai 'True'
    CASE WHEN LOWER(is_digital) = 'true' THEN TRUE ELSE FALSE END AS is_digital,

    description
FROM stg_channels
WHERE channel_id IS NOT NULL
ON CONFLICT (channel_id) DO UPDATE SET
    channel_code      = EXCLUDED.channel_code,
    channel_name      = EXCLUDED.channel_name,
    channel_category  = EXCLUDED.channel_category,
    is_digital        = EXCLUDED.is_digital,
    description       = EXCLUDED.description,
    etl_loaded_at      = NOW();
