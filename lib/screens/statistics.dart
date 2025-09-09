import 'package:flutter/material.dart';
import 'package:finance_tracker/widgets/expense_chart.dart';
import 'package:finance_tracker/widgets/monthly_chart.dart';
import 'package:finance_tracker/data/database.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  final FinanceDatabase _db = FinanceDatabase();
  double _totalIncome = 0;
  double _totalExpenses = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.trending_up), text: 'Expenses'),
            Tab(icon: Icon(Icons.trending_up), text: 'Income'),
            Tab(icon: Icon(Icons.balance), text: 'Balance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildChartTab(ChartType.expenses),
          _buildChartTab(ChartType.income),
          _buildChartTab(ChartType.balance),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
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

          // Expense Distribution Chart
          ExpenseChart(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChartTab(ChartType chartType) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        children: [
          MonthlyTrendChart(chartType: chartType),
          SizedBox(height: 20),
          _buildStatsForChartType(chartType),
        ],
      ),
    );
  }

  Widget _buildStatsForChartType(ChartType chartType) {
    // Placeholder for advanced stats
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Average, trends, and comparisons coming soon!',
              style: TextStyle(color: Colors.grey),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}