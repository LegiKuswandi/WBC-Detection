import 'package:flutter/material.dart';
// import 'homepage.dart';
import 'splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CabeTrace',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// === INPUT DETAILS ===
// Name: images
// Shape: [  1 640 640   3]
// Dtype: <class 'numpy.float32'>

// === OUTPUT DETAILS ===
// Name: Identity
// Shape: [   1    5 8400]
// Dtype: <class 'numpy.float32'>
