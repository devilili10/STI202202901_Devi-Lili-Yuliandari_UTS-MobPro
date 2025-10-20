import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const PersonalJournalApp());
}

class PersonalJournalApp extends StatelessWidget {
  const PersonalJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Journal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomePage(),
    );
  }
}
