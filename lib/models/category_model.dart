import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String name;
  final int iconCode;
  final int colorValue;
  final bool isDefault;

  CategoryModel({
    this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.isDefault = false,
  });

  IconData get iconData => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon_code': iconCode,
      'color_value': colorValue,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconCode: map['icon_code'] as int,
      colorValue: map['color_value'] as int,
      isDefault: (map['is_default'] as int?) == 1,
    );
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    int? iconCode,
    int? colorValue,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
