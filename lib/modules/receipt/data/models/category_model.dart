import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({super.id, required super.name, super.color});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'color': color};
  }

  Map<String, dynamic> toDatabaseJson() {
    return {'id': id, 'name': name, 'color': color};
  }

  factory CategoryModel.fromDatabaseJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String?,
    );
  }
}




