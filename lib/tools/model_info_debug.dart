import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

Future<void> printModelInfo({
  required String modelPath,
  required String labelPath,
}) async {
  try {
    final interpreter = await Interpreter.fromAsset(modelPath);
    final inputShape = interpreter.getInputTensors().first.shape;
    final outputShape = interpreter.getOutputTensors().first.shape;

    print('Model loaded from: $modelPath');
    print('Input Shape: $inputShape');
    print('Output Shape: $outputShape');

    final labelContent = await rootBundle.loadString(labelPath);
    final labels = labelContent
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    print('Loaded ${labels.length} labels from: $labelPath');
    for (int i = 0; i < labels.length; i++) {
      print('  [$i] ${labels[i]}');
    }
  } catch (e) {
    print('Error loading model or labels: $e');
  }
}
