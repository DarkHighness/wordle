import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'db.dart';
import 'model.dart';

Future<IdiomDb> setupIdiomDb() async {
  final String idiomsJson = await rootBundle.loadString("assets/idioms.json");
  final List<Idiom> idiomList =
      List<Idiom>.from(jsonDecode(idiomsJson).map((e) => Idiom.fromJson(e)));

  return IdiomDb(idiomList);
}

Future<String> get localSavePath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get localUserDataFile async {
  final path = await localSavePath;

  return File('$path/user.json');
}

Future<void> saveUserData(UserData userData) async {
  var jsonString = jsonEncode(userData);

  var file = await localUserDataFile;

  await file.writeAsString(jsonString);
}

Future<UserData> loadUserData() async {
  var file = await localUserDataFile;

  var exists = await file.exists();

  if (!exists) {
    return UserData([], 0, false);
  } else {
    var jsonString = await file.readAsString();

    return UserData.fromJson(jsonDecode(jsonString));
  }
}
