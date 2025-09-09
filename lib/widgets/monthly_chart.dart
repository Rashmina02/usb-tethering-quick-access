import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_tracker/data/database.dart';
import 'package:intl/intl.dart';

class MonthlyTrendChart extends StatefulWidget {
  final ChartType chartType;

  MonthlyTrendChart({required this.chartType});

  @override
  _MonthlyTrendChartState createState() => _MonthlyTrendChartState();
}

enum ChartType { expenses, income, balance }

class _MonthlyTrendChartState extends State<MonthlyTrendChart> {
  final FinanceDatabase _db = FinanceDatabase();
  Map<String, double> _monthlyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    Map<String, double> data = {};

    switch (widget.chartType) {
      case ChartType.expenses:
        data = await _db.getMonthlyExpenseData();
        break;
      case ChartType.income:
        data = await _db.getMonthlyIncomeData();
        break;
      case ChartType.balance:
        data = await _db.getMonthlyBalanceData();
        break;
    }

    setState(() {
      _monthlyData = data;
      _isLoading = false;
    });
  }

  List<BarChartGroupData> _getChartGroups() {
    final sortedMonths = _monthlyData.keys.toList()..sort();
    final bars = <BarChartGroupData>[];

    for (int i = 0; i < sortedMonths.length; i++) {
      final month = sortedMonths[i];
      final value = _monthlyData[month]!;
      
      bars.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: value.abs(),
            color: _getColorForValue(value),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));
    }

    return bars;
  }

  Color _getColorForValue(double value) {
    switch (widget.chartType) {
      case ChartType.expenses:
        return Colors.redAccent;
      case ChartType.income:
        return Colors.greenAccent;
      case ChartType.balance:
        return value >= 0 ? Colors.blueAccent : Colors.orangeAccent;
    }
  }

  String _getTitle() {
    switch (widget.chartType) {
      case ChartType.expenses:
        return 'Monthly Expenses';
      case ChartType.income:
        return 'Monthly Income';
      case ChartType.balance:
        return 'Monthly Balance';
    }
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    final sortedMonths = _monthlyData.keys.toList()..sort();
    if (value.toInt() >= sortedMonths.length) return Container();

    final monthKey = sortedMonths[value.toInt()];
    final date = DateTime.parse('$monthKey-01');
    final monthName = DateFormat('MMM yy').format(date);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        monthName,
        style: TextStyle(fontSize: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_monthlyData.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Text(
            'No data available for $_getTitle',
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
              _getTitle(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: _getChartGroups(),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _getBottomTitles,
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildStatsSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    final values = _monthlyData.values.toList();
    if (values.isEmpty) return Container();

    final current = values.last;
    final previous = values.length > 1 ? values[values.length - 2] : 0;
    final difference = current - previous;
    final percentage = previous != 0 ? (difference / previous * 100) : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Current: \$${current.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          '${difference >= 0 ? '+' : ''}${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: difference >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}