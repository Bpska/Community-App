import '../config/app_config.dart';

class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String? logo;
  final String? cover;
  final String category;
  final String type; // public, private
  final double radius;
  final double? latitude;
  final double? longitude;
  final int membersCount;
  final bool isJoined;
  final bool isPendingRequest;
  final String? createdBy;
  final String? creatorName;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    this.logo,
    this.cover,
    required this.category,
    required this.type,
    this.radius = 2.0,
    this.latitude,
    this.longitude,
    this.membersCount = 0,
    this.isJoined = false,
    this.isPendingRequest = false,
    this.createdBy,
    this.creatorName,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logo: AppConfig.resolveMediaUrl(json['logo']),
      cover: AppConfig.resolveMediaUrl(json['cover']),
      category: json['category'] ?? '',
      type: json['type'] ?? 'public',
      radius: json['radius'] != null ? (double.tryParse(json['radius'].toString()) ?? 2.0) : 2.0,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      membersCount: json['membersCount'] ?? json['memberCount'] ?? json['members_count'] ?? json['member_count'] ?? 0,
      isJoined: json['isJoined'] ?? json['is_joined'] ?? json['isMember'] ?? json['is_member'] ?? false,
      isPendingRequest: json['isPendingRequest'] ?? json['is_pending_request'] ?? false,
      createdBy: json['createdBy']?.toString() ?? json['created_by']?.toString(),
      creatorName: json['creatorName'] ?? json['creator_name'],
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
      'latitude': latitude,
      'longitude': longitude,
      'membersCount': membersCount,
      'isJoined': isJoined,
      'isPendingRequest': isPendingRequest,
      'createdBy': createdBy,
      'creatorName': creatorName,
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
    double? latitude,
    double? longitude,
    int? membersCount,
    bool? isJoined,
    bool? isPendingRequest,
    String? createdBy,
    String? creatorName,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      membersCount: membersCount ?? this.membersCount,
      isJoined: isJoined ?? this.isJoined,
      isPendingRequest: isPendingRequest ?? this.isPendingRequest,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
    );
  }
}

