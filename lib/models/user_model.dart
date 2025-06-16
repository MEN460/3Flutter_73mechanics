class UserModel {
  final int id;
  final String username;
  final String email;
  final String userType;
  final String? phone;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? avatarUrl;
  final String? specialization;
  final double? rating;
  final double? distance;
  final bool isOnline;
  final DateTime? lastActiveAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.userType,
    this.phone,
    this.currentLatitude,
    this.currentLongitude,
    this.avatarUrl,
    this.specialization,
    this.rating,
    this.distance,
    this.isOnline = false,
    this.lastActiveAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username']?.toString() ?? 'Unknown User',
      email: (json['email'] ?? '').toString(),
      userType: (json['user_type'] ?? '').toString(),
      phone: json['phone']?.toString(),
      currentLatitude: _safeDouble(json['current_latitude']),
      currentLongitude: _safeDouble(json['current_longitude']),
      avatarUrl: json['avatar_url'],
      specialization: json['specialization'],
      rating: _safeDouble(json['rating']),
      distance: _safeDouble(json['distance']),
      isOnline: json['is_online'] ?? false,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'])
          : null,
    );
  }

  static double? _safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? userType,
    String? phone,
    double? currentLatitude,
    double? currentLongitude,
    String? avatarUrl,
    String? specialization,
    double? rating,
    double? distance,
    bool isOnline = false,
    DateTime? lastActiveAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      specialization: specialization ?? this.specialization,
      rating: rating ?? this.rating,
      distance: distance ?? this.distance,
      isOnline: isOnline,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}
