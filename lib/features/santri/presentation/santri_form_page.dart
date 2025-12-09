import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipesantren/core/models/santri_model.dart';
import 'package:sipesantren/core/repositories/santri_repository.dart';
import 'package:sipesantren/core/repositories/weight_config_repository.dart';

class SantriFormPage extends ConsumerStatefulWidget {
  final SantriModel? santri;

  const SantriFormPage({super.key, this.santri});

  @override
  ConsumerState<SantriFormPage> createState() => _SantriFormPageState();
}

class _SantriFormPageState extends ConsumerState<SantriFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nisController = TextEditingController();
  final _namaController = TextEditingController();
  final _angkatanController = TextEditingController();
  String _selectedBuilding = 'A';
  final _roomNumberController = TextEditingController();

  bool _isLoading = false;
  
  // Validation state
  String? _roomErrorText;
  bool _isRoomFull = false;
  int _maxCapacity = 6;

  @override
  void initState() {
    super.initState();
    if (widget.santri != null) {
      _nisController.text = widget.santri!.nis;
      _namaController.text = widget.santri!.nama;
      _selectedBuilding = widget.santri!.kamarGedung;
      _roomNumberController.text = widget.santri!.kamarNomor.toString();
      _angkatanController.text = widget.santri!.angkatan.toString();
    }
    _loadConfig();
    
    // Add listeners for dynamic validation
    _roomNumberController.addListener(_checkRoomCapacity);
  }

  Future<void> _loadConfig() async {
    final weightRepo = ref.read(weightConfigRepositoryProvider);
    await weightRepo.initializeWeightConfig(); // Ensure default
    final config = await weightRepo.getWeightConfig().first;
    if (mounted) {
      setState(() {
        _maxCapacity = config.maxSantriPerRoom;
      });
      // Check initial state if editing
      _checkRoomCapacity();
    }
  }

  @override
  void dispose() {
    _nisController.dispose();
    _namaController.dispose();
    _angkatanController.dispose();
    _roomNumberController.dispose();
    super.dispose();
  }

  Future<void> _checkRoomCapacity() async {
    if (_roomNumberController.text.isEmpty) {
      setState(() {
        _roomErrorText = null;
        _isRoomFull = false;
      });
      return;
    }

    final int? roomNum = int.tryParse(_roomNumberController.text);
    if (roomNum == null) return;

    final repository = ref.read(santriRepositoryProvider);
    final count = await repository.getSantriCountInRoom(_selectedBuilding, roomNum);

    bool isMovingOrNew = true;
    if (widget.santri != null) {
      // If editing and staying in same room
      if (widget.santri!.kamarGedung == _selectedBuilding && 
          widget.santri!.kamarNomor == roomNum) {
        isMovingOrNew = false;
      }
    }

    if (mounted) {
      setState(() {
        if (isMovingOrNew) {
          // Checking against capacity for a new entry in this room
          if (count >= _maxCapacity) {
            _isRoomFull = true;
            _roomErrorText = 'Kamar penuh ($count/$_maxCapacity)';
          } else {
            _isRoomFull = false;
            _roomErrorText = null; // 'Tersedia ($count/$_maxCapacity)'; // Optional: show available info
          }
        } else {
          // Staying in same room. Valid unless capacity dropped below current usage
          // Note: count includes this santri.
          if (count > _maxCapacity) {
             _isRoomFull = true; // Technically over capacity, but we allow saving to not lock them out? 
                                 // Or enforce rule? Let's enforce warning but maybe allow save if they don't change room?
                                 // Requirement says "max people... value". Usually implies strict limit.
             _roomErrorText = 'Over kapasitas ($count/$_maxCapacity)';
          } else {
             _isRoomFull = false;
             _roomErrorText = null;
          }
        }
      });
    }
  }

    Future<void> _saveSantri() async {

      // Final check before save

      await _checkRoomCapacity();

      if (_isRoomFull) return;

  

      final repository = ref.read(santriRepositoryProvider);

      if (_formKey.currentState!.validate()) {

        setState(() {

          _isLoading = true;

        });

  

        try {

          if (widget.santri == null) {

            // Add new santri

            final newSantri = SantriModel(

              id: '',

              nis: _nisController.text,

              nama: _namaController.text,

              kamarGedung: _selectedBuilding,

              kamarNomor: int.tryParse(_roomNumberController.text) ?? 0,

              angkatan: int.tryParse(_angkatanController.text) ?? DateTime.now().year,

            );

            await repository.addSantri(newSantri);

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

              kamarGedung: _selectedBuilding,

              kamarNomor: int.tryParse(_roomNumberController.text) ?? 0,

              angkatan: int.tryParse(_angkatanController.text) ?? DateTime.now().year,

            );

            await repository.updateSantri(updatedSantri);

            if (mounted) {

              ScaffoldMessenger.of(context).showSnackBar(

                const SnackBar(content: Text('Santri berhasil diperbarui')),

              );

            }

          }

          if (mounted) {

            Navigator.pop(context);

          }

        } catch (e) {

          if (mounted) {

            ScaffoldMessenger.of(context).showSnackBar(

              SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),

            );

          }

        } finally {

          if (mounted) {

            setState(() {

              _isLoading = false;

            });

          }

        }

      }

    }

  

    @override

    Widget build(BuildContext context) {

      return Scaffold(

        appBar: AppBar(

          title: Text(widget.santri == null ? 'Tambah Santri' : 'Edit Santri'),

          backgroundColor: Theme.of(context).colorScheme.primary,

          foregroundColor: Colors.white,

          elevation: 0,

        ),

        body: Padding(

          padding: const EdgeInsets.all(16.0),

          child: Form(

            key: _formKey,

            onChanged: () {

              // Trigger rebuild to update button state based on validation

              setState(() {}); 

            },

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                // NIS Input

                Container(

                  margin: const EdgeInsets.symmetric(vertical: 4),

                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

                  decoration: BoxDecoration(

                    color: Theme.of(context).cardColor,

                    borderRadius: BorderRadius.circular(15),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.grey.withValues(alpha: 0.1),

                        spreadRadius: 2,

                        blurRadius: 5,

                        offset: const Offset(0, 3),

                      ),

                    ],

                  ),

                  child: TextFormField(

                    controller: _nisController,

                    decoration: const InputDecoration(

                      labelText: 'NIS',

                      border: InputBorder.none,

                      contentPadding: EdgeInsets.zero,

                    ),

                    validator: (value) {

                      if (value == null || value.isEmpty) {

                        return 'NIS tidak boleh kosong';

                      }

                      return null;

                    },

                  ),

                ),

                const SizedBox(height: 12),

                

                // Name Input

                Container(

                  margin: const EdgeInsets.symmetric(vertical: 4),

                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

                  decoration: BoxDecoration(

                    color: Theme.of(context).cardColor,

                    borderRadius: BorderRadius.circular(15),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.grey.withValues(alpha: 0.1),

                        spreadRadius: 2,

                        blurRadius: 5,

                        offset: const Offset(0, 3),

                      ),

                    ],

                  ),

                  child: TextFormField(

                    controller: _namaController,

                    decoration: const InputDecoration(

                      labelText: 'Nama Lengkap',

                      border: InputBorder.none,

                      contentPadding: EdgeInsets.zero,

                    ),

                    validator: (value) {

                      if (value == null || value.isEmpty) {

                        return 'Nama tidak boleh kosong';

                      }

                      return null;

                    },

                  ),

                ),

                const SizedBox(height: 12),

                

                // Room Selection

                Container(

                  margin: const EdgeInsets.symmetric(vertical: 4),

                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

                  decoration: BoxDecoration(

                    color: Theme.of(context).cardColor,

                    borderRadius: BorderRadius.circular(15),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.grey.withValues(alpha: 0.1),

                        spreadRadius: 2,

                        blurRadius: 5,

                        offset: const Offset(0, 3),

                      ),

                    ],

                  ),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Row(

                        children: [

                          Expanded(

                            flex: 1,

                            child: DropdownButtonHideUnderline(

                              child: DropdownButton<String>(

                                isExpanded: true,

                                value: _selectedBuilding,

                                icon: const Icon(Icons.arrow_drop_down),

                                elevation: 16,

                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),

                                onChanged: (String? newValue) {

                                  setState(() {

                                    _selectedBuilding = newValue!;

                                  });

                                  _checkRoomCapacity();

                                },

                                items: <String>['A', 'B', 'C', 'D', 'E']

                                    .map<DropdownMenuItem<String>>((String value) {

                                  return DropdownMenuItem<String>(

                                    value: value,

                                    child: Text('Gedung $value'),

                                  );

                                }).toList(),

                              ),

                            ),

                          ),

                          const SizedBox(width: 12),

                          Expanded(

                            flex: 2,

                            child: TextFormField(

                              controller: _roomNumberController,

                              keyboardType: TextInputType.number,

                              decoration: const InputDecoration(

                                labelText: 'Nomor Kamar',

                                border: InputBorder.none,

                                contentPadding: EdgeInsets.zero,

                              ),

                              validator: (value) {

                                if (value == null || value.isEmpty) {

                                  return 'Nomor kamar tidak boleh kosong';

                                }

                                if (int.tryParse(value) == null) {

                                  return 'Nomor kamar harus angka';

                                }

                                return null;

                              },

                            ),

                          ),

                        ],

                      ),

                      if (_roomErrorText != null)

                        Padding(

                          padding: const EdgeInsets.only(top: 8.0),

                          child: Text(

                            _roomErrorText!,

                            style: TextStyle(

                              color: _isRoomFull ? Colors.red : Colors.green,

                              fontWeight: FontWeight.bold,

                              fontSize: 12,

                            ),

                          ),

                        ),

                    ],

                  ),

                ),

                const SizedBox(height: 12),

                

                // Angkatan Input

                Container(

                  margin: const EdgeInsets.symmetric(vertical: 4),

                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

                  decoration: BoxDecoration(

                    color: Theme.of(context).cardColor,

                    borderRadius: BorderRadius.circular(15),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.grey.withValues(alpha: 0.1),

                        spreadRadius: 2,

                        blurRadius: 5,

                        offset: const Offset(0, 3),

                      ),

                    ],

                  ),

                  child: TextFormField(

                    controller: _angkatanController,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(

                      labelText: 'Angkatan (Tahun)',

                      border: InputBorder.none,

                      contentPadding: EdgeInsets.zero,

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

                ),

                const SizedBox(height: 24),

                

                // Save Button

                ElevatedButton(

                  // Disable if loading, room is full, or form is invalid (checked via formKey state roughly or implicit check)

                  onPressed: (_isLoading || _isRoomFull || 

                              _nisController.text.isEmpty || 

                              _namaController.text.isEmpty ||

                              _roomNumberController.text.isEmpty ||

                              _angkatanController.text.isEmpty) ? null : _saveSantri,

                  style: ElevatedButton.styleFrom(

                    padding: const EdgeInsets.symmetric(vertical: 12),

                    backgroundColor: Theme.of(context).colorScheme.primary,

                    foregroundColor: Colors.white,

                    disabledBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(10),

                    ),

                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

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

  