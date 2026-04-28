import 'package:hive_flutter/hive_flutter.dart';
import '../models/evidence_item.dart';

class EvidenceLocalService {
  static const String boxName = 'evidences';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  Box get _box => Hive.box(boxName);

  List<EvidenceItem> getAll() {
    return _box.values
        .map((item) => EvidenceItem.fromMap(Map<String, dynamic>.from(item)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> save(EvidenceItem evidence) async {
    await _box.put(evidence.id, evidence.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}