import 'package:flutter/material.dart';
import '../models/category_model.dart';

class DefaultCategories {
  static final List<CategoryModel> categories = [
    CategoryModel(
      id: 1,
      name: 'طعام ومشروبات',
      iconCode: Icons.restaurant.codePoint,
      colorValue: 0xFFEF4444, // Red
      isDefault: true,
    ),
    CategoryModel(
      id: 2,
      name: 'سكن وفواتير',
      iconCode: Icons.home_rounded.codePoint,
      colorValue: 0xFF3B82F6, // Blue
      isDefault: true,
    ),
    CategoryModel(
      id: 3,
      name: 'مواصلات وسيارة',
      iconCode: Icons.directions_car_rounded.codePoint,
      colorValue: 0xFFF59E0B, // Amber Gold
      isDefault: true,
    ),
    CategoryModel(
      id: 4,
      name: 'صحة وعلاج',
      iconCode: Icons.medical_services_rounded.codePoint,
      colorValue: 0xFF10B981, // Emerald Green
      isDefault: true,
    ),
    CategoryModel(
      id: 5,
      name: 'تسوق وملابس',
      iconCode: Icons.shopping_bag_rounded.codePoint,
      colorValue: 0xFF8B5CF6, // Purple
      isDefault: true,
    ),
    CategoryModel(
      id: 6,
      name: 'ترفيه ومصروفات عامة',
      iconCode: Icons.celebration_rounded.codePoint,
      colorValue: 0xFFEC4899, // Pink
      isDefault: true,
    ),
  ];
}
