-- 03_branch_performance.sql
-- Pertanyaan: Cabang mana yang memiliki performa tertinggi berdasarkan jumlah
--             transaksi dan total nilai transaksi per region?
-- Tables: dim_branch, dim_date, fact_transactions

-- (A) Performa semua cabang (jumlah transaksi & total nilai)
SELECT
    b.region,
    b.branch_id,
    b.branch_code,
    b.branch_name,
    COUNT(f.transaction_id) AS transaction_count,
    SUM(f.amount) AS total_transaction_value
FROM fact_transactions f
JOIN dim_branch b ON f.branch_id = b.branch_id
GROUP BY b.region, b.branch_id, b.branch_code, b.branch_name
ORDER BY total_transaction_value DESC;

-- (B) Ranking cabang per region (cabang terbaik di masing-masing region)
SELECT
    region,
    branch_id,
    branch_name,
    transaction_count,
    total_transaction_value,
    branch_rank
FROM (
    SELECT
        b.region,
        b.branch_id,
        b.branch_name,
        COUNT(f.transaction_id) AS transaction_count,
        SUM(f.amount) AS total_transaction_value,
        RANK() OVER (PARTITION BY b.region ORDER BY SUM(f.amount) DESC) AS branch_rank
    FROM fact_transactions f
    JOIN dim_branch b ON f.branch_id = b.branch_id
    GROUP BY b.region, b.branch_id, b.branch_name
) ranked
WHERE branch_rank = 1
ORDER BY total_transaction_value DESC;

-- (C) Tren performa cabang per tahun (pakai dim_date)
SELECT
    d.year,
    b.region,
    b.branch_id,
    b.branch_name,
    COUNT(f.transaction_id) AS transaction_count,
    SUM(f.amount) AS total_transaction_value
FROM fact_transactions f
JOIN dim_branch b ON f.branch_id = b.branch_id
JOIN dim_date d ON f.transaction_date = d.full_date
GROUP BY d.year, b.region, b.branch_id, b.branch_name
ORDER BY d.year, total_transaction_value DESC;

-- (D) Total performa per region
SELECT
    b.region,
    COUNT(DISTINCT b.branch_id) AS branch_count,
    COUNT(f.transaction_id) AS transaction_count,
    SUM(f.amount) AS total_transaction_value
FROM fact_transactions f
JOIN dim_branch b ON f.branch_id = b.branch_id
GROUP BY b.region
ORDER BY total_transaction_value DESC;
