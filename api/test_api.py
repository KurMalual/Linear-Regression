import requests
import json

# Test locally
url = "http://localhost:8000/predict"
data = {
    "age": 20,
    "expectations": 4,
    "reading_volume": 3,
    "meet_deadlines": 4,
    "work_quality": 3,
    "level_understanding": 2,
    "study_hours_before": 15.0,
    "study_hours_after": 25.0,
    "stress_level": 3
}

response = requests.post(url, json=data)
print(json.dumps(response.json(), indent=2))