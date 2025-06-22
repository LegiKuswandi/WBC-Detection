import 'dart:isolate';
import 'dart:ui';
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

      // Normalisasi dan bentuk input [1, height, width, 3]
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

      // Bentuk output: [1, 5, 8400]
      final output = [
        List.generate(
          model.outputShape[1], // 5
          (_) => List.filled(model.outputShape[2], 0.0), // 8400
        )
      ];

      final interpreter = Interpreter.fromAddress(model.interpreterAddress);
      interpreter.run(input, output);

      final detections = <DetectionResult>[];

      // Ambil output dari tensor
      final raw = output[0]; // [5][8400]
      final xList = raw[0];
      final yList = raw[1];
      final wList = raw[2];
      final hList = raw[3];
      final confList = raw[4];

      for (int i = 0; i < model.outputShape[2]; i++) {
        final x = xList[i];
        final y = yList[i];
        final w = wList[i];
        final h = hList[i];
        final confidence = confList[i];

        if (confidence > 0.5) {
          final label = model.labels[0]; //hanya 1 kelas
          final rect = Rect.fromLTWH(
            x - w / 2,
            y - h / 2,
            w,
            h,
          );
          detections.add(DetectionResult(label, confidence, rect));
        }
      }

      model.responsePort.send(detections);
    }
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
