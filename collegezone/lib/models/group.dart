class Group {
  String id;
  String name;
  List<String> memberIds;
  String createdBy;
  List<String> members;
  String createdAt;
  String? image; // Nullable image field

  Group({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.createdBy,
    required this.members,
    required this.createdAt,
    this.image,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json['id'],
    name: json['name'],
    memberIds: List<String>.from(json['memberIds']),
    createdBy: json['createdBy'],
    members: List<String>.from(json['members']),
    createdAt: json['createdAt'],
    image: json['image'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'memberIds': memberIds,
    'createdBy': createdBy,
    'members': members,
    'createdAt': createdAt,
    'image': image,
  };
}
