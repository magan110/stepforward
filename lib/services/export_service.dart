import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:step_counter_app/services/storage_service.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  final StorageService _storageService;

  ExportService(this._storageService);

  Future<String> exportToCSV() async {
    // Get all step data
    final List<List<dynamic>> rows = [];

    // Add headers
    rows.add(['Date', 'Steps', 'Distance (km)', 'Calories (kcal)']);

    // Get data for the last 30 days
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final steps = _storageService.getStepsForDate(date);

      // Calculate distance and calories (same formulas as StepService)
      final profile = _storageService.getUserProfile();
      final double height = profile['height'];
      final double strideLength = height * 0.415 / 100;
      final distance = (steps * strideLength) / 1000;
      final calories = steps * 0.04;

      rows.add([
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        steps,
        distance.toStringAsFixed(2),
        calories.toStringAsFixed(0),
      ]);
    }

    // Convert to CSV
    final csv = const ListToCsvConverter().convert(rows);

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/step_data_export.csv';
    final file = File(path);
    await file.writeAsString(csv);

    return path;
  }

  Future<void> shareCSV() async {
    final path = await exportToCSV();
    await Share.shareXFiles([
      XFile(path),
    ], text: 'My Step Counter Data - Last 30 Days');
  }

  Future<Map<String, dynamic>> getExportSummary() async {
    final now = DateTime.now();
    int totalSteps = 0;
    int daysWithData = 0;

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final steps = _storageService.getStepsForDate(date);
      if (steps > 0) {
        totalSteps += steps;
        daysWithData++;
      }
    }

    final avgSteps = daysWithData > 0 ? totalSteps / daysWithData : 0;

    return {
      'totalSteps': totalSteps,
      'daysWithData': daysWithData,
      'avgSteps': avgSteps.round(),
      'period': '30 days',
    };
  }
}
