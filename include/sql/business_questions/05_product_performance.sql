-- 05_product_performance.sql
-- Pertanyaan: Produk rekening mana (Tabungan/Giro/Deposito) yang menghasilkan
--             volume transaksi dan saldo rata-rata tertinggi?
-- Tables: dim_account, dim_date, fact_transactions

-- (A) Volume & nilai transaksi per tipe produk (account_type)
SELECT
    a.account_type,
    COUNT(f.transaction_id)          AS transaction_volume,
    SUM(f.amount)                    AS total_transaction_value,
    ROUND(AVG(f.balance_after), 2)   AS avg_balance
FROM fact_transactions f
JOIN dim_account a ON f.account_id = a.account_id
GROUP BY a.account_type
ORDER BY transaction_volume DESC;

-- (B) Volume & nilai transaksi per produk detail (product_name)
SELECT
    a.account_type,
    a.product_name,
    COUNT(f.transaction_id)          AS transaction_volume,
    SUM(f.amount)                    AS total_transaction_value,
    ROUND(AVG(f.balance_after), 2)   AS avg_balance
FROM fact_transactions f
JOIN dim_account a ON f.account_id = a.account_id
GROUP BY a.account_type, a.product_name
ORDER BY transaction_volume DESC;

-- (C) Tren volume transaksi per tipe produk per tahun
SELECT
    d.year,
    a.account_type,
    COUNT(f.transaction_id) AS transaction_volume,
    SUM(f.amount)           AS total_transaction_value
FROM fact_transactions f
JOIN dim_account a ON f.account_id = a.account_id
JOIN dim_date d     ON f.transaction_date = d.full_date
GROUP BY d.year, a.account_type
ORDER BY d.year, transaction_volume DESC;

-- (D) Jumlah rekening aktif per tipe produk (konteks basis nasabah, dari dim_account)
SELECT
    account_type,
    COUNT(*) FILTER (WHERE status = 'ACTIVE') AS active_account_count,
    COUNT(*)                                  AS total_account_count,
    ROUND(AVG(interest_rate), 2)              AS avg_interest_rate
FROM dim_account
GROUP BY account_type
ORDER BY total_account_count DESC;
