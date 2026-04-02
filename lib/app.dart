import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RPG Fitness',
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}
