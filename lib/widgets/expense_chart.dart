import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_tracker/data/database.dart';

class ExpenseChart extends StatefulWidget {
  @override
  _ExpenseChartState createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  final FinanceDatabase _db = FinanceDatabase();
  List<Map<String, dynamic>> _expenses = [];
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final expenses = await _db.getExpenses();
    setState(() {
      _expenses = expenses;
    });
  }

  Map<String, double> _getCategoryTotals() {
    Map<String, double> totals = {};

    for (var expense in _expenses) {
      if (expense['type'] == 'expense') {
        final category = expense['category'];
        final amount = expense['amount'].toDouble();
        
        totals[category] = (totals[category] ?? 0) + amount;
      }
    }

    return totals;
  }

  List<PieChartSectionData> _getChartSections() {
    final categoryTotals = _getCategoryTotals();
    final totalExpenses = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    
    if (totalExpenses == 0) {
      return [];
    }

    return categoryTotals.entries.map((entry) {
      final index = categoryTotals.keys.toList().indexOf(entry.key);
      final isTouched = index == _selectedIndex;
      final fontSize = isTouched ? 16.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      final color = _getColorForCategory(entry.key);

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${((entry.value / totalExpenses) * 100).toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColorForCategory(String category) {
    final colors = [
      Colors.blueAccent,
      Colors.redAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
      Colors.pinkAccent,
    ];
    
    final index = category.hashCode % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final chartSections = _getChartSections();

    if (chartSections.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Text(
            'No expense data yet!\nAdd some expenses to see charts.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _selectedIndex = -1;
                          return;
                        }
                        _selectedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: chartSections,
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final categoryTotals = _getCategoryTotals();
    final totalExpenses = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: categoryTotals.entries.map((entry) {
        final color = _getColorForCategory(entry.key);
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              color: color,
            ),
            SizedBox(width: 4),
            Text(
              '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}