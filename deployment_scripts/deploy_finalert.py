"""
deploy_finalert.py
==================
Script deployment model Fin-Alert AI ke Azure ML Managed Online Endpoint
Menggunakan Azure ML SDK v2

Cara pakai:
    python deploy_finalert.py

Prerequisites:
    pip install azure-ai-ml azure-identity
"""

from azure.ai.ml import MLClient
from azure.ai.ml.entities import (
    ManagedOnlineEndpoint,
    ManagedOnlineDeployment,
    Model,
    Environment,
    CodeConfiguration,
)
from azure.identity import DefaultAzureCredential
import time

# ============================================================
# KONFIGURASI — sesuaikan dengan resource kamu
# ============================================================
SUBSCRIPTION_ID = "73218dbb-3de8-4a77-8046-30ab9fb386f1"
RESOURCE_GROUP  = "rg-finalert-ai"
WORKSPACE_NAME  = "ml-finalert-ai"
ENDPOINT_NAME   = "finalert-ep-v4"
DEPLOYMENT_NAME = "finalert-deploy-v1"

# ============================================================
# 1. Connect ke Azure ML Workspace
# ============================================================
print("🔗 Connecting ke Azure ML Workspace...")
credential = DefaultAzureCredential()
ml_client = MLClient(
    credential=credential,
    subscription_id=SUBSCRIPTION_ID,
    resource_group_name=RESOURCE_GROUP,
    workspace_name=WORKSPACE_NAME,
)
print(f"✅ Connected ke workspace: {WORKSPACE_NAME}")

# ============================================================
# 2. Register Model ke Azure ML Model Registry
# ============================================================
print("\n📦 Mendaftarkan model ke Azure ML Model Registry...")
model = Model(
    path="models/",                 # Folder berisi xgb_finalert.pkl & scaler_finalert.pkl
    name="xgb-finalert-ai",
    description="XGBoost model untuk prediksi TWP90 P2P Lending per provinsi",
    type="custom_model",
)
registered_model = ml_client.models.create_or_update(model)
print(f"✅ Model registered: {registered_model.name} v{registered_model.version}")

# ============================================================
# 3. Buat Environment
# ============================================================
print("\n🐍 Membuat environment...")
env = Environment(
    name="finalert-env",
    description="Environment untuk Fin-Alert AI inference",
    conda_file="conda_env.yml",
    image="mcr.microsoft.com/azureml/openmpi4.1.0-ubuntu20.04:latest",
)

# ============================================================
# 4. Buat / Update Endpoint
# ============================================================
print(f"\n🌐 Membuat endpoint: {ENDPOINT_NAME}...")
endpoint = ManagedOnlineEndpoint(
    name=ENDPOINT_NAME,
    description="Fin-Alert AI — Sistem Peringatan Dini Risiko Kredit Digital",
    auth_mode="key",
    tags={
        "project": "fin-alert-ai",
        "model": "xgboost",
        "target": "twp90-prediction"
    }
)

ml_client.online_endpoints.begin_create_or_update(endpoint).result()
print(f"✅ Endpoint '{ENDPOINT_NAME}' siap!")
print("⏳ Menunggu endpoint benar-benar ready (30 detik)...")
time.sleep(30)

# ============================================================
# 5. Deploy Model ke Endpoint
# ============================================================
print(f"\n🚀 Mendeploy model ke endpoint...")
deployment = ManagedOnlineDeployment(
    name=DEPLOYMENT_NAME,
    endpoint_name=ENDPOINT_NAME,
    model=registered_model,
    code_configuration=CodeConfiguration(
        code=".",                   # Folder berisi score.py
        scoring_script="score.py",
    ),
    environment=env,
    instance_type="Standard_F2s_v2",
    instance_count=1,
)

ml_client.online_deployments.begin_create_or_update(deployment).result()
print(f"✅ Deployment '{DEPLOYMENT_NAME}' berhasil!")

# ============================================================
# 6. Set traffic 100% ke deployment ini
# ============================================================
print("\n🔀 Setting traffic...")
endpoint.traffic = {DEPLOYMENT_NAME: 100}
ml_client.online_endpoints.begin_create_or_update(endpoint).result()
print("✅ Traffic 100% → finalert-deploy-v1")

# ============================================================
# 7. Test endpoint
# ============================================================
print("\n🧪 Testing endpoint...")
import json

test_input = {
    "data": {
        "provinsi": "Jawa Barat",
        "periode": "2025-12-01",
        "twp90_lag1": 3.2,
        "twp90_lag3": 3.0,
        "twp90_lag6": 2.8,
        "twp90_roll3": 3.1,
        "twp90_roll6": 3.0,
        "outstanding_per_rekening": 2500000,
        "outstanding_growth_mom": 0.02,
        "internet_x_literasi": 0.45,
        "bi_rate_lag3": 6.0,
        "bi_rate_change": 0.25,
        "dummy_jawa": 1,
        "dummy_island": 1,
        "dummy_q1": 0,
        "total_tkd_per_kapita": 1500000
    }
}

# Simpan test input ke file
with open("test_input.json", "w") as f:
    json.dump(test_input, f)

# Invoke endpoint
response = ml_client.online_endpoints.invoke(
    endpoint_name=ENDPOINT_NAME,
    deployment_name=DEPLOYMENT_NAME,
    request_file="test_input.json",
)

print("\n" + "="*50)
print("  🎯 HASIL TEST ENDPOINT — FIN-ALERT AI")
print("="*50)
result = json.loads(response)
print(f"  Provinsi      : {result['provinsi']}")
print(f"  TWP90 Pred    : {result['twp90_predicted']}%")
print(f"  Risk Zone     : {result['risk_zone']}")
print(f"  Alert Status  : {result['alert_status']}")
print(f"  Rekomendasi   : {result['rekomendasi']}")
print("="*50)

# ============================================================
# 8. Ambil endpoint URL & key
# ============================================================
endpoint_detail = ml_client.online_endpoints.get(ENDPOINT_NAME)
print(f"\n🔗 Endpoint URL: {endpoint_detail.scoring_uri}")
print(f"🔑 Primary Key : {ml_client.online_endpoints.get_keys(ENDPOINT_NAME).primary_key[:20]}...")
print("\n✅ DEPLOYMENT SELESAI! Fin-Alert AI siap menerima request real-time.")
