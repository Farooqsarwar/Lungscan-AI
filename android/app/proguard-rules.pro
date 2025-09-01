# Suppress TensorFlow Lite GPU delegate warnings
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options

# Ensure required TensorFlow Lite GPU classes are kept
-keep class org.tensorflow.lite.gpu.** { *; }
