class MessageModel {
  final String id;
  final String text;
  final String sender;
  final String timestamp; // ISO string
  bool isSynced;

  MessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'sender': sender,
        'timestamp': timestamp,
        'isSynced': isSynced,
      };

  factory MessageModel.fromMap(Map map) {
    return MessageModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      sender: map['sender'] ?? 'you',
      timestamp: map['timestamp'] ?? DateTime.now().toUtc().toIso8601String(),
      isSynced: map['isSynced'] ?? false,
    );
  }
}
