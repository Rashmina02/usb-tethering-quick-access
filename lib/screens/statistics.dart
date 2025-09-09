import 'package:flutter/material.dart';
import 'package:finance_tracker/widgets/expense_chart.dart';
import 'package:finance_tracker/data/database.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final FinanceDatabase _db = FinanceDatabase();
  double _totalIncome = 0;
  double _totalExpenses = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final expenses = await _db.getExpenses();
    
    double income = 0;
    double expensesTotal = 0;

    for (var transaction in expenses) {
      if (transaction['type'] == 'income') {
        income += transaction['amount'].toDouble();
      } else {
        expensesTotal += transaction['amount'].toDouble();
      }
    }

    setState(() {
      _totalIncome = income;
      _totalExpenses = expensesTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Income',
                    _totalIncome,
                    Colors.green,
                    Icons.arrow_upward,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Expenses',
                    _totalExpenses,
                    Colors.red,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildSummaryCard(
              'Net Balance',
              _totalIncome - _totalExpenses,
              (_totalIncome - _totalExpenses) >= 0 ? Colors.blue : Colors.orange,
              (_totalIncome - _totalExpenses) >= 0 ? Icons.trending_up : Icons.trending_down,
            ),
            SizedBox(height: 20),

            // Expense Chart
            ExpenseChart(),
            SizedBox(height: 20),

            // Monthly Trends (Placeholder for next step)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Trends',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Monthly charts coming soon!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}