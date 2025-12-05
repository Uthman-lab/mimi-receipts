import '../../domain/entities/shop.dart';

class ShopModel extends Shop {
  const ShopModel({
    super.id,
    required super.name,
    super.address,
    super.tel,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      address: json['address'] as String?,
      tel: json['tel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'tel': tel,
    };
  }

  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'tel': tel,
    };
  }

  factory ShopModel.fromDatabaseJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      tel: json['tel'] as String?,
    );
  }
}

