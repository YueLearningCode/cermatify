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
  final String? status; // waiting verification, approved, rejected
  final String? orderId; // Link to order document
  final String? userId; // User who created the kuesioner
  final String? link; // Link to the questionnaire form
  final String? rentangUsia; // Criteria: age range
  final String? jenisKelamin; // Criteria: gender
  final String? tingkatPenghasilan; // Criteria: income level
  final String? pendidikanTerakhir; // Criteria: education level

  Kuesioner({
    required this.id,
    required this.createdAt,
    required this.answers,
    this.status,
    this.orderId,
    this.userId,
    this.link,
    this.rentangUsia,
    this.jenisKelamin,
    this.tingkatPenghasilan,
    this.pendidikanTerakhir,
  });

  factory Kuesioner.fromJson(Map<String, dynamic> json, String docId) {
    return Kuesioner(
      id: docId,
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : (json['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      answers:
          (json['answers'] as List?)?.map((item) => QuestionAnswer.fromJson(item as Map<String, dynamic>)).toList() ??
          [],
      status: json['status'] as String?,
      orderId: json['orderId'] as String?,
      userId: json['userId'] as String? ?? json['createdBy'] as String?,
      link: json['link'] as String?,
      rentangUsia: json['rentangUsia'] as String?,
      jenisKelamin: json['jenisKelamin'] as String?,
      tingkatPenghasilan: json['tingkatPenghasilan'] as String?,
      pendidikanTerakhir: json['pendidikanTerakhir'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'answers': answers.map((qa) => qa.toJson()).toList(),
      'status': status,
      'orderId': orderId,
      'userId': userId,
      'link': link,
      'rentangUsia': rentangUsia,
      'jenisKelamin': jenisKelamin,
      'tingkatPenghasilan': tingkatPenghasilan,
      'pendidikanTerakhir': pendidikanTerakhir,
    };
  }
}
