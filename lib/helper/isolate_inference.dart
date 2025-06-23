import 'dart:isolate';
import 'dart:ui';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'image_detection_helper.dart';

class IsolateInference {
  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;
  late SendPort sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn(_entryPoint, _receivePort.sendPort);
    sendPort = await _receivePort.first;
  }

  void close() {
    _isolate.kill();
    _receivePort.close();
  }

  static void _entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (var message in port) {
      final InferenceModel model = message;

      final img.Image inputImage = img.copyResize(
        model.image!,
        width: model.inputShape[1],
        height: model.inputShape[2],
      );

      final input = [
        List.generate(model.inputShape[1], (y) {
          return List.generate(model.inputShape[2], (x) {
            final pixel = inputImage.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          });
        })
      ];

      final output = [
        List.generate(model.outputShape[1], (_) => List.filled(model.outputShape[2], 0.0))
      ];

      final interpreter = Interpreter.fromAddress(model.interpreterAddress);
      interpreter.run(input, output);

      final xList = output[0][0];
      final yList = output[0][1];
      final wList = output[0][2];
      final hList = output[0][3];
      final confList = output[0][4];

      List<DetectionResult> rawDetections = [];

      for (int i = 0; i < confList.length; i++) {
        double confidence = confList[i];
        if (confidence > 0.5) {
          double x = xList[i];
          double y = yList[i];
          double w = wList[i];
          double h = hList[i];

          Rect rect = Rect.fromLTWH(x - w / 2, y - h / 2, w, h);
          rawDetections.add(DetectionResult(model.labels[0], confidence, rect));
        }
      }

      // Terapkan Non-Maximum Suppression
      final detections = _nonMaxSuppression(rawDetections, iouThreshold: 0.5);

      model.responsePort.send(detections);
    }
  }

  static List<DetectionResult> _nonMaxSuppression(
    List<DetectionResult> boxes, {
    double iouThreshold = 0.5,
  }) {
    boxes.sort((a, b) => b.confidence.compareTo(a.confidence));

    List<DetectionResult> selected = [];

    while (boxes.isNotEmpty) {
      final current = boxes.removeAt(0);
      selected.add(current);

      boxes.removeWhere((box) => _iou(current.boundingBox, box.boundingBox) > iouThreshold);
    }

    return selected;
  }

  static double _iou(Rect a, Rect b) {
    final double x1 = max(a.left, b.left);
    final double y1 = max(a.top, b.top);
    final double x2 = min(a.right, b.right);
    final double y2 = min(a.bottom, b.bottom);

    final double interArea = max(0, x2 - x1) * max(0, y2 - y1);
    final double unionArea = a.width * a.height + b.width * b.height - interArea;

    return unionArea == 0 ? 0 : interArea / unionArea;
  }
}

class InferenceModel {
  final img.Image? image;
  final int interpreterAddress;
  final List<String> labels;
  final List<int> inputShape;
  final List<int> outputShape;
  late SendPort responsePort;

  InferenceModel({
    required this.image,
    required this.interpreterAddress,
    required this.labels,
    required this.inputShape,
    required this.outputShape,
  });
}
