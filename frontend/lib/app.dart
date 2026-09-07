import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

class ReFindApp extends StatelessWidget {
  const ReFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReFind',
      home: const HomeScreen(),
    );
  }
}