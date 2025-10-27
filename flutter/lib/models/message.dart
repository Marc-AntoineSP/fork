class Message {
  final String id;
  final String authorId;
  final String text;
  final DateTime sentAt;

  Message({
    required this.id,
    required this.authorId,
    required this.text,
    required this.sentAt,
  });
}
