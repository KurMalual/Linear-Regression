from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import numpy as np
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="ALU GPA Predictor", version="1.0")

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"]
)

# Load ML artifacts
model = joblib.load('best_model.pkl')
scaler = joblib.load('scaler.pkl')

class StudentData(BaseModel):
    age: int
    expectations: int
    reading_volume: int
    meet_deadlines: int
    work_quality: int
    level_understanding: int
    study_hours_before: float
    study_hours_after: float
    stress_level: int

@app.post("/predict")
async def predict(data: StudentData):
    try:
        features = np.array([
            data.age,
            data.expectations,
            data.reading_volume,
            data.meet_deadlines,
            data.work_quality,
            data.level_understanding,
            data.study_hours_before,
            data.study_hours_after,
            data.stress_level
        ]).reshape(1, -1)
        
        scaled_features = scaler.transform(features)
        prediction = model.predict(scaled_features)
        
        return {"predicted_gpa": round(float(prediction[0]), 2)}
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)