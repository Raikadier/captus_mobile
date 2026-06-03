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
  final int memberCount;
  final int pendingTasks;
  final DateTime lastActivity;
  final String inviteCode;
  final bool isJoined;
  final String? userId;

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
    required this.inviteCode,
    this.isJoined = false,
    this.userId,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id']?.toString() ?? '',
      name: json['title']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      courseId: json['courseId']?.toString(),
      courseName: json['courseName']?.toString(),
      memberCount: (json['memberCount'] as int?) ?? 0,
      pendingTasks: (json['pendingTasks'] as int?) ?? 0,
      isJoined: (json['isJoined'] == 1) || (json['isJoined'] == true),
      userId: json['userId']?.toString(),
      inviteCode: json['inviteCode']?.toString() ?? '',
      lastActivity: json['lastActivity'] != null
          ? DateTime.tryParse(json['lastActivity'].toString()) ?? DateTime.now()
          : DateTime.now(),
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
