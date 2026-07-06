# Final Project Data Pipeline — BNI Corpu

Repo ini berisi materi dan hands-on project **ETL Pipeline dengan Apache Airflow v3 + PostgreSQL** menggunakan Docker Compose.

---

## Persiapan Awal: Fork Repo Ini

> Lakukan fork agar punya salinan repo di akun GitHub masing-masing. Semua perubahan dan progress disimpan di fork milik sendiri.

### Langkah Fork

1. Buka halaman repo: [https://github.com/saipulrx/final_project_data_pipeline_bni_corpu](https://github.com/saipulrx/final_project_data_pipeline_bni_corpu)
2. Klik tombol **`Fork`** di pojok kanan atas
3. Pilih akun GitHub pribadi sebagai destination
4. Klik **`Create fork`**

Setelah fork berhasil, semua langkah selanjutnya dilakukan dari repo hasil fork di akun masing-masing (bukan repo asli).

---

## Struktur Repo

```
.
├── dags/                          # Airflow DAG files
│   ├── dag_etl_bank_transactions.py
│   ├── dag_el_churn.py
│   ├── dag_etl_customers.py
│   ├── dag_etl_accounts.py
│   ├── dag_etl_branches.py
│   ├── dag_etl_channels.py
│   ├── dag_etl_dim_date.py
│   ├── dag_etl_transactions.py
│   └── dag_etl_fraud_labels.py
├── include/
│   ├── dataset/                   # Source CSV files (generate dulu, lihat langkah 4)
│   ├── script/                    # Python ETL scripts
│   │   ├── generate_banking_dataset.py
│   │   └── etl_bank_transactions.py
│   └── sql/                       # SQL transform files & query analitik
│       ├── churn/
│       ├── customers/
│       ├── accounts/
│       ├── branches/
│       ├── channels/
│       ├── dim_date/
│       ├── transactions/
│       ├── fraud_labels/
│       └── business_questions/    # Query untuk menjawab pertanyaan bisnis
├── docker-compose.yaml
├── .env.example                   # Template environment variables
└── requirements.txt
```

---

## Cara Menjalankan di GitHub Codespace (Rekomendasi)

### 1. Buka Codespace

Di halaman **repo fork milik Anda**, klik tombol **`Code`** → tab **`Codespaces`** → **`Create codespace on main`**.

Tunggu hingga environment selesai di-setup (sekitar 1-2 menit).

### 2. Setup Environment Variables

```bash
cp .env.example .env
```

Edit file `.env` sesuai kebutuhan (password bisa dibiarkan default untuk development):

```bash
# Isi minimal ini:
AIRFLOW_UID=50000
```

### 3. Jalankan Docker Compose

```bash
# Fresh start (hapus volume lama jika ada)
docker compose down -v

# Start semua services
docker compose up -d
```

Tunggu semua container healthy (sekitar 1-2 menit):

```bash
docker compose ps
```

Semua service harus berstatus `healthy` atau `running`.

### 4. Generate Dataset

```bash
python include/script/generate_banking_dataset.py
```

Dataset akan tersimpan di `include/dataset/`.

### 5. Buka Airflow UI

Di panel **Ports** Codespace (tab bawah), cari port **`8082`** → klik ikon globe untuk buka di browser.

- **Username**: `airflow`
- **Password**: `airflow`

### 6. Setup Airflow Connection

Buka **Admin → Connections → `+`** lalu isi:

| Field | Value |
|---|---|
| Connection ID | `postgres_etl(bebas terserah anda)` |
| Connection Type | `Postgres` |
| Host | `<lihat host di akun neon anda>` |
| Database | `<lihat database di akun neon anda>` |
| Login | `<lihat username di akun neon anda>` |
| Password | `<lihat password di akun neon anda>` |
| Port | `5432` |

Klik **Save**.

### 7. Jalankan DAG

1. Buka halaman **DAGs**
2. Pilih DAG yang ingin dijalankan (misal: `dag_etl_customers`)
3. Klik tombol **▶ Trigger DAG**
4. Monitor eksekusi di tab **Graph** atau **Logs**

---

## Cara Menjalankan di Lokal (Docker Desktop)

### Prasyarat
- Docker Desktop terinstall dan berjalan
- Python 3.8+

### Langkah

```bash
# 1. Clone repo fork milik Anda (ganti YOUR_USERNAME)
git clone https://github.com/YOUR_USERNAME/final_project_data_pipeline_bni_corpu.git
cd final_project_data_pipeline_bni_corpu

# 2. Setup env
cp .env.example .env
# Edit .env jika perlu (ETL_POSTGRES_HOST=localhost, ETL_POSTGRES_PORT=5433)

# 3. Jalankan
docker compose up -d

# 4. Generate dataset
python include/script/generate_banking_dataset.py

# 5. Buka Airflow di browser
open http://localhost:8082
```

---

## DAGs yang Tersedia

| DAG ID | Source | Destination | Keterangan |
|---|---|---|---|
| `dag_etl_bank_transactions` | `bank_transactions_data_2.csv` | `trx_sample` | ETL transaksi bank |
| `dag_el_churn` | `churn.csv` | `churn_clean` | EL + transform data churn |
| `dag_etl_customers` | `customers.csv` | `dim_customer` | ETL dimensi customer |
| `dag_etl_accounts` | `accounts.csv` | `dim_account` | ETL dimensi account |
| `dag_etl_branches` | `branches.csv` | `dim_branch` | ETL dimensi branch |
| `dag_etl_channels` | `channels.csv` | `dim_channel` | ETL dimensi channel |
| `dag_etl_dim_date` | `dim_date.csv` | `dim_date` | ETL dimensi date |
| `dag_etl_transactions` | `transactions.csv` | `fact_transactions` | ETL fact transaksi |
| `dag_etl_fraud_labels` | `fraud_labels.csv` | `fact_fraud_labels` | ETL fact fraud label |

---

## Pertanyaan Bisnis & Query Analitik

Query di bawah ini murni untuk analisis (bukan task DAG) — jalankan manual lewat SQL client (psql/DBeaver/dsb) setelah DAG dimensi & fact selesai dijalankan.

| # | Pertanyaan Bisnis | Tables | Query |
|---|---|---|---|
| 01 | Berapa total volume dan nilai transaksi per hari, minggu, dan bulan? Apa tren pertumbuhannya? | `dim_date`, `dim_channel`, `fact_transactions` | [01_transaction_analytics.sql](include/sql/business_questions/01_transaction_analytics.sql) |
| 02 | Siapa nasabah paling aktif berdasarkan frekuensi dan nilai transaksi? Bagaimana distribusi per segmen (Retail/Priority/VIP)? | `dim_customer`, `dim_account`, `fact_transactions` | [02_customer_360.sql](include/sql/business_questions/02_customer_360.sql) |
| 03 | Cabang mana yang memiliki performa tertinggi berdasarkan jumlah transaksi dan total nilai transaksi per region? | `dim_branch`, `dim_date`, `fact_transactions` | [03_branch_performance.sql](include/sql/business_questions/03_branch_performance.sql) |
| 04 | Channel apa yang paling banyak digunakan nasabah (ATM, Mobile, Teller, Internet Banking)? Bagaimana tren migrasi ke digital? | `dim_channel`, `dim_date`, `fact_transactions` | [04_channel_analysis.sql](include/sql/business_questions/04_channel_analysis.sql) |
| 05 | Produk rekening mana (Tabungan/Giro/Deposito) yang menghasilkan volume transaksi dan saldo rata-rata tertinggi? | `dim_account`, `dim_date`, `fact_transactions` | [05_product_performance.sql](include/sql/business_questions/05_product_performance.sql) |
| 06 | Adakah transaksi anomali (nilai sangat besar, frekuensi tidak wajar, atau status FAILED berulang) yang perlu diwaspadai? | `dim_customer`, `dim_channel`, `fact_transactions` | [06_risk_fraud_detection.sql](include/sql/business_questions/06_risk_fraud_detection.sql) |

---

## Troubleshooting

**DAG tidak muncul di UI**
```bash
# Hapus cache DAG processor
docker exec $(docker ps --filter "name=airflow-dag-processor" -q) \
  sh -c "rm -rf /opt/airflow/dags/__pycache__"
```

**Koneksi lama muncul / data tidak bersih**
```bash
# Reset semua data (hapus volumes)
docker compose down -v
docker compose up -d
```

**Cek logs container**
```bash
docker compose logs airflow-worker --tail=50
docker compose logs airflow-dag-processor --tail=50
```

**Port 8082 tidak bisa diakses di Codespace**  
Pastikan visibility port di-set ke **Public**: klik kanan port `8082` di tab Ports → **Port Visibility** → **Public**.

---

## GitHub Codespaces — Free Quota & Tips Hemat

### Cek Sisa Quota

Buka: [https://github.com/settings/billing/summary](https://github.com/settings/billing/summary)

Di bagian **Codespaces** akan terlihat compute hours dan storage yang sudah terpakai bulan ini.

### Free Quota per Bulan

| Akun | Compute | Storage |
|---|---|---|
| Free | 120 core-hours | 15 GB |
| Pro | 180 core-hours | 20 GB |

**Catatan core-hours** — tergantung machine type:
- 2-core machine → 120 core-hours = **60 jam aktif**
- 4-core machine → 120 core-hours = **30 jam aktif**

Gunakan **2-core machine** untuk hemat quota (cukup untuk hands-on ini).

### Tips Hemat Quota

> ⚠️ Jangan hanya tutup browser — Codespace tetap berjalan dan memakan quota.

**Stop Codespace saat tidak dipakai:**
1. Buka [https://github.com/codespaces](https://github.com/codespaces)
2. Klik `...` di Codespace yang aktif
3. Pilih **Stop codespace**

Atau dari dalam Codespace: tekan `Ctrl+Shift+P` → ketik `Stop Current Codespace` → Enter.

Codespace otomatis stop setelah **30 menit idle**, tapi lebih baik stop manual untuk memastikan.

**Hapus Codespace yang sudah tidak dipakai** untuk bebaskan storage quota:
1. Buka [https://github.com/codespaces](https://github.com/codespaces)
2. Klik `...` → **Delete**
