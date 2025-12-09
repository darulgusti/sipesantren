import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipesantren/core/models/weight_config_model.dart';
import 'package:sipesantren/core/repositories/weight_config_repository.dart';

class WeightConfigPage extends ConsumerStatefulWidget {
  const WeightConfigPage({super.key});

  @override
  ConsumerState<WeightConfigPage> createState() => _WeightConfigPageState();
}

class _WeightConfigPageState extends ConsumerState<WeightConfigPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for weights
  final _tahfidzController = TextEditingController();
  final _fiqhController = TextEditingController();
  final _bahasaArabController = TextEditingController();
  final _akhlakController = TextEditingController();
  final _kehadiranController = TextEditingController();
  
  // Controller for settings
  final _maxSantriController = TextEditingController();

  bool _isLoading = true;
  WeightConfigModel? _currentConfig;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final _repository = ref.read(weightConfigRepositoryProvider);
    // Ensure initialized
    await _repository.initializeWeightConfig();
    
    _repository.getWeightConfig().listen((config) {
      if (mounted) {
        setState(() {
          _currentConfig = config;
          _tahfidzController.text = (config.tahfidz * 100).toStringAsFixed(0);
          _fiqhController.text = (config.fiqh * 100).toStringAsFixed(0);
          _bahasaArabController.text = (config.bahasaArab * 100).toStringAsFixed(0);
          _akhlakController.text = (config.akhlak * 100).toStringAsFixed(0);
          _kehadiranController.text = (config.kehadiran * 100).toStringAsFixed(0);
          _maxSantriController.text = config.maxSantriPerRoom.toString();
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tahfidzController.dispose();
    _fiqhController.dispose();
    _bahasaArabController.dispose();
    _akhlakController.dispose();
    _kehadiranController.dispose();
    _maxSantriController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      final _repository = ref.read(weightConfigRepositoryProvider);
      
      double t = double.parse(_tahfidzController.text) / 100;
      double f = double.parse(_fiqhController.text) / 100;
      double b = double.parse(_bahasaArabController.text) / 100;
      double a = double.parse(_akhlakController.text) / 100;
      double k = double.parse(_kehadiranController.text) / 100;
      int maxSantri = int.parse(_maxSantriController.text);

      double total = t + f + b + a + k;
      // Allow small epsilon error
      if ((total - 1.0).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Total bobot harus 100%. Saat ini: ${(total * 100).toStringAsFixed(0)}%')),
        );
        return;
      }

      final newConfig = WeightConfigModel(
        id: _currentConfig!.id,
        tahfidz: t,
        fiqh: f,
        bahasaArab: b,
        akhlak: a,
        kehadiran: k,
        maxSantriPerRoom: maxSantri,
      );

      await _repository.updateWeightConfig(newConfig);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konfigurasi berhasil disimpan')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfigurasi Aplikasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bobot Penilaian (%)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInput('Tahfidz', _tahfidzController),
              _buildInput('Fiqh', _fiqhController),
              _buildInput('Bahasa Arab', _bahasaArabController),
              _buildInput('Akhlak', _akhlakController),
              _buildInput('Kehadiran', _kehadiranController),
              
              const Divider(height: 32),
              
              const Text(
                'Pengaturan Asrama',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxSantriController,
                decoration: const InputDecoration(
                  labelText: 'Maksimal Santri per Kamar',
                  border: OutlineInputBorder(),
                  suffixText: 'orang',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harus diisi';
                  if (int.tryParse(value) == null) return 'Harus angka';
                  return null;
                },
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveConfig,
                  child: const Text('SIMPAN KONFIGURASI'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixText: '%',
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Harus diisi';
          if (double.tryParse(value) == null) return 'Harus angka';
          return null;
        },
      ),
    );
  }
}