-- 01_transform.sql
-- Transform stg_transactions -> fact_transactions
-- Cast tipe data + hitung kolom turunan: amount_segment, is_success

TRUNCATE TABLE fact_transactions;

INSERT INTO fact_transactions (
    transaction_id,
    transaction_code,
    account_id,
    customer_id,
    branch_id,
    channel_id,
    transaction_date,
    transaction_at,
    transaction_type,
    amount,
    balance_before,
    balance_after,
    status,
    reference_no,
    amount_segment,
    is_success
)
SELECT
    transaction_id,
    transaction_code,
    account_id,
    customer_id,
    branch_id,
    channel_id,
    transaction_date::DATE                                       AS transaction_date,
    transaction_at::TIMESTAMP                                    AS transaction_at,
    transaction_type,
    amount,
    balance_before,
    balance_after,
    status,
    reference_no,

    -- amount_segment: kategori nominal transaksi
    CASE
        WHEN amount IS NULL              THEN NULL
        WHEN amount < 1000000             THEN 'Low'
        WHEN amount < 5000000             THEN 'Medium'
        WHEN amount < 20000000            THEN 'High'
        ELSE 'Very High'
    END                                                            AS amount_segment,

    -- is_success: TRUE kalau status SUCCESS
    (status = 'SUCCESS')                                          AS is_success
FROM stg_transactions
WHERE transaction_id IS NOT NULL
ON CONFLICT (transaction_id) DO UPDATE SET
    transaction_code    = EXCLUDED.transaction_code,
    account_id           = EXCLUDED.account_id,
    customer_id           = EXCLUDED.customer_id,
    branch_id              = EXCLUDED.branch_id,
    channel_id              = EXCLUDED.channel_id,
    transaction_date         = EXCLUDED.transaction_date,
    transaction_at            = EXCLUDED.transaction_at,
    transaction_type           = EXCLUDED.transaction_type,
    amount                       = EXCLUDED.amount,
    balance_before                = EXCLUDED.balance_before,
    balance_after                  = EXCLUDED.balance_after,
    status                          = EXCLUDED.status,
    reference_no                     = EXCLUDED.reference_no,
    amount_segment                    = EXCLUDED.amount_segment,
    is_success                         = EXCLUDED.is_success,
    etl_loaded_at                       = NOW();
