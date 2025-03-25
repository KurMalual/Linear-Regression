// flutter_app/lib/main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// lib/main.dart or lib/pages/prediction_page.dart
final String apiUrl = "https://your-real-api-url.onrender.com/predict"; // Update this
void main() => runApp(AluGpaPredictorApp());

class AluGpaPredictorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU GPA Predictor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ALU GPA Predictor')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PredictionPage()),
          ),
          child: Text('Predict GPA'),
        ),
      ),
    );
  }
}

class PredictionPage extends StatefulWidget {
  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final _formKey = GlobalKey<FormState>();
  final String apiUrl = "https://your-api-url.herokuapp.com/predict";

  // Form fields
  int? age;
  int? expectations;
  int? readingVolume;
  int? meetDeadlines;
  int? workQuality;
  int? levelUnderstanding;
  double? studyHoursBefore;
  double? studyHoursAfter;
  int? stressLevel;

  String prediction = '';
  bool isLoading = false;

  Future<void> predictGpa() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isLoading = true);

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'Age': age,
            'Expectations': expectations,
            'Reading_Volume': readingVolume,
            'Meet_deadlines': meetDeadlines,
            'Work_quality': workQuality,
            'Level_understanding': levelUnderstanding,
            'Study_hours_before': studyHoursBefore,
            'Study_hours_after': studyHoursAfter,
            'Stress_Level': stressLevel,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() => prediction = data['predicted_gpa'].toString());
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Predict GPA')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Age
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final val = int.tryParse(value);
                  if (val == null || val < 15 || val > 30) return '15-30 only';
                  return null;
                },
                onSaved: (value) => age = int.parse(value!),
              ),

              // Expectations
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Initial Expectations (1-5)'),
                items: List.generate(5, (i) => DropdownMenuItem(
                  value: i+1,
                  child: Text('${i+1}'),
                )),
                validator: (value) => value == null ? 'Required' : null,
                onChanged: (value) => expectations = value,
              ),

              // Add similar fields for other features...

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : predictGpa,
                child: isLoading 
                    ? CircularProgressIndicator()
                    : Text('PREDICT GPA'),
              ),

              if (prediction.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'Predicted GPA: $prediction',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}