class UserModel {
  final String id;
  final String name;
  final String email;
  final String? bio;
  final String? gender;
  final int? age;
  final String? profilePhoto;
  final double? latitude;
  final double? longitude;
  final bool isOnline;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.gender,
    this.age,
    this.profilePhoto,
    this.latitude,
    this.longitude,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'],
      gender: json['gender'],
      age: json['age'],
      profilePhoto: json['profilePhoto'] ?? json['profile_photo'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isOnline: json['isOnline'] ?? json['is_online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'gender': gender,
      'age': age,
      'profilePhoto': profilePhoto,
      'latitude': latitude,
      'longitude': longitude,
      'isOnline': isOnline,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? bio,
    String? gender,
    int? age,
    String? profilePhoto,
    double? latitude,
    double? longitude,
    bool? isOnline,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
