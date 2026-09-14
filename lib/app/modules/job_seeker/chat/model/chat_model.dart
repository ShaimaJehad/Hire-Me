class ChatModel {
  final String id;
  final String companyId;
  final String seekerId;
  final String jobId;
  final String companyName;
  final String seekerName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String avatarUrl;
  final String companyAvatarUrl;
  final String lastMessageAuthor;
  final int unreadSeeker;
  final int unreadCompany;

  ChatModel({
    required this.id,
    required this.companyId,
    required this.seekerId,
    required this.jobId,
    required this.companyName,
    required this.seekerName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.avatarUrl,
    this.companyAvatarUrl = '',
    this.lastMessageAuthor = '',
    this.unreadSeeker = 0,
    this.unreadCompany = 0,
  });

  factory ChatModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ChatModel(
      id: id,
      companyId: map['companyId'] ?? '',
      seekerId: map['seekerId'] ?? '',
      jobId: map['jobId'] ?? '',
      companyName: map['companyName'] ?? '',
      seekerName: map['seekerName'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(
        map['lastMessageTime'] ?? 0,
      ),
      avatarUrl: map['avatarUrl'] ?? '',
      companyAvatarUrl: map['companyAvatarUrl'] ?? '',
      lastMessageAuthor: map['lastMessageAuthor'] ?? '',
      unreadSeeker: map['unreadSeeker'] ?? 0,
      unreadCompany: map['unreadCompany'] ?? 0,
    );
  }

  String otherName(String currentUserId) {
    return currentUserId == seekerId ? companyName : seekerName;
  }

  String otherAvatarUrl(String currentUserId) {
    return currentUserId == seekerId ? companyAvatarUrl : avatarUrl;
  }

  int unreadFor(String userId) {
    if (userId == seekerId) return unreadSeeker;
    if (userId == companyId) return unreadCompany;
    return 0;
  }
}
