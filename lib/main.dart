// import 'package:flutter/material.dart';
// // import 'homepage.dart';
// import 'splash.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'CabeTrace',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
//         useMaterial3: true,
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:image_classification_mobilenet/splash.dart';
import 'tools/model_info_debug.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await printModelInfo(
    modelPath: 'assets/models/mymodel.tflite',
    labelPath: 'assets/models/labels2.txt',
  );

  runApp(const SplashScreen());
}
