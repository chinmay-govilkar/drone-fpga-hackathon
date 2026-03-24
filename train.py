import os
import numpy as np
import librosa
import tensorflow as tf
from sklearn.model_selection import train_test_split

# ── Config ──────────────────────────────────────────
DATASET_PATH = r"C:\Users\govil\OneDrive\Documents\BITS\BITS '25-'26\Sem II\HyderabadHackathon\drone_fpga\DroneAudioDataset-master\Binary_Drone_Audio"
SAMPLE_RATE  = 16000
DURATION     = 1
N_MELS       = 32
# ────────────────────────────────────────────────────

def load_audio_clips(folder, label):
    clips, labels = [], []
    for f in os.listdir(folder):
        if not f.endswith(".wav"):
            continue
        path = os.path.join(folder, f)
        try:
            y, sr = librosa.load(path, sr=SAMPLE_RATE, duration=DURATION)
            if len(y) < SAMPLE_RATE:
                y = np.pad(y, (0, SAMPLE_RATE - len(y)))
            mel = librosa.feature.melspectrogram(y=y, sr=sr, n_mels=N_MELS)
            mel_db = librosa.power_to_db(mel, ref=np.max)
            clips.append(mel_db)
            labels.append(label)
        except Exception as e:
            print(f"Skipping {f}: {e}")
    return clips, labels

print("Loading data...")
X, y = [], []

# yes_drone = 1, unknown = 0
drone_clips, drone_labels = load_audio_clips(
os.path.join(DATASET_PATH, "yes_drone"), label=1)
X.extend(drone_clips); y.extend(drone_labels)

noise_clips, noise_labels = load_audio_clips(
os.path.join(DATASET_PATH, "unknown"), label=0)
X.extend(noise_clips); y.extend(noise_labels)

X = np.array(X)[..., np.newaxis]
y = np.array(y)
print(f"✅ Loaded {len(y)} clips — Drone: {sum(y==1)}, Not Drone: {sum(y==0)}")
print(f"   Input shape: {X.shape}")

# ── Train/Test Split ──────────────────────────────────
X_train, X_test, y_train, y_test = train_test_split(
X, y, test_size=0.3, random_state=42, stratify=y)

# ── Tiny CNN ──────────────────────────────────────────
model = tf.keras.Sequential([
tf.keras.layers.Input(shape=X_train.shape[1:]),
tf.keras.layers.Conv2D(8, (3,3), activation='relu', padding='same'),
tf.keras.layers.MaxPooling2D((2,2)),
tf.keras.layers.Conv2D(16, (3,3), activation='relu', padding='same'),
tf.keras.layers.MaxPooling2D((2,2)),
tf.keras.layers.Flatten(),
tf.keras.layers.Dense(32, activation='relu'),
tf.keras.layers.Dense(1, activation='sigmoid')
])

model.summary()
model.compile(optimizer='adam',loss='binary_crossentropy',metrics=['accuracy'])

# ── Train ─────────────────────────────────────────────
print("\nTraining...")
from sklearn.utils.class_weight import compute_class_weight
class_weights = compute_class_weight('balanced', classes=np.unique(y_train),y=y_train)
class_weight_dict = dict(enumerate(class_weights))
print(f"Class weights: {class_weight_dict}")
history = model.fit(X_train, y_train,epochs=20,batch_size=32,validation_split=0.15,class_weight=class_weight_dict)

loss, acc = model.evaluate(X_test, y_test)
print(f"\n✅ Test Accuracy: {acc*100:.2f}%")

# ── Save ──────────────────────────────────────────────
model.save("drone_cnn.h5")
np.save("X_test.npy", X_test)
np.save("y_test.npy", y_test)
print("✅ Model saved → drone_cnn.keras")
print("✅ Test data saved → X_test.npy, y_test.npy")