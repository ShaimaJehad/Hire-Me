class ChatDetailsModel {
  final String id;
  final String text;
  final String senderId;
  final DateTime time;
  final bool isRead;

  ChatDetailsModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.time,
    this.isRead = false,
  });

  factory ChatDetailsModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ChatDetailsModel(
      id: id,
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] ?? 0),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'time': time.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }
}
