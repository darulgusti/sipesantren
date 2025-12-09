import 'package:flutter/material.dart';
import 'package:sipesantren/core/models/mapel_model.dart';
import 'package:sipesantren/core/repositories/mapel_repository.dart';
import 'package:sipesantren/features/master_data/presentation/mapel_form_page.dart';

class MapelListPage extends StatefulWidget {
  const MapelListPage({super.key});

  @override
  State<MapelListPage> createState() => _MapelListPageState();
}

class _MapelListPageState extends State<MapelListPage> {
  final MapelRepository _repository = MapelRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Mata Pelajaran'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<MapelModel>>(
        stream: _repository.getMapelList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final mapelList = snapshot.data!;

          if (mapelList.isEmpty) {
            return const Center(child: Text('Belum ada mata pelajaran.'));
          }

          return ListView.builder(
            itemCount: mapelList.length,
            itemBuilder: (context, index) {
              final mapel = mapelList[index];
              return Dismissible(
                key: Key(mapel.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Konfirmasi Hapus"),
                        content: Text("Anda yakin ingin menghapus '${mapel.name}'?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("BATAL"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("HAPUS"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  await _repository.deleteMapel(mapel.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${mapel.name} berhasil dihapus')),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(mapel.name),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapelFormPage(mapel: mapel),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapelFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
