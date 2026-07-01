-- 01_transform.sql
-- Transform stg_fraud_labels -> fact_fraud_labels
-- Cast tipe data + hitung kolom turunan: fraud_risk_level

TRUNCATE TABLE fact_fraud_labels;

INSERT INTO fact_fraud_labels (
    transaction_id,
    transaction_code,
    is_fraud,
    fraud_type,
    fraud_score,
    flagged_at,
    fraud_risk_level
)
SELECT
    transaction_id,
    transaction_code,

    -- is_fraud: TRUE kalau kolom bernilai 'True'
    CASE WHEN LOWER(is_fraud) = 'true' THEN TRUE ELSE FALSE END AS is_fraud,

    fraud_type,
    fraud_score,
    flagged_at::TIMESTAMP                                        AS flagged_at,

    -- fraud_risk_level: kategori berdasarkan fraud_score
    CASE
        WHEN fraud_score IS NULL          THEN NULL
        WHEN fraud_score < 0.25            THEN 'Low'
        WHEN fraud_score < 0.50            THEN 'Medium'
        WHEN fraud_score < 0.75            THEN 'High'
        ELSE 'Critical'
    END                                                            AS fraud_risk_level
FROM stg_fraud_labels
WHERE transaction_id IS NOT NULL
ON CONFLICT (transaction_id) DO UPDATE SET
    transaction_code   = EXCLUDED.transaction_code,
    is_fraud             = EXCLUDED.is_fraud,
    fraud_type            = EXCLUDED.fraud_type,
    fraud_score             = EXCLUDED.fraud_score,
    flagged_at                = EXCLUDED.flagged_at,
    fraud_risk_level            = EXCLUDED.fraud_risk_level,
    etl_loaded_at                 = NOW();
