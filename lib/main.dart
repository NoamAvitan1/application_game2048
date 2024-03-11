
import 'package:application_game2048/intoduction_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '2048 Game',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const IntroductionPage(),
    );
  }
}

