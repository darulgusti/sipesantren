import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipesantren/core/models/weight_config_model.dart';
import 'package:sipesantren/core/repositories/weight_config_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sipesantren/core/providers/weight_config_provider.dart'; // New import

class WeightConfigPage extends ConsumerStatefulWidget {
  const WeightConfigPage({super.key});

  @override
  ConsumerState<WeightConfigPage> createState() => _WeightConfigPageState();
}

class _WeightConfigPageState extends ConsumerState<WeightConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'tahfidz': TextEditingController(),
    'fiqh': TextEditingController(),
    'bahasaArab': TextEditingController(),
    'akhlak': TextEditingController(),
    'kehadiran': TextEditingController(),
  };

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveWeights() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final repo = ref.read(weightConfigRepositoryProvider);

      try {
        final newConfig = WeightConfigModel(
          id: 'grading_weights', // Fixed ID as defined in repository
          tahfidz: double.parse(_controllers['tahfidz']!.text),
          fiqh: double.parse(_controllers['fiqh']!.text),
          bahasaArab: double.parse(_controllers['bahasaArab']!.text),
          akhlak: double.parse(_controllers['akhlak']!.text),
          kehadiran: double.parse(_controllers['kehadiran']!.text),
        );
        await repo.updateWeightConfig(newConfig);
        Fluttertoast.showToast(msg: "Weights updated successfully!");
        Navigator.of(context).pop(); // Go back after saving
      } catch (e) {
        Fluttertoast.showToast(msg: "Failed to update weights: $e");
      }
    }
  }

  String? _weightValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a weight';
    }
    final double? weight = double.tryParse(value);
    if (weight == null || weight < 0 || weight > 1) {
      return 'Weight must be a number between 0 and 1';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final weightConfigAsync = ref.watch(weightConfigStreamProvider); // Use the new StreamProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Scoring Weights'),
      ),
      body: weightConfigAsync.when(
        data: (config) {
          // Initialize controllers with current data only if they are empty
          // Ensure we don't overwrite user input if they are editing
          if (_controllers['tahfidz']!.text.isEmpty) {
             _controllers['tahfidz']!.text = config.tahfidz.toString();
             _controllers['fiqh']!.text = config.fiqh.toString();
             _controllers['bahasaArab']!.text = config.bahasaArab.toString();
             _controllers['akhlak']!.text = config.akhlak.toString();
             _controllers['kehadiran']!.text = config.kehadiran.toString();
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildWeightInput('Tahfidz', _controllers['tahfidz']!),
                _buildWeightInput('Fiqh', _controllers['fiqh']!),
                _buildWeightInput('Bahasa Arab', _controllers['bahasaArab']!),
                _buildWeightInput('Akhlak', _controllers['akhlak']!),
                _buildWeightInput('Kehadiran', _controllers['kehadiran']!),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveWeights,
                  child: const Text('Save Weights'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildWeightInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: _weightValidator,
        onSaved: (value) => controller.text = value!,
      ),
    );
  }
}
