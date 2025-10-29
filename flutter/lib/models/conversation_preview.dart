class ConversationPreview {
  final String contactId; // l’autre participant
  final String name; // nom de l’autre participant
  final String avatarUrl; // avatar de l’autre participant
  final String lastText; // dernier message
  final DateTime? lastSentAt; // date/heure du dernier message
  final String conversationId;

  ConversationPreview({
    required this.contactId,
    required this.name,
    required this.avatarUrl,
    required this.lastText,
    required this.lastSentAt,
    required this.conversationId,
  });
}
