-- 04_channel_analysis.sql
-- Pertanyaan: Channel apa yang paling banyak digunakan nasabah
--             (ATM, Mobile, Teller, Internet Banking)?
--             Bagaimana tren migrasi ke digital?
-- Tables: dim_channel, dim_date, fact_transactions

-- (A) Penggunaan per channel (jumlah & nilai transaksi)
SELECT
    ch.channel_name,
    ch.channel_category,
    ch.is_digital,
    COUNT(f.transaction_id)   AS transaction_count,
    SUM(f.amount)             AS total_transaction_value
FROM fact_transactions f
JOIN dim_channel ch ON f.channel_id = ch.channel_id
GROUP BY ch.channel_name, ch.channel_category, ch.is_digital
ORDER BY transaction_count DESC;

-- (B) Tren migrasi digital vs non-digital per tahun (jumlah transaksi & share %)
SELECT
    d.year,
    ch.is_digital,
    COUNT(f.transaction_id) AS transaction_count,
    ROUND(
        100.0 * COUNT(f.transaction_id)
        / SUM(COUNT(f.transaction_id)) OVER (PARTITION BY d.year)
    , 2)                                                       AS pct_of_year
FROM fact_transactions f
JOIN dim_channel ch ON f.channel_id = ch.channel_id
JOIN dim_date d     ON f.transaction_date = d.full_date
GROUP BY d.year, ch.is_digital
ORDER BY d.year, ch.is_digital;

-- (C) Tren migrasi digital per bulan (untuk melihat kecepatan pergeseran)
SELECT
    d.year,
    d.month,
    d.month_name,
    ch.is_digital,
    COUNT(f.transaction_id) AS transaction_count,
    ROUND(
        100.0 * COUNT(f.transaction_id)
        / SUM(COUNT(f.transaction_id)) OVER (PARTITION BY d.year, d.month)
    , 2)                                                       AS pct_of_month
FROM fact_transactions f
JOIN dim_channel ch ON f.channel_id = ch.channel_id
JOIN dim_date d     ON f.transaction_date = d.full_date
GROUP BY d.year, d.month, d.month_name, ch.is_digital
ORDER BY d.year, d.month, ch.is_digital;
