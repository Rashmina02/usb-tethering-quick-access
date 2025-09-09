import 'package:flutter/material.dart';
import 'package:finance_tracker/data/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Test the database
  final db = FinanceDatabase();
  await db.loadData();
  
  // Add a test expense
  await db.addExpense({
    'id': DateTime.now().millisecondsSinceEpoch.toString(),
    'amount': 25.99,
    'category': 'Food',
    'description': 'Test lunch',
    'date': DateTime.now().toIso8601String(),
    'type': 'expense',
  });

  // Read expenses
  final expenses = await db.getExpenses();
  print('Total expenses: ${expenses.length}');
  print('First expense: ${expenses.first}');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      home: Scaffold(
        appBar: AppBar(title: Text('Finance Tracker')),
        body: Center(child: Text('Database setup successful! Check console for output.')),
      ),
    );
  }
}