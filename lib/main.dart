import 'package:flutter/material.dart';
import 'package:finance_tracker/data/database.dart';
import 'package:finance_tracker/screens/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final db = FinanceDatabase();
  await db.loadData();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}