// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProblemModel _$ProblemModelFromJson(Map<String, dynamic> json) => ProblemModel(
      json['hash'] as String,
      json['word'] as String,
      json['pinyin'] as String,
      json['explanation'] as String,
      json['derivation'] as String,
      json['type'] as String,
      json['difficulty'] as String,
      (json['similar'] as List<dynamic>).map((e) => e as String).toList(),
      json['freq'] as int,
    );

Map<String, dynamic> _$ProblemModelToJson(ProblemModel instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'word': instance.word,
      'pinyin': instance.pinyin,
      'explanation': instance.explanation,
      'derivation': instance.derivation,
      'type': instance.type,
      'difficulty': instance.difficulty,
      'freq': instance.freq,
      'similar': instance.similar,
    };
