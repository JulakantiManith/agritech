from fastapi import Depends, Header
from auth.jwt_handler import verify_token
from auth.jwt_handler import create_access_token


from fastapi import FastAPI, UploadFile, File, HTTPException
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
import tensorflow as tf
import numpy as np
from PIL import Image
import os
import json


def jwt_required(authorization: str = Header(None)):
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing token")

    token = authorization.replace("Bearer ", "")
    payload = verify_token(token)

    if not payload:
        raise HTTPException(status_code=401, detail="Invalid token")

    return payload


app = FastAPI(title="Plant Disease Detection API")
@app.post("/token")
def generate_token(user: dict):
    """
    Expects: { "email": "user@gmail.com" }
    """
    token = create_access_token({"sub": user["email"]})
    return {"access_token": token}


# -------------------------------
# Load model once
# -------------------------------
MODEL_PATH = "model/plant_disease_mobilenet.keras"
model = tf.keras.models.load_model(MODEL_PATH)
CLASS_NAMES="model/class_names.json"

IMG_SIZE = 224

# -------------------------------
# Load class names (same order as training)
# IMPORTANT: folder name must match training
# -------------------------------

with open("model/class_names.json", "r") as f:
    CLASS_NAMES = json.load(f)
CLASS_NAMES = {int(k): v for k, v in CLASS_NAMES.items()}

# -------------------------------
# TREATMENT DATASET (FULL)
# -------------------------------
TREATMENTS = {

    "Apple": {
        "Apple_scab": {
            "chemical": ["Captan", "Myclobutanil"],
            "organic": ["Sulfur spray", "Copper fungicide"]
        },
        "Black_rot": {
            "chemical": ["Captan", "Thiophanate-methyl"],
            "organic": ["Copper fungicide"]
        },
        "Cedar_apple_rust": {
            "chemical": ["Myclobutanil"],
            "organic": ["Sulfur spray"]
        }
    },

    "Blueberry": {
        "healthy": {
            "chemical": [],
            "organic": []
        }
    },

    "Cherry": {
        "Powdery_mildew": {
            "chemical": ["Myclobutanil"],
            "organic": ["Sulfur spray", "Neem oil"]
        }
    },

    "Corn": {
        "Cercospora_leaf_spot Gray_leaf_spot": {
            "chemical": ["Azoxystrobin", "Propiconazole"],
            "organic": ["Copper fungicide"]
        },
        "Common_rust": {
            "chemical": ["Propiconazole"],
            "organic": ["Neem oil"]
        },
        "Northern_Leaf_Blight": {
            "chemical": ["Mancozeb"],
            "organic": ["Copper fungicide"]
        }
    },

    "Grape": {
        "Black_rot": {
            "chemical": ["Mancozeb"],
            "organic": ["Copper fungicide"]
        },
        "Esca_(Black_Measles)": {
            "chemical": ["Thiophanate-methyl"],
            "organic": ["Copper fungicide"]
        },
        "Leaf_blight_(Isariopsis_Leaf_Spot)": {
            "chemical": ["Captan"],
            "organic": ["Neem oil"]
        }
    },

    "Orange": {
        "Haunglongbing_(Citrus_greening)": {
            "chemical": ["Imidacloprid"],
            "organic": ["Neem oil"]
        }
    },

    "Peach": {
        "Bacterial_spot": {
            "chemical": ["Copper-based bactericide"],
            "organic": ["Copper fungicide"]
        }
    },

    "Pepper,_bell": {
        "Bacterial_spot": {
            "chemical": ["Copper-based bactericide"],
            "organic": ["Neem oil"]
        }
    },

    "Potato": {
        "Early_blight": {
            "chemical": ["Mancozeb", "Chlorothalonil"],
            "organic": ["Copper fungicide"]
        },
        "Late_blight": {
            "chemical": ["Metalaxyl", "Mancozeb"],
            "organic": ["Copper fungicide"]
        }
    },

    "Raspberry": {
        "healthy": {
            "chemical": [],
            "organic": []
        }
    },

    "Soybean": {
        "healthy": {
            "chemical": [],
            "organic": []
        }
    },

    "Squash": {
        "Powdery_mildew": {
            "chemical": ["Myclobutanil"],
            "organic": ["Sulfur spray", "Neem oil"]
        }
    },

    "Strawberry": {
        "Leaf_scorch": {
            "chemical": ["Captan"],
            "organic": ["Copper fungicide"]
        }
    },

    "Tomato": {
        "Bacterial_spot": {
            "chemical": ["Copper-based bactericide"],
            "organic": ["Neem oil"]
        },
        "Early_blight": {
            "chemical": ["Mancozeb", "Chlorothalonil"],
            "organic": ["Neem oil"]
        },
        "Late_blight": {
            "chemical": ["Mancozeb", "Chlorothalonil"],
            "organic": ["Copper fungicide"]
        },
        "Leaf_Mold": {
            "chemical": ["Chlorothalonil"],
            "organic": ["Copper fungicide"]
        },
        "Septoria_leaf_spot": {
            "chemical": ["Mancozeb"],
            "organic": ["Copper fungicide"]
        },
        "Spider_mites Two-spotted_spider_mite": {
            "chemical": ["Abamectin"],
            "organic": ["Neem oil"]
        },
        "Target_Spot": {
            "chemical": ["Chlorothalonil"],
            "organic": ["Copper fungicide"]
        },
        "Tomato_Yellow_Leaf_Curl_Virus": {
            "chemical": ["Imidacloprid"],
            "organic": ["Neem oil"]
        },
        "Tomato_mosaic_virus": {
            "chemical": ["No chemical cure"],
            "organic": ["Remove infected plants"]
        }
    }
}

# -------------------------------
# Image preprocessing
# -------------------------------
def preprocess_image(image: Image.Image):
    image = image.resize((IMG_SIZE, IMG_SIZE))
    image = np.array(image)
    image = preprocess_input(image)
    image = np.expand_dims(image, axis=0)
    return image


# -------------------------------
# Prediction Endpoint
# -------------------------------
@app.post("/predict")
async def predict(
    file: UploadFile = File(...),
    user=Depends(jwt_required)
):
    try:
        image = Image.open(file.file).convert("RGB")
        img_array = preprocess_image(image)

        preds = model.predict(img_array)[0]
        idx = int(np.argmax(preds))
        confidence = float(preds[idx])

        if confidence < 0.3:
            return {
                "plant": "Unknown",
                "disease": "Low confidence prediction",
                "confidence": round(confidence * 100, 2),
                "treatment": {
                    "chemical": [],
                    "organic": ["Please upload a clear leaf image"]
                }
        }


        label = CLASS_NAMES[idx]


        if "___" in label:
            plant, disease = label.split("___")
        else:
            plant = label
            disease = "Unknown"

        # Fetch treatment safely
        treatment = TREATMENTS.get(plant, {}).get(disease, {
            "chemical": ["No specific treatment available"],
            "organic": []
        })

        return {
            "plant": plant,
            "disease": disease,
            "confidence": round(confidence * 100, 2),
            "treatment": treatment
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
