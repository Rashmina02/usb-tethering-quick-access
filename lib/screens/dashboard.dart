import 'package:flutter/material.dart';
import 'package:finance_tracker/data/database.dart';
import 'package:finance_tracker/screens/add_expense.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FinanceDatabase _db = FinanceDatabase();
  double _totalBalance = 0;
  double _monthlyExpenses = 0;
  List<Map<String, dynamic>> _recentExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final balance = await _db.getTotalBalance();
    final expenses = await _db.getMonthlyExpenses();
    final recent = await _db.getExpenses();
    
    setState(() {
      _totalBalance = balance;
      _monthlyExpenses = expenses;
      _recentExpenses = recent.reversed.toList(); // Latest first
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Tracker'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            _buildBalanceCard(),
            SizedBox(height: 20),
            
            // Monthly Expenses
            _buildMonthlyExpensesCard(),
            SizedBox(height: 20),
            
            // Recent Transactions Header
            Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            
            // Recent Transactions List
            _buildRecentTransactions(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );
          _loadData(); // Refresh data after adding expense
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '\$${_totalBalance.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _totalBalance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyExpensesCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Expenses',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  '\$${_monthlyExpenses.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Icon(Icons.trending_up, color: Colors.blue, size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_recentExpenses.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'No transactions yet\nTap + to add your first expense!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _recentExpenses.length,
        itemBuilder: (context, index) {
          final expense = _recentExpenses[index];
          return _buildTransactionItem(expense);
        },
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> expense) {
    final isIncome = expense['type'] == 'income';
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(
          isIncome ? Icons.arrow_circle_up : Icons.arrow_circle_down,
          color: isIncome ? Colors.green : Colors.red,
          size: 32,
        ),
        title: Text(
          expense['description'] ?? 'No description',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${expense['category']} • ${_formatDate(expense['date'])}',
        ),
        trailing: Text(
          '\$${expense['amount'].toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}