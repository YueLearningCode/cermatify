class Mentor {
  final String id;
  final String name;
  final String kampus;
  final String jurusan;
  final String layanan;
  final String image;
  final String email;
  final String bio;
  final double rating;
  final int totalSessions;

  Mentor({
    required this.id,
    required this.name,
    required this.kampus,
    required this.jurusan,
    required this.layanan,
    required this.image,
    required this.email,
    required this.bio,
    required this.rating,
    required this.totalSessions,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['id'] as String,
      name: json['name'] as String,
      kampus: json['kampus'] as String,
      jurusan: json['jurusan'] as String,
      layanan: json['layanan'] as String,
      image: json['image'] as String,
      email: json['email'] as String,
      bio: json['bio'] as String,
      rating: (json['rating'] as num).toDouble(),
      totalSessions: json['totalSessions'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kampus': kampus,
      'jurusan': jurusan,
      'layanan': layanan,
      'image': image,
      'email': email,
      'bio': bio,
      'rating': rating,
      'totalSessions': totalSessions,
    };
  }
}
