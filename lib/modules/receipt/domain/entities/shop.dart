class Shop {
  final int? id;
  final String name;
  final String? address;
  final String? tel;

  const Shop({
    this.id,
    required this.name,
    this.address,
    this.tel,
  });

  Shop copyWith({
    int? id,
    String? name,
    String? address,
    String? tel,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      tel: tel ?? this.tel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Shop && other.id == id && other.id != null;
  }

  @override
  int get hashCode => id.hashCode;
}

