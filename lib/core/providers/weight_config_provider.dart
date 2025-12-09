import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipesantren/core/models/weight_config_model.dart';
import 'package:sipesantren/core/repositories/weight_config_repository.dart';

final weightConfigStreamProvider = StreamProvider<WeightConfigModel>((ref) {
  final repository = ref.watch(weightConfigRepositoryProvider);
  return repository.getWeightConfig();
});
