import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:finance_tracker/data/database.dart';
import 'package:flutter/material.dart'; // Add this import for BuildContext

class ExportService {
  final FinanceDatabase _db = FinanceDatabase();

  Future<File> exportToCSV() async {
    // Get all expenses
    final expenses = await _db.getExpenses();
    
    // Create CSV data
    final List<List<dynamic>> csvData = [];
    
    // Add header row
    csvData.add(['ID', 'Date', 'Type', 'Category', 'Description', 'Amount']);
    
    // Add data rows
    for (var expense in expenses) {
      csvData.add([
        expense['id'],
        expense['date'],
        expense['type'],
        expense['category'],
        expense['description'],
        expense['amount'].toString(),
      ]);
    }
    
    // Convert to CSV string
    final csvString = const ListToCsvConverter().convert(csvData);
    
    // Get directory for saving
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/finance_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    
    // Write to file
    await file.writeAsString(csvString);
    
    return file;
  }

  Future<File> exportMonthlySummary() async {
    final expenses = await _db.getExpenses();
    final incomeData = await _db.getMonthlyIncomeData();
    final expenseData = await _db.getMonthlyExpenseData();
    
    final List<List<dynamic>> csvData = [];
    
    // Header
    csvData.add(['Month', 'Income', 'Expenses', 'Balance']);
    
    // Combine all months
    final allMonths = {...incomeData.keys, ...expenseData.keys}.toList()..sort();
    
    for (var month in allMonths) {
      final income = incomeData[month] ?? 0;
      final expenses = expenseData[month] ?? 0;
      final balance = income - expenses;
      
      csvData.add([
        month,
        income.toStringAsFixed(2),
        expenses.toStringAsFixed(2),
        balance.toStringAsFixed(2),
      ]);
    }
    
    final csvString = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/monthly_summary_${DateTime.now().millisecondsSinceEpoch}.csv');
    
    await file.writeAsString(csvString);
    return file;
  }

  Future<void> shareFile(File file, BuildContext context) async {
    final snackBar = SnackBar(
      content: Text('File exported to: ${file.path}'),
      duration: Duration(seconds: 3),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          // Dismiss the snackbar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}