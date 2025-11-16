class QuestionAnswer {
  final String question;
  final String answer;

  QuestionAnswer({required this.question, required this.answer});

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAnswer(question: json['question'] as String, answer: json['answer'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'question': question, 'answer': answer};
  }
}

class Kuesioner {
  final String id;
  final DateTime createdAt;
  final List<QuestionAnswer> answers;

  Kuesioner({required this.id, required this.createdAt, required this.answers});

  factory Kuesioner.fromJson(Map<String, dynamic> json) {
    return Kuesioner(
      id: json['id'] as String,
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.parse(json['createdAt'] as String),
      answers: (json['answers'] as List).map((item) => QuestionAnswer.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'createdAt': createdAt.toIso8601String(), 'answers': answers.map((qa) => qa.toJson()).toList()};
  }
}
