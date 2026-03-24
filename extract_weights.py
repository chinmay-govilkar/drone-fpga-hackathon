import numpy as np
import tensorflow as tf

model = tf.keras.models.load_model("drone_cnn.h5")
model.summary()

print("\n--- Extracting weights for Verilog ---\n")

for i, layer in enumerate(model.layers):
    weights = layer.get_weights()
    if len(weights) == 0:
        continue
    print(f"Layer {i}: {layer.name}")
    print(f"  Weight shapes: {[w.shape for w in weights]}")

    # Save each layer's weights as numpy arrays
    for j, w in enumerate(weights):
        fname = f"weights_layer{i}_{layer.name}_w{j}.npy"
        np.save(fname, w)
        print(f"  Saved → {fname}")

# Also quantize to 8-bit integers (what Verilog will use)
print("\n--- 8-bit quantized versions (for Verilog) ---\n")

for i, layer in enumerate(model.layers):
    weights = layer.get_weights()
    if len(weights) == 0:
        continue
    for j, w in enumerate(weights):
        # Scale to -127 to +127 range
        max_val = np.max(np.abs(w))
        if max_val == 0:
            continue
        w_quantized = np.round((w / max_val) * 127).astype(np.int8)
        fname = f"weights_layer{i}_{layer.name}_w{j}_int8.npy"
        np.save(fname, w_quantized)
        print(f"Layer {i} {layer.name} weight {j}:")
        print(f"  Original range: [{w.min():.4f}, {w.max():.4f}]")
        print(f"  Quantized range: [{w_quantized.min()}, {w_quantized.max()}]")
        print(f"  Shape: {w_quantized.shape} → saved to {fname}")

print("\n✅ Done! Weights ready for Verilog.")