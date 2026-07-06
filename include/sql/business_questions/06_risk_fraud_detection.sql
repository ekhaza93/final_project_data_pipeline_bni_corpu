-- 06_risk_fraud_detection.sql
-- Pertanyaan: Adakah transaksi anomali (nilai sangat besar, frekuensi tidak wajar,
--             atau status FAILED berulang) yang perlu diwaspadai?
-- Tables: dim_customer, dim_channel, fact_transactions

-- (A) Transaksi dengan nilai sangat besar (di atas persentil-95 seluruh transaksi)
WITH stats AS (
    SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY amount) AS p95_amount
    FROM fact_transactions
)
SELECT
    f.transaction_id,
    f.transaction_code,
    c.full_name,
    c.segment,
    ch.channel_name,
    f.amount,
    f.status,
    f.transaction_at
FROM fact_transactions f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_channel ch ON f.channel_id = ch.channel_id
CROSS JOIN stats s
WHERE f.amount > s.p95_amount
ORDER BY f.amount DESC;

-- (B) Frekuensi transaksi tidak wajar: nasabah dengan >10 transaksi dalam satu hari
SELECT
    c.customer_id,
    c.full_name,
    c.segment,
    f.transaction_date,
    COUNT(f.transaction_id) AS daily_transaction_count,
    SUM(f.amount) AS daily_total_value
FROM fact_transactions f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name, c.segment, f.transaction_date
HAVING COUNT(f.transaction_id) > 10
ORDER BY daily_transaction_count DESC;

-- (C) Status FAILED berulang: nasabah/channel dengan >=3 transaksi gagal
SELECT
    c.customer_id,
    c.full_name,
    c.segment,
    ch.channel_name,
    COUNT(f.transaction_id) AS failed_count
FROM fact_transactions f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_channel ch ON f.channel_id = ch.channel_id
WHERE f.status = 'FAILED'
GROUP BY c.customer_id, c.full_name, c.segment, ch.channel_name
HAVING COUNT(f.transaction_id) >= 3
ORDER BY failed_count DESC;

-- (D) Ringkasan skor risiko per nasabah: gabungan nilai besar + frekuensi + FAILED
--     (skor sederhana, bukan model ML — untuk watchlist awal)
WITH stats AS (
    SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY amount) AS p95_amount
    FROM fact_transactions
),
per_customer AS (
    SELECT
        f.customer_id,
        COUNT(f.transaction_id) AS total_transactions,
        COUNT(f.transaction_id) FILTER (WHERE f.amount > s.p95_amount) AS large_amount_count,
        COUNT(f.transaction_id) FILTER (WHERE f.status = 'FAILED') AS failed_count
    FROM fact_transactions f
    CROSS JOIN stats s
    GROUP BY f.customer_id
)
SELECT
    c.customer_id,
    c.full_name,
    c.segment,
    p.total_transactions,
    p.large_amount_count,
    p.failed_count,
    (p.large_amount_count * 3 + p.failed_count * 2) AS risk_score
FROM per_customer p
JOIN dim_customer c ON p.customer_id = c.customer_id
WHERE p.large_amount_count > 0 OR p.failed_count >= 3
ORDER BY risk_score DESC
LIMIT 50;
