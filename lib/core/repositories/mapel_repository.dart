import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sipesantren/core/models/mapel_model.dart';

class MapelRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new Mapel
  Future<void> addMapel(MapelModel mapel) async {
    await _db.collection('mapel').add(mapel.toFirestore());
  }

  // Get a stream of all Mapel
  Stream<List<MapelModel>> getMapelList() {
    return _db.collection('mapel').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => MapelModel.fromFirestore(doc)).toList());
  }

  // Update an existing Mapel
  Future<void> updateMapel(MapelModel mapel) async {
    await _db.collection('mapel').doc(mapel.id).update(mapel.toFirestore());
  }

  // Delete a Mapel
  Future<void> deleteMapel(String mapelId) async {
    await _db.collection('mapel').doc(mapelId).delete();
  }
}
