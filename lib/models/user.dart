class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatar;
  final String role;
  final bool isVerified;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.avatar = '',
    this.role = 'customer',
    this.isVerified = true,
  });

  String get firstName => fullName.trim().split(' ').first;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? json['profileImage'] ?? json['image'] ?? '',
      role: json['role'] ?? 'customer',
      isVerified: json['isVerified'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'avatar': avatar,
    'role': role,
    'isVerified': isVerified,
  };
}
