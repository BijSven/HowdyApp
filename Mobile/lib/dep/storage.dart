// ---
// Copyright © 2023 ORAE IBC. All Rights Reserved
// This file is limited to intergrating to the Secure Storage module. 
// ---

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();

Future<bool> write(String key, String value) async {
  try {
    print('[STORAGE] Writing data to $key. Please wait!');
    await _storage.write(key: key, value: value);
    print('[STORAGE] Written data to $key. Completed!');
    return true;
  } catch (e) {
    print('[STORAGE] Error writing data to $key: $e');
    return false;
  }
}

Future<String?> read(String key) async {
  try {
    print('[STORAGE] Reading data from $key. Please wait!');
    String? data = await _storage.read(key: key);
    if (data != null) {
      print('[STORAGE] Read data from $key. Completed!');
      return data;
    } else {
      print('[STORAGE] No data found for $key.');
      return null;
    }
  } catch (e) {
    print('[STORAGE] Error reading data from $key: $e');
    return null;
  }
}

Future<bool> edit(String key, String value) async {
  try {
    print('[STORAGE] Editing data for $key. Please wait!');
    await _storage.delete(key: key);
    await _storage.write(key: key, value: value);
    print('[STORAGE] Edited data for $key. Completed!');
    return true;
  } catch (e) {
    print('[STORAGE] Error editing data for $key: $e');
    return false;
  }
}

Future<bool> delete(String key) async {
  try {
    print('[STORAGE] Deleting data for $key. Please wait!');
    await _storage.delete(key: key);
    print('[STORAGE] Deleted data for $key. Completed!');
    return true;
  } catch (e) {
    print('[STORAGE] Error deleting data for $key: $e');
    return false;
  }
}