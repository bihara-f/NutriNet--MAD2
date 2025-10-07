import 'package:flutter/material.dart';
import 'dart:math';
import 'payment_page.dart';

class DietPlanPage extends StatefulWidget {
  const DietPlanPage({super.key});

  @override
  State<DietPlanPage> createState() => _DietPlanPageState();
}

class _DietPlanPageState extends State<DietPlanPage> {
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _mealsController = TextEditingController();
  final _waterController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _selectedBodyType = 'Average';
  final List<String> _selectedConditions = [];

  final List<String> _bodyTypes = ['Average', 'Plump', 'Extra'];
  final List<String> _healthConditions = [
    'Diabetes',
    'Cholesterol',
    'Low blood pressure',
    'High blood pressure',
    'None',
  ];

  double? _bmi;

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final heightCm = double.tryParse(_heightController.text);

    if (weight != null && heightCm != null && heightCm > 0) {
      final heightM = heightCm / 100;
      final bmi = weight / pow(heightM, 2);
      setState(() {
        _bmi = bmi;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('asset/logo.png', height: 32, width: 32),
            const SizedBox(width: 8),
            const Text(
              "NutriNet",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 9, 60, 77),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("1. Your age:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter your age",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter your age';
                  final age = int.tryParse(value);
                  if (age == null || age <= 0) return 'Enter a valid age';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text(
                "2. Current body type:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: _selectedBodyType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items:
                    _bodyTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() => _selectedBodyType = value!);
                },
              ),
              const SizedBox(height: 20),

              const Text(
                "3. Your health condition:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children:
                      _healthConditions.map((condition) {
                        return CheckboxListTile(
                          title: Text(condition),
                          value: _selectedConditions.contains(condition),
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedConditions.add(condition);
                              } else {
                                _selectedConditions.remove(condition);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
              if (_selectedConditions.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 5, left: 8),
                  child: Text(
                    "Select at least one condition (or 'None')",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              const Text("4. Meals per day:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _mealsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter meals per day",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter meals per day'
                            : null,
              ),
              const SizedBox(height: 20),

              const Text(
                "5. Water intake per day in Liters:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _waterController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter water intake per day",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter water intake'
                            : null,
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final formValid = _formKey.currentState!.validate();
                    final conditionValid = _selectedConditions.isNotEmpty;

                    if (formValid && conditionValid) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentPage(),
                        ),
                      );
                    } else if (!conditionValid) {
                      setState(
                        () {},
                      ); // Refresh to show warning under health section
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 21, 128, 147),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Divider(thickness: 2),

              const Text(
                "BMI Calculator",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Weight (kg)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Height (cm)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _weightController.clear();
                        _heightController.clear();
                        setState(() => _bmi = null);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(221, 255, 125, 4),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Reset"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _calculateBMI,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          21,
                          128,
                          147,
                        ),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Calculate"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 2),

              if (_bmi != null) ...[
                const Center(
                  child: Text(
                    "Your BMI is",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    _bmi!.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 211, 184, 31),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    _bmi! < 18.5
                        ? "Underweight"
                        : _bmi! < 25
                        ? "Normal"
                        : _bmi! < 30
                        ? "Overweight"
                        : "Obese",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
