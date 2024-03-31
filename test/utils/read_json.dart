import 'dart:io';

String readJson(String name) {
  return File(name).readAsStringSync();
}
