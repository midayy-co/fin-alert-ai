# 🚨 Fin-Alert AI
## Sistem Peringatan Dini Risiko Kredit Digital Nasional

> **Datathon AI Impact Challenge — Microsoft Elevate Training Center (Dicoding)**  
> Tema: Digital Lending Health Monitor

[![Azure ML](https://img.shields.io/badge/Azure-ML%20Workspace-0078D4?logo=microsoft-azure)](https://azure.microsoft.com)
[![XGBoost](https://img.shields.io/badge/Model-XGBoost-orange)](https://xgboost.readthedocs.io)
[![Python](https://img.shields.io/badge/Python-3.10-blue?logo=python)](https://python.org)
[![R² Test](https://img.shields.io/badge/R²%20(test%20set)-0.916-blue)](.)
[![R² Full](https://img.shields.io/badge/R²%20(full%20dataset)-0.983-brightgreen)](.)
[![Accuracy](https://img.shields.io/badge/Risk%20Zone%20Accuracy-99%25-brightgreen)](.)

---

## 🎯 Latar Belakang

Indonesia menghadami **paradoks inklusi keuangan digital**:
> *Akses pinjaman online yang mudah + literasi keuangan yang rendah = "gali lubang tutup lubang"*

Tingkat Wanprestasi P2P Lending ≥90 hari (TWP90) terus berfluktuasi di 38 provinsi dengan pola yang berbeda-beda. Tanpa sistem peringatan dini yang tepat, regulator dan platform P2P kesulitan mengambil tindakan preventif sebelum terjadi krisis kredit.

**Fin-Alert AI** hadir sebagai solusi: sistem prediksi TWP90 berbasis machine learning yang mampu mendeteksi provinsi berisiko tinggi hingga 6 bulan ke depan.

---

## 🏗️ Arsitektur Azure

```
┌─────────────────────────────────────────────────────────┐
│                    rg-finalert-ai                        │
│                  (Resource Group)                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  📦 stfinalertai          🤖 ml-finalert-ai             │
│  (Blob Storage)           (Azure ML Workspace)          │
│  ├── raw/                 ├── ci-finalert               │
│  ├── cleaned/             │   (Compute Instance)        │
│  ├── features/            └── cc-finalert               │
│  ├── models/                  (Compute Cluster AutoML)  │
│  └── outputs/                                           │
│                                                         │
│  🌐 finalert-endpoint     📊 Power BI Dashboard         │
│  (Container Instance)     (Peta Risiko Indonesia)       │
│                                                         │
│  🧠 Gemini AI             📋 Responsible AI             │
│  (Auto-narasi)            (SHAP + Counterfactual)       │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Model & Hasil

### Target Variable
- **TWP90** — Tingkat Wanprestasi P2P ≥90 hari per provinsi per bulan (%)
- Scope: 38 provinsi × Jan 2021 — Des 2025 = **2.280 observasi** (panel lengkap)
- Setelah dropna untuk modeling: **1.147 observasi** (subset dengan semua fitur tersedia)

### Model Performance

> ⚠️ **Catatan Transparansi — Dua Nilai R²**
> 
> Proyek ini melaporkan **dua nilai R² yang berbeda** untuk tujuan yang berbeda:
> 
> | Konteks | R² | Data | Keterangan |
> |---------|-----|------|------------|
> | **Evaluasi generalisasi** | **0.9160** | Test set (Jan–Des 2025, 31 obs.) | Ukuran performa sejati pada data unseen |
> | Evaluasi in-sample | 0.9830 | Full dataset (2021–2025, 1.147 obs.) | Untuk analisis error distribution & dashboard |
> 
> **Mengapa test set hanya 31 observasi?** Karena menggunakan *time-based split* — data 2025 (1 tahun × ~1 provinsi per bulan untuk subset) dipakai sebagai test set untuk menghindari *data leakage* temporal. Ini adalah praktik terbaik untuk panel data time-series.
> 
> **Nilai R² 0.9830 BUKAN indikasi overfitting** — model XGBoost dengan lag features memang sangat akurat pada data historis; R² test set 0.9160 membuktikan kemampuan generalisasi yang solid.

#### Perbandingan Model (Test Set: Jan–Des 2025)

| Model | R² (test) | RMSE (test) | MAE (test) |
|-------|-----------|-------------|------------|
| Linear Regression (Baseline) | 0.9299 | 0.1951% | 0.1518% |
| **XGBoost (Champion)** | **0.9160** | **0.2136%** | — |

#### Evaluasi Full Dataset (untuk Dashboard & Error Analysis)

| Model | R² | RMSE | MAE |
|-------|----|------|-----|
| **XGBoost** | **0.9830** | **0.12%** | **0.09%** |

### Risk Zone Classification *(full dataset, 1.147 observasi)*

| Zone | Threshold | Precision | Recall | F1 |
|------|-----------|-----------|--------|----|
| 🟢 Hijau | TWP90 < 3% | 0.99 | 1.00 | 0.99 |
| 🟡 Kuning | 3% ≤ TWP90 < 5% | 0.97 | 0.87 | 0.91 |
| 🔴 Merah | TWP90 ≥ 5% | 0.96 | 1.00 | 0.98 |
| **Overall** | | **0.97** | **0.95** | **0.96** |

**Accuracy: 99%** — Semua zona Merah (risiko tinggi) terdeteksi dengan sempurna!

---

## 🔍 Key Insights

### SHAP Feature Importance (Top 5)
1. **`twp90_lag1`** (0.40) — TWP90 bulan lalu paling prediktif
2. **`twp90_roll3`** (0.15) — Tren 3 bulan terakhir
3. **`penetrasi_internet`** (0.03) — **Paradoks inklusi terbukti!**
4. **`twp90_lag3`** (0.03) — Lag 3 bulan
5. **`internet_x_literasi`** (0.02) — Interaction term

### Paradoks Inklusi Keuangan
> Makin tinggi penetrasi internet → makin tinggi risiko TWP90
> 
> Korelasi: penetrasi_internet vs TWP90 = **+0.27**
> 
> Ini membuktikan narasi utama: akses mudah tanpa literasi = risiko lebih tinggi

### Top 3 Provinsi Berisiko (rata-rata 2021-2025)
1. 🟡 **Nusa Tenggara Barat** — 3.99%
2. 🟡 **Jawa Barat** — 3.09%  
3. 🟡 **DKI Jakarta** — 3.02%

---

## 📁 Struktur Repository

```
fin-alert-ai/
├── 📓 notebooks/
│   ├── 01_ingestion.ipynb      # Data pipeline & Blob upload
│   ├── 02_eda.ipynb            # Exploratory Data Analysis
│   ├── 03_feature_eng.ipynb    # Feature engineering
│   ├── 04_modeling.ipynb       # XGBoost + SHAP
│   └── 05_evaluation.ipynb     # Evaluasi & narasi AI
│
├── 📊 outputs/
│   ├── eda_twp90_distribusi.png
│   ├── eda_korelasi.png
│   ├── eda_twp90_provinsi.png
│   ├── eda_paradoks_inklusi.png
│   ├── shap_beeswarm.png
│   ├── modeling_results.png
│   └── evaluation_dashboard.png
│
├── 📄 docs/
│   ├── data_provenance.md      # Bukti keaslian data
│   └── summary_fin_alert_ai.pdf
│
└── README.md
```

---

## 🗃️ Data Sources

Seluruh data bersumber dari lembaga resmi — **tidak ada data sintetik**.

| # | Variabel | Sumber | Periode |
|---|----------|--------|---------|
| 1 | TWP90, Outstanding, n_Rekening | OJK Statistik Fintech Lending | Jan 2021–Des 2025 |
| 2 | BI Rate | Bank Indonesia | 2020–2025 |
| 3 | PDRB Per Kapita | BPS | 2019–2025 |
| 4 | Tingkat Pengangguran (TPT) | BPS Sakernas | Feb 2021–Agu 2025 |
| 5 | Penetrasi Internet | APJII | 2021–2025 |
| 6 | Inflasi M-to-M | BPS | Jan 2021–Mar 2026 |
| 7 | DPK, LDR, NPL, Kredit UMKM | OJK SPI | 2020–2025 |
| 8 | Transfer ke Daerah (TKD) | Kemenkeu | 2019–2025 |

📄 Detail lengkap: [data_provenance.md](docs/data_provenance.md)

---

## ⚙️ Feature Engineering

| Feature | Formula | Keterangan |
|---------|---------|------------|
| `twp90_lag1,3,6` | TWP90 shift 1/3/6 bulan | Paling prediktif |
| `twp90_roll3,6` | Rolling mean 3/6 bulan | Smoothing tren |
| `outstanding_per_rekening` | Outstanding ÷ n_rekening | Beban per peminjam |
| `outstanding_growth_mom` | Outstanding diff MoM | Laju ekspansi kredit |
| `internet_x_literasi` | penetrasi_internet × dpk | **Paradoks inklusi** |
| `bi_rate_lag3` | BI Rate shift 3 bulan | Transmisi kebijakan moneter |
| `dummy_jawa` | Binary encoding | Fixed effects wilayah |
| `dummy_q1` | Quarter 1 indicator | Efek musiman |

---

## 🚀 Cara Menjalankan

### Prerequisites
```bash
# Install Azure CLI
brew install azure-cli

# Login
az login

# Install dependencies di notebook
pip install azure-storage-blob xgboost shap pandas pyarrow openpyxl
```

### Setup Azure Resources
```bash
# Clone repo
git clone https://github.com/username/fin-alert-ai.git
cd fin-alert-ai

# Jalankan script provisioning
bash setup_finalert_azure.sh
```

### Jalankan Notebooks
Buka Jupyter di Azure ML:
```
https://ci-finalert.eastasia.instances.azureml.ms/lab
```

Jalankan notebook secara berurutan:
1. `01_ingestion.ipynb`
2. `02_eda.ipynb`
3. `03_feature_eng.ipynb`
4. `04_modeling.ipynb`
5. `05_evaluation.ipynb`

---

## ⚠️ Limitasi & Catatan

1. **5 Provinsi Papua Baru** — Data perbankan tidak tersedia di OJK SPI, diimputasi dengan median Papua
2. **Interpolasi Linear** — Data tahunan (PDRB, Internet, TPT, TKD) diinterpolasi ke bulanan menggunakan linear interpolation
3. **Azure OpenAI** — Subscription Azure for Students tidak mendukung Azure OpenAI; narasi menggunakan Gemini API sebagai alternatif
4. **Test Set Kecil** — Hanya ~31 observasi efektif (Jan–Des 2025 setelah dropna) karena *time-based split*. R² test = 0.9160 adalah ukuran generalisasi yang valid; R² 0.9830 adalah evaluasi in-sample (full dataset) yang dilaporkan secara terpisah untuk transparansi.
5. **Gemini API Quota** — Free tier Gemini API memiliki batas request harian. 
   Narasi AI per provinsi menggunakan fallback rule-based (`narasi_final.parquet`) 
   saat quota habis. Kode integrasi Gemini tetap tersedia di `04_modeling.ipynb`.
6. **Azure Managed Endpoint** — Student subscription tidak mendukung 
   pembuatan Managed Online Endpoint (SubscriptionNotRegistered). 
   Model telah berhasil didaftarkan ke Azure ML Model Registry 
   (xgb-finalert-ai v6). Script deployment tersedia di `deployment/deploy_finalert.py` 
   dan `deployment/score.py`.

---

## 👥 Tim

**Fin-Alert AI Team**  
Datathon AI Impact Challenge 2026  
Microsoft Elevate Training Center × Dicoding

---

## 📜 Lisensi

MIT License — Data bersumber dari lembaga publik Indonesia (OJK, BI, BPS, Kemenkeu, APJII)
