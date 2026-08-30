enum UserRole {
  customer,
  vendor,
  rider,
  admin,
  superAdmin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'vendor':
        return UserRole.vendor;
      case 'rider':
        return UserRole.rider;
      case 'admin':
        return UserRole.admin;
      case 'super_admin':
      case 'superadmin':
        return UserRole.superAdmin;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  String toDbString() {
    switch (this) {
      case UserRole.vendor:
        return 'vendor';
      case UserRole.rider:
        return 'rider';
      case UserRole.admin:
        return 'admin';
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.customer:
        return 'customer';
    }
  }
}

class UserProfile {
  final String id;
  final String phone;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.phone,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      phone: json['phone'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'User',
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'customer'),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role.toDbString(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
