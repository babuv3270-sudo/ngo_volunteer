Map<String, dynamic> firestoreDocMap(Object? data, {required String id}) {
  final Map<String, dynamic> map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  map['id'] = id;
  return map;
}