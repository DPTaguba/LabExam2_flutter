import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'crud_service.dart';
import 'firebase_options.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.repository});

  final TaskRepository? repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF126F88),
          surface: const Color(0xFFF6F8FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        useMaterial3: true,
      ),
      home: HomePage(
        repository:
            repository ?? FirestoreTaskRepository(FirebaseFirestore.instance),
      ),
    );
  }
}
