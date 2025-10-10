class Message {
  final String id;
  final String fromId;
  final String toId;
  final String text;
  final DateTime sentAt;

  Message({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.text,
    required this.sentAt,
  });
}
