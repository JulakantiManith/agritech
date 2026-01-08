import json
import os
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input


IMG_SIZE = 224
BATCH_SIZE = 32
EPOCHS = 15

DATASET_PATH = "plant_dataset"  # make sure this matches your folder name
MODEL_DIR = "model"

# Image generators
datagen = ImageDataGenerator(
    preprocessing_function=preprocess_input,
    validation_split=0.2,

    rotation_range=40,
    zoom_range=0.35,
    width_shift_range=0.25,
    height_shift_range=0.25,
    shear_range=0.25,

    brightness_range=[0.5, 1.5],

    horizontal_flip=True,
    fill_mode="nearest"
)






train_data = datagen.flow_from_directory(
    DATASET_PATH,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    subset="training"
)



val_data = datagen.flow_from_directory(
    DATASET_PATH,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    subset="validation"
)

class_names = {int(v): k for k, v in train_data.class_indices.items()}

with open(os.path.join(MODEL_DIR, "class_names.json"), "w") as f:
    json.dump(class_names, f, indent=2, sort_keys=True)

print("✅ Saved class_names.json")

# -------- MobileNetV2 base --------
base_model = MobileNetV2(
    weights="imagenet",
    include_top=False,
    input_shape=(IMG_SIZE, IMG_SIZE, 3)
)

base_model.trainable = True

for layer in base_model.layers[:-40]:
    layer.trainable = False


# Custom classification head
x = base_model.output
x = GlobalAveragePooling2D()(x)
x = Dense(256, activation="relu")(x)
x = Dropout(0.5)(x)
outputs = Dense(train_data.num_classes, activation="softmax")(x)

model = Model(inputs=base_model.input, outputs=outputs)

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-5),
    loss="categorical_crossentropy",
    metrics=["accuracy"]
)


# Train
model.fit(
    train_data,
    validation_data=val_data,
    epochs=EPOCHS
)

# Save model (modern format)
model.save("model/plant_disease_mobilenet.keras")
print("MobileNetV2 model saved successfully!")
