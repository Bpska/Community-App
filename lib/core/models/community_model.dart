class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String? logo;
  final String? cover;
  final String category;
  final String type; // public, private
  final double radius;
  final int membersCount;
  final bool isJoined;
  final bool isPendingRequest;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    this.logo,
    this.cover,
    required this.category,
    required this.type,
    this.radius = 2.0,
    this.membersCount = 0,
    this.isJoined = false,
    this.isPendingRequest = false,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'],
      cover: json['cover'],
      category: json['category'] ?? '',
      type: json['type'] ?? 'public',
      radius: json['radius']?.toDouble() ?? 2.0,
      membersCount: json['membersCount'] ?? json['members_count'] ?? 0,
      isJoined: json['isJoined'] ?? json['is_joined'] ?? false,
      isPendingRequest: json['isPendingRequest'] ?? json['is_pending_request'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'cover': cover,
      'category': category,
      'type': type,
      'radius': radius,
      'membersCount': membersCount,
      'isJoined': isJoined,
      'isPendingRequest': isPendingRequest,
    };
  }

  CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logo,
    String? cover,
    String? category,
    String? type,
    double? radius,
    int? membersCount,
    bool? isJoined,
    bool? isPendingRequest,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      cover: cover ?? this.cover,
      category: category ?? this.category,
      type: type ?? this.type,
      radius: radius ?? this.radius,
      membersCount: membersCount ?? this.membersCount,
      isJoined: isJoined ?? this.isJoined,
      isPendingRequest: isPendingRequest ?? this.isPendingRequest,
    );
  }
}
