import 'package:flutter/material.dart';
import 'package:sipesantren/core/models/santri_model.dart';
import 'package:sipesantren/core/repositories/santri_repository.dart';

class SantriFormPage extends StatefulWidget {
  final SantriModel? santri; // Optional: if provided, it's an edit operation

  const SantriFormPage({super.key, this.santri});

  @override
  State<SantriFormPage> createState() => _SantriFormPageState();
}

class _SantriFormPageState extends State<SantriFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nisController = TextEditingController();
  final _namaController = TextEditingController();
  final _kamarController = TextEditingController();
  final _angkatanController = TextEditingController();
  final SantriRepository _repository = SantriRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.santri != null) {
      _nisController.text = widget.santri!.nis;
      _namaController.text = widget.santri!.nama;
      _kamarController.text = widget.santri!.kamar;
      _angkatanController.text = widget.santri!.angkatan.toString();
    }
  }

  @override
  void dispose() {
    _nisController.dispose();
    _namaController.dispose();
    _kamarController.dispose();
    _angkatanController.dispose();
    super.dispose();
  }

  Future<void> _saveSantri() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (widget.santri == null) {
          // Add new santri
          final newSantri = SantriModel(
            id: '', // Firestore auto-id
            nis: _nisController.text,
            nama: _namaController.text,
            kamar: _kamarController.text,
            angkatan: int.tryParse(_angkatanController.text) ?? DateTime.now().year,
          );
          await _repository.addSantri(newSantri);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Santri berhasil ditambahkan')),
            );
          }
        } else {
          // Update existing santri
          final updatedSantri = SantriModel(
            id: widget.santri!.id,
            nis: _nisController.text,
            nama: _namaController.text,
            kamar: _kamarController.text,
            angkatan: int.tryParse(_angkatanController.text) ?? DateTime.now().year,
          );
          await _repository.updateSantri(updatedSantri);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Santri berhasil diperbarui')),
            );
          }
        }
        if (mounted) {
          Navigator.pop(context); // Go back to SantriListPage
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.santri == null ? 'Tambah Santri' : 'Edit Santri'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nisController,
                decoration: const InputDecoration(
                  labelText: 'NIS',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIS tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kamarController,
                decoration: const InputDecoration(
                  labelText: 'Kamar',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kamar tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _angkatanController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Angkatan (Tahun)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Angkatan tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Angkatan harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSantri,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(widget.santri == null ? 'SIMPAN' : 'PERBARUI'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
