# Data Provenance — Fin-Alert AI
## Sistem Peringatan Dini Risiko Kredit Digital Nasional
**Datathon AI Impact Challenge — Microsoft Elevate Training Center (Dicoding)**

> Dokumen ini membuktikan bahwa seluruh data yang digunakan dalam proyek Fin-Alert AI
> bersumber dari lembaga resmi pemerintah dan regulator Indonesia.
> **Tidak ada data sintetik atau generated** dalam pipeline modeling ini.

---

## 1. TWP90 — Target Variable
| Item | Detail |
|------|--------|
| **Nama lengkap** | Tingkat Wanprestasi P2P Lending ≥90 Hari per Provinsi |
| **Sumber** | Otoritas Jasa Keuangan (OJK) |
| **Publikasi** | Statistik Fintech Lending Bulanan |
| **URL resmi** | https://www.ojk.go.id/id/kanal/iknb/data-dan-statistik/fintech/Pages/Statistik-Fintech-Lending-Periode-Desember-2025.aspx |
| **Granularitas** | Per provinsi, bulanan |
| **Periode** | Januari 2021 — Desember 2025 |
| **Cakupan** | 38 provinsi |
| **File** | `data_prep_datathon_dicoding6.xlsx` → Sheet "Tab 9 (TWP90)" |
| **Verifikasi** | TWP90 nasional rata-rata ~2% sesuai laporan OJK 2023 ✅ |

---

## 2. BI Rate — Suku Bunga Acuan
| Item | Detail |
|------|--------|
| **Nama lengkap** | BI 7-Day Reverse Repo Rate (BI7DRR) |
| **Sumber** | Bank Indonesia (BI) |
| **Publikasi** | Keputusan Rapat Dewan Gubernur BI |
| **URL resmi** | https://www.bi.go.id/id/statistik/indikator/bi-7day-rr.aspx |
| **Granularitas** | Nasional, bulanan |
| **Periode** | 2020 — 2025 |
| **File** | `data_prep_datathon_dicoding6.xlsx` → Sheet "BI Rate" |
| **Verifikasi** | Jan 2021 = 3.75% ✅, Nov 2023 = 6.00% ✅ (sesuai pengumuman BI) |

---

## 3. PDRB Per Kapita — Proxy Kesejahteraan Ekonomi
| Item | Detail |
|------|--------|
| **Nama lengkap** | Produk Domestik Regional Bruto Per Kapita |
| **Sumber** | Badan Pusat Statistik (BPS) |
| **Publikasi** | Publikasi PDRB Provinsi Atas Dasar Harga Berlaku |
| **URL resmi** | https://www.bps.go.id/id/statistics-table/2/MTk2IzI=/pdrb-per-kapita-atas-dasar-harga-berlaku-menurut-provinsi.html |
| **Granularitas** | Per provinsi, tahunan → diinterpolasi bulanan (linear) |
| **Periode** | 2019 — 2025 |
| **Cakupan** | 38 provinsi |
| **File** | `data_prep_datathon_dicoding6.xlsx` → Sheet "PDRB Per Kapita" |
| **Verifikasi** | DKI Jakarta tertinggi, Papua terendah — sesuai publikasi BPS ✅ |

---

## 4. Tingkat Pengangguran Terbuka (TPT)
| Item | Detail |
|------|--------|
| **Nama lengkap** | Tingkat Pengangguran Terbuka per Provinsi |
| **Sumber** | Badan Pusat Statistik (BPS) |
| **Publikasi** | Survei Angkatan Kerja Nasional (Sakernas) |
| **URL resmi** | https://www.bps.go.id/id/statistics-table/2/NTQzIzI=/tingkat-pengangguran-terbuka--persen--menurut-provinsi.html |
| **Granularitas** | Per provinsi, semesteran (Feb & Agu) → diinterpolasi bulanan |
| **Periode** | Februari 2021 — Agustus 2025 |
| **Cakupan** | 38 provinsi |
| **File** | `data_prep_datathon_dicoding6.xlsx` → Sheet "Tingkat Pengangguran Terbuka" |
| **Verifikasi** | TPT nasional ~5-7% sesuai rilis BPS 2021-2025 ✅ |

---

## 5. Tingkat Penetrasi Internet
| Item | Detail |
|------|--------|
| **Nama lengkap** | Persentase Penduduk yang Mengakses Internet per Provinsi |
| **Sumber** | Asosiasi Penyelenggara Jasa Internet Indonesia (APJII) |
| **Publikasi** | Survei Penetrasi Internet Indonesia Tahunan |
| **URL resmi** | https://apjii.or.id/survei |
| **Granularitas** | Per provinsi, tahunan → diinterpolasi bulanan |
| **Periode** | 2021 — 2025 |
| **Cakupan** | 38 provinsi |
| **File** | `data_prep_datathon_dicoding6.xlsx` → Sheet "Tingkat Penetrasi Internet" |
| **Verifikasi** | Penetrasi nasional ~77% (2023) sesuai laporan APJII 2023 ✅ |

---

## 6. Inflasi per Provinsi (Month-to-Month)
| Item | Detail |
|------|--------|
| **Nama lengkap** | Indeks Harga Konsumen (IHK) — Inflasi M-to-M per Provinsi |
| **Sumber** | Badan Pusat Statistik (BPS) |
| **Publikasi** | Berita Resmi Statistik Inflasi Bulanan |
| **URL resmi** | https://www.bps.go.id/id/statistics-table/2/NDcxIzI=/indeks-harga-konsumen-dan-inflasi-bulanan-indonesia.html |
| **Granularitas** | Per provinsi (rata-rata kota), bulanan |
| **Periode** | Januari 2021 — Maret 2026 |
| **Cakupan** | 38 provinsi |
| **File** | `data_prep_datathon_dicoding6.xlsx` → Sheet "Inflasi per Provinsi Tahunan (Y" |
| **Verifikasi** | Inflasi Sep 2022 tinggi (>1%) sesuai dampak kenaikan BBM ✅ |

---

## 7. Data Perbankan (DPK, LDR, NPL, Kredit UMKM)
| Item | Detail |
|------|--------|
| **Nama lengkap** | Statistik Perbankan Indonesia per Provinsi |
| **Sumber** | Otoritas Jasa Keuangan (OJK) |
| **Publikasi** | Statistik Perbankan Indonesia (SPI) |
| **URL resmi** | https://www.ojk.go.id/id/kanal/perbankan/data-dan-statistik/statistik-perbankan-indonesia/Default.aspx |
| **Granularitas** | Per provinsi, tahunan (snapshot Des) → diinterpolasi bulanan |
| **Periode** | 2020 — 2025 |
| **Cakupan** | 33 provinsi (5 provinsi Papua baru tidak tersedia di SPI) |
| **Variabel** | DPK, LDR, NPL Ratio, Kredit UMKM, Jumlah KC Bank |
| **File** | `data_prep_datathon_dicoding6.xlsx` → Sheet "Perbankan" |
| **Catatan** | 5 provinsi Papua baru diimputasi dengan median Papua — didokumentasikan sebagai limitasi |
| **Verifikasi** | LDR nasional ~80-85% sesuai publikasi OJK ✅ |

---

## 8. Transfer ke Daerah (TKD)
| Item | Detail |
|------|--------|
| **Nama lengkap** | Realisasi Transfer ke Daerah per Provinsi |
| **Sumber** | Kementerian Keuangan RI (Kemenkeu) |
| **Publikasi** | APBN Kita & Realisasi APBN per Provinsi |
| **URL resmi** | https://www.kemenkeu.go.id/informasi-publik/data-keuangan-negara/transfer-daerah |
| **Granularitas** | Per provinsi, tahunan (realisasi) → diinterpolasi bulanan |
| **Periode** | 2019 — 2025 |
| **Cakupan** | 38 provinsi |
| **Variabel** | DBH, DAU, DAK, Dana Otsus, Dana Desa, Total TKD |
| **File** | `TKD_per_Provinsi_2019_2025.xlsx` → Sheet "Panel TKD (JOIN-Ready)" |
| **Catatan** | Menggunakan data **Realisasi** (bukan Alokasi) — lebih akurat |
| **Verifikasi** | Total TKD 2023 ~857 Triliun sesuai laporan APBN Kita ✅ |

---

## Metodologi Integrasi Data

```
Join Key: kode_bps (2-digit) + periode (YYYY-MM-01)

Interpolasi tahunan → bulanan: Linear interpolation
df.resample('MS').interpolate('linear')

Alasan: Valid dan defensible jika didokumentasikan
Alternatif yang dipertimbangkan: cubic spline (terlalu agresif),
forward-fill (tidak mencerminkan tren)
```

---

## Checklist Anti-Sintetik ✅

- [x] Semua data bersumber dari lembaga resmi (OJK, BI, BPS, APJII, Kemenkeu)
- [x] File Excel original tersimpan di Blob Storage `finalert-data/raw/`
- [x] Nilai-nilai kunci diverifikasi dengan publikasi resmi
- [x] Tidak ada data yang di-generate, di-simulate, atau di-augment
- [x] Interpolasi linear didokumentasikan secara eksplisit sebagai metodologi
- [x] Limitasi data (5 provinsi Papua, snapshot perbankan) didokumentasikan
- [x] Join key konsisten antar semua sumber (kode_bps + periode)

---

## Cara Verifikasi Mandiri

Untuk memverifikasi keaslian data, juri dapat:

1. **Cek BI Rate**: Kunjungi bi.go.id → bandingkan dengan kolom `bi_rate` di master_panel
2. **Cek TWP90**: Unduh Statistik Fintech Lending OJK → bandingkan TWP90 per provinsi
3. **Cek PDRB**: BPS.go.id → tabel PDRB per kapita provinsi
4. **Cek TKD**: Kemenkeu.go.id → realisasi transfer daerah per tahun

---

*Dokumen ini dibuat sebagai bagian dari submission Datathon AI Impact Challenge.*  
*Tim: Fin-Alert AI | Tanggal: April 2026*
