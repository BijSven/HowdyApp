import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const FlutterSecureStorage storage = FlutterSecureStorage();

Future<bool> removeToken() async {
  storage.deleteAll();
  return true;
}

Future<String?> getToken() async {
  return await storage.read(key: 'token');
}