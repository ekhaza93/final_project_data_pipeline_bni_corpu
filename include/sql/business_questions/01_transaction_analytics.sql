-- 01_transaction_analytics.sql
-- Pertanyaan: Berapa total volume dan nilai transaksi per hari, minggu, dan bulan?
--             Apa tren pertumbuhannya?
-- Tables: dim_date, dim_channel, fact_transactions

-- (A) Volume & nilai transaksi per hari
SELECT
    d.full_date,
    COUNT(f.transaction_id)   AS transaction_volume,
    SUM(f.amount)             AS transaction_value
FROM fact_transactions f
JOIN dim_date d ON f.transaction_date = d.full_date
GROUP BY d.full_date
ORDER BY d.full_date;

-- (B) Volume & nilai transaksi per minggu
SELECT
    d.year,
    d.week_of_year,
    COUNT(f.transaction_id)   AS transaction_volume,
    SUM(f.amount)             AS transaction_value
FROM fact_transactions f
JOIN dim_date d ON f.transaction_date = d.full_date
GROUP BY d.year, d.week_of_year
ORDER BY d.year, d.week_of_year;

-- (C) Volume & nilai transaksi per bulan + tren pertumbuhan MoM (%)
WITH monthly AS (
    SELECT
        d.year,
        d.month,
        d.month_name,
        COUNT(f.transaction_id) AS transaction_volume,
        SUM(f.amount)           AS transaction_value
    FROM fact_transactions f
    JOIN dim_date d ON f.transaction_date = d.full_date
    GROUP BY d.year, d.month, d.month_name
)
SELECT
    year,
    month,
    month_name,
    transaction_volume,
    transaction_value,
    LAG(transaction_value) OVER (ORDER BY year, month)      AS prev_month_value,
    ROUND(
        (transaction_value - LAG(transaction_value) OVER (ORDER BY year, month))
        / NULLIF(LAG(transaction_value) OVER (ORDER BY year, month), 0) * 100
    , 2)                                                     AS mom_growth_pct
FROM monthly
ORDER BY year, month;

-- (D) Breakdown volume & nilai transaksi per bulan per channel (bonus: lihat kontribusi channel)
SELECT
    d.year,
    d.month,
    d.month_name,
    ch.channel_name,
    COUNT(f.transaction_id) AS transaction_volume,
    SUM(f.amount)           AS transaction_value
FROM fact_transactions f
JOIN dim_date d    ON f.transaction_date = d.full_date
JOIN dim_channel ch ON f.channel_id = ch.channel_id
GROUP BY d.year, d.month, d.month_name, ch.channel_name
ORDER BY d.year, d.month, transaction_value DESC;
