
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FinanceDatabase {
  // Add to FinanceDatabase class:

// Get expenses by month
Future<Map<String, double>> getMonthlyExpenseData() async {
  await loadData();
  Map<String, double> monthlyData = {};

  for (var expense in _data['expenses']) {
    if (expense['type'] == 'expense') {
      final date = DateTime.parse(expense['date']);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + expense['amount'];
    }
  }

  return monthlyData;
}

// Get income by month  
Future<Map<String, double>> getMonthlyIncomeData() async {
  await loadData();
  Map<String, double> monthlyData = {};

  for (var expense in _data['expenses']) {
    if (expense['type'] == 'income') {
      final date = DateTime.parse(expense['date']);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + expense['amount'];
    }
  }

  return monthlyData;
}

// Get monthly balance (income - expenses)
Future<Map<String, double>> getMonthlyBalanceData() async {
  final incomeData = await getMonthlyIncomeData();
  final expenseData = await getMonthlyExpenseData();
  
  Map<String, double> balanceData = {};

  // Combine all months from both income and expenses
  final allMonths = {...incomeData.keys, ...expenseData.keys};
  
  for (var month in allMonths) {
    final income = incomeData[month] ?? 0;
    final expense = expenseData[month] ?? 0;
    balanceData[month] = income - expense;
  }

  return balanceData;
}
  // Singleton instance
  static final FinanceDatabase _instance = FinanceDatabase._internal();
  factory FinanceDatabase() => _instance;
  FinanceDatabase._internal();

  // Data structure
  Map<String, dynamic> _data = {
    "expenses": [],
    "categories": ["Food", "Transport", "Entertainment", "Shopping", "Bills", "Salary"],
    "settings": {
      "currency": "USD",
      "monthlyBudget": 1000
    }
  };

  // Get the local file path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/finances.json');
  }

  // Load data from JSON file
  Future<void> loadData() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        _data = jsonDecode(contents);
      } else {
        // Use initial data if file doesn't exist
        await _saveData();
      }
    } catch (e) {
      print('Error loading data: $e');
      // Continue with default data
    }
  }

  // Save data to JSON file
  Future<void> _saveData() async {
    try {
      final file = await _localFile;
      final jsonString = jsonEncode(_data);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  // CRUD Operations for Expenses
  Future<void> addExpense(Map<String, dynamic> expense) async {
    _data['expenses'].add(expense);
    await _saveData();
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    await loadData(); // Ensure data is loaded
    return List<Map<String, dynamic>>.from(_data['expenses']);
  }

  Future<void> deleteExpense(String id) async {
    _data['expenses'].removeWhere((expense) => expense['id'] == id);
    await _saveData();
  }

  // Category operations
  Future<List<String>> getCategories() async {
    await loadData();
    return List<String>.from(_data['categories']);
  }

  Future<void> addCategory(String category) async {
    if (!_data['categories'].contains(category)) {
      _data['categories'].add(category);
      await _saveData();
    }
  }

  // Settings operations
  Future<Map<String, dynamic>> getSettings() async {
    await loadData();
    return Map<String, dynamic>.from(_data['settings']);
  }

  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    _data['settings'] = newSettings;
    await _saveData();
  }

  // Utility methods
  Future<double> getTotalBalance() async {
    await loadData();
    double total = 0;
    for (var expense in _data['expenses']) {
      if (expense['type'] == 'income') {
        total += expense['amount'];
      } else {
        total -= expense['amount'];
      }
    }
    return total;
  }

  Future<double> getMonthlyExpenses() async {
    await loadData();
    final now = DateTime.now();
    double total = 0;
    
    for (var expense in _data['expenses']) {
      final date = DateTime.parse(expense['date']);
      if (expense['type'] == 'expense' && 
          date.month == now.month && 
          date.year == now.year) {
        total += expense['amount'];
      }
    }
    return total;
  }
}