#!/bin/bash
# ============================================================
# Fin-Alert AI — Azure Resource Provisioning Script
# Project : Datathon AI Impact Challenge (Dicoding)
# Resource Group : rg-finalert-ai
# Region  : Southeast Asia (southeastasia)
# ============================================================
# Jalankan dengan: bash setup_finalert_azure.sh
# Pastikan sudah login: az login
# ============================================================

set -e  # Exit on error

# ─────────────────────────────────────────
# 0. KONFIGURASI GLOBAL
# ─────────────────────────────────────────
RG="rg-finalert-ai"
LOCATION="indonesiacentral"

STORAGE_ACCOUNT="stfinalertai"          # Azure Blob Storage
ML_WORKSPACE="ml-finalert-ai"          # Azure ML Workspace
COMPUTE_INSTANCE="ci-finalert"         # Compute Instance (Notebook)
COMPUTE_CLUSTER="cc-finalert"          # Compute Cluster (AutoML)
AOAI_NAME="aoai-finalert"             # Azure OpenAI Service
ACI_NAME="finalert-endpoint"          # Azure Container Instance (REST API)

BLOB_CONTAINER="finalert-data"        # Container di dalam storage account

echo "======================================================"
echo "  Fin-Alert AI — Azure Provisioning"
echo "  Resource Group : $RG"
echo "  Region         : $LOCATION"
echo "======================================================"

# ─────────────────────────────────────────
# 1. RESOURCE GROUP
# ─────────────────────────────────────────
echo ""
echo "[1/8] Membuat Resource Group: $RG ..."
az group create \
  --name "$RG" \
  --location "$LOCATION" \
  --tags project=finalert-ai env=datathon

echo "  ✅ Resource Group berhasil dibuat."

# ─────────────────────────────────────────
# 2. AZURE BLOB STORAGE
# ─────────────────────────────────────────
echo ""
echo "[2/8] Membuat Storage Account: $STORAGE_ACCOUNT ..."
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot \
  --tags project=finalert-ai

# Ambil connection string
STORAGE_CONN=$(az storage account show-connection-string \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RG" \
  --query connectionString -o tsv)

echo "  Membuat Blob Container: $BLOB_CONTAINER ..."
az storage container create \
  --name "$BLOB_CONTAINER" \
  --connection-string "$STORAGE_CONN"

# Buat subfolder structure via placeholder blobs
echo "  Membuat folder structure (raw/, cleaned/, features/, models/, outputs/) ..."
for FOLDER in raw cleaned features models outputs; do
  az storage blob upload \
    --container-name "$BLOB_CONTAINER" \
    --name "${FOLDER}/.gitkeep" \
    --data "" \
    --connection-string "$STORAGE_CONN" \
    --overwrite true \
    --no-progress \
    2>/dev/null || true
done

echo "  ✅ Blob Storage + folder structure berhasil dibuat."
echo "  📁 Struktur:"
echo "     finalert-data/"
echo "     ├── raw/        ← upload data_prep_datathon_dicoding6.xlsx + TKD_per_Provinsi_2019_2025.xlsx"
echo "     ├── cleaned/    ← master_panel.parquet (output notebook 01)"
echo "     ├── features/   ← master_features.parquet (output notebook 03)"
echo "     ├── models/     ← model artifacts"
echo "     └── outputs/    ← prediksi final + narasi GPT-4o"

# ─────────────────────────────────────────
# 3. AZURE ML WORKSPACE
# ─────────────────────────────────────────
echo ""
echo "[3/8] Membuat Azure ML Workspace: $ML_WORKSPACE ..."
echo "  (Proses ini bisa memakan waktu 2-5 menit...)"

az ml workspace create \
  --name "$ML_WORKSPACE" \
  --resource-group "$RG" \
  --location "$LOCATION" \
   \
  --tags project=finalert-ai

echo "  ✅ Azure ML Workspace berhasil dibuat."

# ─────────────────────────────────────────
# 4. COMPUTE INSTANCE (untuk Notebook)
# ─────────────────────────────────────────
echo ""
echo "[4/8] Membuat Compute Instance: $COMPUTE_INSTANCE ..."
echo "  VM Size: Standard_DS2_v2 (2 vCPU, 7 GB RAM)"

az ml compute create \
  --name "$COMPUTE_INSTANCE" \
  --resource-group "$RG" \
  --workspace-name "$ML_WORKSPACE" \
  --type ComputeInstance \
  --size Standard_DS2_v2 \
  --tags project=finalert-ai

echo "  ✅ Compute Instance berhasil dibuat."
echo "  📓 Gunakan untuk: Notebook 01_ingestion, 02_eda, 03_feature_eng, 04_modeling, 05_evaluation"

# ─────────────────────────────────────────
# 5. COMPUTE CLUSTER (untuk AutoML)
# ─────────────────────────────────────────
echo ""
echo "[5/8] Membuat Compute Cluster: $COMPUTE_CLUSTER ..."
echo "  VM Size: Standard_DS2_v2 | min=0, max=2 nodes"

az ml compute create \
  --name "$COMPUTE_CLUSTER" \
  --resource-group "$RG" \
  --workspace-name "$ML_WORKSPACE" \
  --type AmlCompute \
  --size Standard_DS2_v2 \
  --min-instances 0 \
  --max-instances 2 \
  --tags project=finalert-ai

echo "  ✅ Compute Cluster berhasil dibuat."
echo "  🤖 Gunakan untuk: Azure AutoML (pencarian algoritma otomatis — R² primary metric)"

# ─────────────────────────────────────────
# 6. AZURE OPENAI SERVICE (GPT-4o)
# ─────────────────────────────────────────
echo ""
echo "[6/8] Membuat Azure OpenAI Service: $AOAI_NAME ..."
echo "  ⚠️  Pastikan subscription kamu sudah disetujui untuk Azure OpenAI."

az cognitiveservices account create \
  --name "$AOAI_NAME" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --kind OpenAI \
  --sku S0 \
  --yes \
  --tags project=finalert-ai

echo "  Melakukan deploy model GPT-4o ..."
az cognitiveservices account deployment create \
  --name "$AOAI_NAME" \
  --resource-group "$RG" \
  --deployment-name "gpt-4o" \
  --model-name "gpt-4o" \
  --model-version "2024-11-20" \
  --model-format OpenAI \
  --sku-capacity 10 \
  --sku-name "Standard"

echo "  ✅ Azure OpenAI GPT-4o berhasil di-deploy."
echo "  📝 Fungsi: Auto-narasi laporan risiko kredit per provinsi (Notebook 05_evaluation)"

# ─────────────────────────────────────────
# 7. AZURE CONTAINER INSTANCES (REST API Endpoint)
# ─────────────────────────────────────────
echo ""
echo "[7/8] Membuat Azure Container Instance: $ACI_NAME ..."
echo "  ⚠️  ACI akan dibuat setelah model di-export dari Azure ML."
echo "  Script ini menyiapkan placeholder — update image URL setelah modeling selesai."

# Placeholder ACI — image akan di-update setelah model selesai
# Ganti IMAGE_URL dengan Docker image hasil export dari Azure ML
IMAGE_URL="mcr.microsoft.com/azureml/base:latest"  # placeholder

az container create \
  --name "$ACI_NAME" \
  --resource-group "$RG" \
  --image "$IMAGE_URL" \
  --cpu 1 \
  --memory 2 \
  --ports 5001 \
  --protocol TCP \
  --restart-policy OnFailure \
  --tags project=finalert-ai

echo "  ✅ Azure Container Instance placeholder berhasil dibuat."
echo "  🔗 Fungsi: REST API endpoint untuk model prediksi TWP90"
echo "  ⚠️  Update image dengan model container setelah Notebook 04_modeling selesai:"
echo "     az container create --name $ACI_NAME --resource-group $RG --image <YOUR_MODEL_IMAGE> ..."

# ─────────────────────────────────────────
# 8. UPLOAD DATA KE BLOB STORAGE
# ─────────────────────────────────────────
echo ""
echo "[8/8] Upload file data ke Blob Storage (/raw/) ..."

# Cek apakah file ada di direktori lokal
DATA_FILES=(
  "data_prep_datathon_dicoding6.xlsx"
  "TKD_per_Provinsi_2019_2025.xlsx"
)

for FILE in "${DATA_FILES[@]}"; do
  if [ -f "$FILE" ]; then
    echo "  Mengupload $FILE ..."
    az storage blob upload \
      --container-name "$BLOB_CONTAINER" \
      --name "raw/$FILE" \
      --file "$FILE" \
      --connection-string "$STORAGE_CONN" \
      --overwrite true
    echo "  ✅ $FILE berhasil diupload."
  else
    echo "  ⚠️  File $FILE tidak ditemukan di direktori lokal — skip upload."
    echo "     Upload manual via portal atau:"
    echo "     az storage blob upload --container-name $BLOB_CONTAINER --name raw/$FILE --file <path>/$FILE --connection-string \"\$STORAGE_CONN\""
  fi
done

# ─────────────────────────────────────────
# RINGKASAN AKHIR
# ─────────────────────────────────────────
echo ""
echo "======================================================"
echo "  ✅ SEMUA LAYANAN BERHASIL DIBUAT"
echo "======================================================"
echo ""
echo "  Resource Group   : $RG ($LOCATION)"
echo ""
echo "  Layanan yang dibuat:"
echo "  ┌─────────────────────────────────────────────────────────────┐"
echo "  │ No │ Layanan                   │ Resource Name              │"
echo "  ├─────────────────────────────────────────────────────────────┤"
echo "  │  1 │ Azure Blob Storage        │ $STORAGE_ACCOUNT           │"
echo "  │  2 │ Azure ML Workspace        │ $ML_WORKSPACE              │"
echo "  │  3 │ Compute Instance          │ $COMPUTE_INSTANCE          │"
echo "  │  4 │ Compute Cluster (AutoML)  │ $COMPUTE_CLUSTER           │"
echo "  │  5 │ Azure OpenAI GPT-4o       │ $AOAI_NAME                 │"
echo "  │  6 │ Azure Container Instance  │ $ACI_NAME                  │"
echo "  └─────────────────────────────────────────────────────────────┘"
echo ""
echo "  🔑 Ambil Credentials:"
echo "     Storage Key     : az storage account keys list --account-name $STORAGE_ACCOUNT --resource-group $RG"
echo "     OpenAI Endpoint : az cognitiveservices account show --name $AOAI_NAME --resource-group $RG --query properties.endpoint"
echo "     OpenAI Key      : az cognitiveservices account keys list --name $AOAI_NAME --resource-group $RG"
echo ""
echo "  📊 Responsible AI Dashboard & Power BI:"
echo "     → Aktifkan Responsible AI Dashboard dari Azure ML Studio (UI)"
echo "     → Buat Power BI Peta Risiko Indonesia dari outputs/ di Blob Storage"
echo ""
echo "  🗑️  Untuk menghapus semua resource (hemat kredit):"
echo "     az group delete --name $RG --yes --no-wait"
echo "======================================================"
