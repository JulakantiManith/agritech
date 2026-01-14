🌱 Smart Agriculture -- Plant Disease Detection System
=====================================================

📌 Project Description
----------------------

The Smart Agriculture -- Plant Disease Detection System is an AI-based application developed to assist farmers in identifying plant diseases at an early stage. The system analyzes images of plant leaves and predicts the type of disease using a deep learning model. Based on the prediction, it provides suitable chemical and organic treatment recommendations.

The project consists of a Flutter mobile application for user interaction, a FastAPI backend server for handling image processing and prediction requests, and a deep learning model based on MobileNetV2 trained on the PlantVillage dataset. Secure authentication is implemented using Firebase Authentication and JWT tokens.

This system aims to improve crop health, reduce crop loss, and promote smart agricultural practices.

* * * * *

⚙️ Installation and Setup
-------------------------

### 🔹 Backend Setup

1.  Open the backend project directory:

`cd backend`

1.  Install the required Python dependencies:

`pip install -r requirements.txt`

1.  Run the FastAPI server:

`uvicorn main:app --host 0.0.0.0 --port 5000`

The backend server will start at:

`http://0.0.0.0:5000`

* * * * *

### 🔹 Frontend Setup

1.  Open the frontend project directory:

`cd frontend`

1.  Install Flutter dependencies:

`flutter pub get`

1.  Run the Flutter application:

`flutter run`

1.  Update the backend server IP address in the Flutter application:

`ApiConstants.baseUrl = "http://<your-local-ip>:5000";`

* * * * *

⚠️ Note
-------

-   Ensure Python and Flutter are properly installed

-   Backend server and mobile device/emulator should be connected to the same network

-   Firebase configuration must be completed before running the application
