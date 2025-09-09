import 'package:flutter/material.dart';
import 'package:finance_tracker/services/export_service.dart';

class ExportScreen extends StatefulWidget {
  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final ExportService _exportService = ExportService();
  bool _isExporting = false;
  String _exportStatus = '';

  Future<void> _exportData(String type) async {
    setState(() {
      _isExporting = true;
      _exportStatus = 'Exporting $type...';
    });

    try {
      final file = type == 'detailed' 
          ? await _exportService.exportToCSV()
          : await _exportService.exportMonthlySummary();

      setState(() {
        _exportStatus = 'Exported successfully!\nFile: ${file.path}';
      });

      _exportService.shareFile(file, context);

    } catch (e) {
      setState(() {
        _exportStatus = 'Export failed: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export Data'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Options',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Detailed Export Card
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.list, color: Colors.blue),
                title: Text('Detailed Transactions'),
                subtitle: Text('Export all transactions with full details'),
                trailing: _isExporting 
                    ? CircularProgressIndicator()
                    : IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () => _exportData('detailed'),
                      ),
              ),
            ),
            SizedBox(height: 10),
            
            // Summary Export Card
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.bar_chart, color: Colors.green),
                title: Text('Monthly Summary'),
                subtitle: Text('Export monthly income, expenses, and balance'),
                trailing: _isExporting
                    ? CircularProgressIndicator()
                    : IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () => _exportData('summary'),
                      ),
              ),
            ),
            SizedBox(height: 20),
            
            // Status Display
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _exportStatus,
                      style: TextStyle(
                        color: _exportStatus.contains('failed') 
                            ? Colors.red 
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Spacer(),
            
            // Instructions
            Text(
              'Note: Exported files are saved in your device\'s documents folder and can be opened with spreadsheet apps like Excel or Google Sheets.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}