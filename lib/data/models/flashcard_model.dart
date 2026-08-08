class FlashCard {
  final String id;
  final String question;
  final String answer;
  final String? hint;

  const FlashCard({
    required this.id,
    required this.question,
    required this.answer,
    this.hint,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'hint': hint,
    };
  }

  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      hint: json['hint'] as String?,
    );
  }
}
