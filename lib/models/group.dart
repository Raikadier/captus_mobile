class GroupMember {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isAdmin;

  const GroupMember({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isAdmin = false,
  });
}

class GroupModel {
  final String id;
  final String name;
  final String? courseId;
  final String? courseName;
  final String? description;
  final List<GroupMember> members;
  /// Fallback member count when [members] is empty (API-only data).
  final int memberCount;
  final int pendingTasks;
  final DateTime lastActivity;
  final String inviteCode;

  const GroupModel({
    required this.id,
    required this.name,
    this.courseId,
    this.courseName,
    this.description,
    this.members = const [],
    this.memberCount = 0,
    this.pendingTasks = 0,
    required this.lastActivity,
    this.inviteCode = '',
  });

  /// Effective member count: prefers the [members] list length if populated,
  /// otherwise falls back to [memberCount].
  int get effectiveMemberCount =>
      members.isNotEmpty ? members.length : memberCount;

  /// Maps the Express API response from `GET /groups/my-groups`.
  ///
  /// Backend returns:
  /// ```json
  /// {
  ///   "id": "uuid",
  ///   "course_id": "uuid",
  ///   "name": "...",
  ///   "description": "...",
  ///   "created_by": "uuid",
  ///   "members": 3   // count (from aggregate)
  /// }
  /// ```
  factory GroupModel.fromApiJson(Map<String, dynamic> json) {
    // members can be int (count) or List (detail)
    final rawMembers = json['members'];
    List<GroupMember> members = [];
    int memberCount = 0;

    if (rawMembers is int) {
      memberCount = rawMembers;
    } else if (rawMembers is List) {
      members = rawMembers.map((m) {
        final map = m as Map<String, dynamic>;
        return GroupMember(
          id: map['student_id']?.toString() ?? map['id']?.toString() ?? '',
          name: map['name']?.toString() ?? 'Miembro',
          avatarUrl: map['avatar_url']?.toString(),
        );
      }).toList();
      memberCount = members.length;
    }

    // created_at from DB (ISO string) or fallback to now
    DateTime lastActivity = DateTime.now();
    final createdAt = json['created_at']?.toString();
    if (createdAt != null) {
      lastActivity = DateTime.tryParse(createdAt) ?? DateTime.now();
    }

    return GroupModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      courseId: json['course_id']?.toString(),
      courseName: json['course_name']?.toString() ??
          json['courses']?['title']?.toString(),
      description: json['description']?.toString(),
      members: members,
      memberCount: memberCount,
      pendingTasks: (json['pendingTasks'] as num?)?.toInt() ?? 0,
      lastActivity: lastActivity,
      inviteCode: json['invite_code']?.toString() ?? '',
    );
  }

  static List<GroupModel> get mockList => [
        GroupModel(
          id: 'g1',
          name: 'Grupo Proyecto Final',
          courseName: 'Ingeniería de Software I',
          members: [
            const GroupMember(id: '1', name: 'David Barceló', isAdmin: true),
            const GroupMember(id: '2', name: 'Isabella Manjarrez'),
            const GroupMember(id: '3', name: 'Harold Flórez'),
          ],
          pendingTasks: 3,
          lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
          inviteCode: 'GRP001',
        ),
        GroupModel(
          id: 'g2',
          name: 'Estudio Cálculo',
          courseName: 'Cálculo II',
          members: [
            const GroupMember(id: '1', name: 'David Barceló'),
            const GroupMember(id: '4', name: 'Valentina Molina', isAdmin: true),
          ],
          pendingTasks: 1,
          lastActivity: DateTime.now().subtract(const Duration(days: 1)),
          inviteCode: 'GRP002',
        ),
      ];
}
