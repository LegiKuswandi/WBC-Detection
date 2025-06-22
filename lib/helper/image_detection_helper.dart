import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'isolate_inference.dart';

class ImageDetectionHelper {
  static const modelPath = 'assets/models/bestweight.tflite';
  static const labelsPath = 'assets/models/labelsWBC.txt';

  late final Interpreter interpreter;
  late final List<String> labels;
  late final IsolateInference isolateInference;
  late Tensor inputTensor;
  late Tensor outputTensor;

  Future<void> _loadModel() async {
    final options = InterpreterOptions();

    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    }
    if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }

    interpreter = await Interpreter.fromAsset(modelPath, options: options);
    inputTensor = interpreter.getInputTensors().first;
    outputTensor = interpreter.getOutputTensors().first;

    log('Interpreter loaded successfully');
  }

  Future<void> _loadLabels() async {
    final labelTxt = await rootBundle.loadString(labelsPath);
    labels = labelTxt.split('\n').where((line) => line.isNotEmpty).toList();
  }

  Future<void> initHelper() async {
    await _loadLabels();
    await _loadModel();
    isolateInference = IsolateInference();
    await isolateInference.start();
  }

  Future<List<DetectionResult>> _inference(InferenceModel model) async {
    ReceivePort responsePort = ReceivePort();
    model.responsePort = responsePort.sendPort;
    isolateInference.sendPort.send(model);
    return await responsePort.first;
  }

  Future<List<DetectionResult>> inferenceImage(Image image) async {
    final model = InferenceModel(
      image: image,
      interpreterAddress: interpreter.address,
      labels: labels,
      inputShape: inputTensor.shape,
      outputShape: outputTensor.shape,
    );
    return _inference(model);
  }

  Future<void> close() async {
    isolateInference.close();
  }
}

class DetectionResult {
  final String label;
  final double confidence;
  final Rect boundingBox;

  DetectionResult(this.label, this.confidence, this.boundingBox);
}
