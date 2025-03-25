import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionPage extends StatefulWidget {
  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final _formKey = GlobalKey<FormState>();
  final String apiUrl = "http://localhost:8000/predict"; // Update with your deployed URL

  // Form controllers
  final ageController = TextEditingController();
  final expectationsController = TextEditingController();
  // Add controllers for other fields...

  String prediction = '';
  bool isLoading = false;

  Future<void> predictGpa() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        prediction = '';
      });

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'age': int.parse(ageController.text),
            'expectations': int.parse(expectationsController.text),
            // Include all other fields...
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() => prediction = 'Predicted GPA: ${data['predicted_gpa']}');
        } else {
          throw Exception('Server responded with ${response.statusCode}');
        }
      } catch (e) {
        setState(() => prediction = 'Error: ${e.toString()}');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GPA Prediction')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              // Add other form fields...
              
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : predictGpa,
                child: isLoading 
                    ? CircularProgressIndicator()
                    : Text('PREDICT GPA'),
              ),
              SizedBox(height: 20),
              Text(prediction, style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    ageController.dispose();
    expectationsController.dispose();
    super.dispose();
  }
}