-- 02_customer_360.sql
-- Pertanyaan: Siapa nasabah paling aktif berdasarkan frekuensi dan nilai transaksi?
--             Bagaimana distribusi per segmen (Retail/Priority/VIP)?
-- Tables: dim_customer, dim_account, fact_transactions

-- (A) Top 20 nasabah paling aktif (frekuensi & nilai transaksi)
SELECT
    c.customer_id,
    c.customer_code,
    c.full_name,
    c.segment,
    COUNT(f.transaction_id)   AS transaction_frequency,
    SUM(f.amount)             AS total_transaction_value,
    ROUND(AVG(f.amount), 2)   AS avg_transaction_value
FROM fact_transactions f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_code, c.full_name, c.segment
ORDER BY transaction_frequency DESC, total_transaction_value DESC
LIMIT 20;

-- (B) Distribusi aktivitas transaksi per segmen nasabah
SELECT
    c.segment,
    COUNT(DISTINCT c.customer_id)                            AS customer_count,
    COUNT(f.transaction_id)                                  AS total_transactions,
    SUM(f.amount)                                             AS total_transaction_value,
    ROUND(AVG(f.amount), 2)                                   AS avg_transaction_value,
    ROUND(COUNT(f.transaction_id)::NUMERIC
          / NULLIF(COUNT(DISTINCT c.customer_id), 0), 2)      AS avg_transaction_per_customer
FROM dim_customer c
LEFT JOIN fact_transactions f ON f.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY total_transaction_value DESC;

-- (C) Distribusi jumlah & saldo rekening per segmen nasabah (pakai dim_account)
SELECT
    c.segment,
    COUNT(DISTINCT a.account_id)         AS total_accounts,
    ROUND(AVG(a.interest_rate), 2)       AS avg_interest_rate,
    SUM(f.amount)                        AS total_transaction_value
FROM dim_customer c
JOIN dim_account a       ON a.customer_id = c.customer_id
LEFT JOIN fact_transactions f ON f.account_id = a.account_id
GROUP BY c.segment
ORDER BY total_transaction_value DESC;
