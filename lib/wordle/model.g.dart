// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Idiom _$IdiomFromJson(Map<String, dynamic> json) => Idiom(
      json['hash'] as String,
      json['word'] as String,
      json['pinyin'] as String,
      json['explanation'] as String,
      json['derivation'] as String,
      json['type'] as String,
    );

Map<String, dynamic> _$IdiomToJson(Idiom instance) => <String, dynamic>{
      'hash': instance.hash,
      'word': instance.word,
      'pinyin': instance.pinyin,
      'explanation': instance.explanation,
      'derivation': instance.derivation,
      'type': instance.type,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      (json['solved'] as List<dynamic>).map((e) => e as String).toList(),
      json['totalTries'] as int,
      json['hardMode'] as bool,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'solved': instance.solved,
      'totalTries': instance.totalTries,
      'hardMode': instance.hardMode,
    };
