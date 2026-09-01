class MarketplaceCategory {
  final String id;
  final String slug;
  final String name;
  final String? nameUrdu;
  final String icon;
  final int displayOrder;
  final bool isActive;

  const MarketplaceCategory({
    required this.id,
    required this.slug,
    required this.name,
    this.nameUrdu,
    required this.icon,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory MarketplaceCategory.fromJson(Map<String, dynamic> json) {
    return MarketplaceCategory(
      id: json['id'] as String,
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameUrdu: json['name_urdu'] as String?,
      icon: json['icon'] as String? ?? 'shopping_bag',
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'name_urdu': nameUrdu,
      'icon': icon,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }

  MarketplaceCategory copyWith({
    String? id,
    String? slug,
    String? name,
    String? nameUrdu,
    String? icon,
    int? displayOrder,
    bool? isActive,
  }) {
    return MarketplaceCategory(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      nameUrdu: nameUrdu ?? this.nameUrdu,
      icon: icon ?? this.icon,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
