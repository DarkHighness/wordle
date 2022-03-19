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
    );

Map<String, dynamic> _$IdiomToJson(Idiom instance) => <String, dynamic>{
      'hash': instance.hash,
      'word': instance.word,
      'pinyin': instance.pinyin,
      'explanation': instance.explanation,
      'derivation': instance.derivation,
    };

IdiomLog _$IdiomLogFromJson(Map<String, dynamic> json) => IdiomLog(
      (json['log'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$IdiomLogToJson(IdiomLog instance) => <String, dynamic>{
      'log': instance.log,
    };

IdiomStatus _$IdiomStatusFromJson(Map<String, dynamic> json) => IdiomStatus(
      json['hash'] as String,
      (json['logs'] as List<dynamic>)
          .map((e) => IdiomLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$IdiomStatusToJson(IdiomStatus instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'logs': instance.logs,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      (json['status'] as List<dynamic>)
          .map((e) => IdiomStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'status': instance.status,
    };
