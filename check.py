import numpy as np
import tensorflow as tf
from sklearn.metrics import classification_report, confusion_matrix

model = tf.keras.models.load_model("drone_cnn.h5")
X_test = np.load("X_test.npy")
y_test = np.load("y_test.npy")

# Predict
y_pred = (model.predict(X_test) > 0.5).astype(int).flatten()

# Detailed report
print(classification_report(y_test, y_pred, 
      target_names=["Not Drone", "Drone"]))

# Confusion matrix
cm = confusion_matrix(y_test, y_pred)
print("Confusion Matrix:")
print(f"                 Predicted Not Drone | Predicted Drone")
print(f"Actual Not Drone       {cm[0][0]}          |      {cm[0][1]}")
print(f"Actual Drone           {cm[1][0]}          |      {cm[1][1]}")