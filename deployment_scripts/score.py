import os
import json
import pickle
import numpy as np
import pandas as pd

def init():
    """Load model saat endpoint diinisialisasi."""
    global model, scaler
    
    model_dir = os.environ.get("AZUREML_MODEL_DIR", ".")
    
    # Load XGBoost model
    model_path = os.path.join(model_dir, "xgb_finalert.pkl")
    with open(model_path, "rb") as f:
        model = pickle.load(f)
    
    # Load scaler (untuk fallback LR, tapi XGBoost tidak butuh)
    scaler_path = os.path.join(model_dir, "scaler_finalert.pkl")
    with open(scaler_path, "rb") as f:
        scaler = pickle.load(f)
    
    print("✅ Model Fin-Alert AI berhasil dimuat!")

def risk_zone(twp90_pct):
    """Klasifikasi risk zone berdasarkan nilai TWP90."""
    if twp90_pct < 3.0:
        return "Hijau", "✅ Aman", "Pertahankan kondisi saat ini"
    elif twp90_pct < 5.0:
        return "Kuning", "⚠️ Waspada", "Tingkatkan monitoring dan literasi keuangan"
    else:
        return "Merah", "🚨 Kritis", "Pengetatan penyaluran kredit diperlukan segera"

def run(raw_data):
    """
    Fungsi inferensi utama.
    
    Input JSON format:
    {
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
    
    Output:
    {
        "provinsi": "Jawa Barat",
        "periode": "2025-12-01",
        "twp90_predicted": 3.15,
        "risk_zone": "Kuning",
        "alert_status": "⚠️ Waspada",
        "rekomendasi": "Tingkatkan monitoring dan literasi keuangan",
        "model": "XGBoost Fin-Alert AI v1.0"
    }
    """
    try:
        # Parse input
        data = json.loads(raw_data)
        input_data = data.get("data", data)
        
        # Fitur yang dipakai model (22 kolom, sesuai 04_modeling.ipynb)
        FEATURES = [
            'twp90_lag1', 'twp90_lag3', 'twp90_lag6',
            'twp90_roll3', 'twp90_roll6',
            'outstanding_per_rekening', 'outstanding_growth_mom',
            'internet_x_literasi', 'bi_rate_lag3', 'bi_rate_change',
            'dummy_jawa', 'dummy_island', 'dummy_q1',
            'total_tkd_per_kapita'
        ]
        
        # Ambil metadata
        provinsi = input_data.get("provinsi", "Unknown")
        periode = input_data.get("periode", "Unknown")
        
        # Buat DataFrame fitur
        features = {f: input_data.get(f, 0) for f in FEATURES}
        df_input = pd.DataFrame([features])
        
        # Prediksi
        twp90_pred = float(model.predict(df_input[FEATURES])[0])
        twp90_pred = max(0, twp90_pred)  # Tidak boleh negatif
        
        # Klasifikasi risk zone
        zone, status, rekomendasi = risk_zone(twp90_pred)
        
        result = {
            "provinsi": provinsi,
            "periode": periode,
            "twp90_predicted": round(twp90_pred, 4),
            "risk_zone": zone,
            "alert_status": status,
            "rekomendasi": rekomendasi,
            "model": "XGBoost Fin-Alert AI v1.0",
            "features_used": len(FEATURES)
        }
        
        return json.dumps(result, ensure_ascii=False)
    
    except Exception as e:
        error_result = {"error": str(e), "status": "failed"}
        return json.dumps(error_result)
