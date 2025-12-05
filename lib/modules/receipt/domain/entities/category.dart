class Category {
  final int? id;
  final String name;
  final String? color; // Optional color code for the category

  const Category({
    this.id,
    required this.name,
    this.color,
  });

  Category copyWith({
    int? id,
    String? name,
    String? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id && other.id != null;
  }

  @override
  int get hashCode => id.hashCode;
}

