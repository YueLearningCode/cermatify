import 'package:cermatify/app/data/models/kuesioner_model.dart';

final List<Kuesioner> dummyKuesioner = [
  Kuesioner(
    id: 'k1',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    answers: [
      QuestionAnswer(
        question: 'Bagaimana pengalaman Anda menggunakan platform ini?',
        answer: 'Sangat baik, platform ini sangat membantu dalam proses belajar saya.',
      ),
      QuestionAnswer(
        question: 'Apakah fitur yang tersedia sudah memenuhi kebutuhan Anda?',
        answer: 'Ya, fitur-fitur yang ada sudah cukup lengkap untuk kebutuhan saya.',
      ),
      QuestionAnswer(
        question: 'Bagaimana tingkat kepuasan Anda dengan layanan mentor?',
        answer: 'Sangat puas, mentor memberikan bimbingan yang sangat membantu.',
      ),
    ],
  ),
  Kuesioner(
    id: 'k2',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    answers: [
      QuestionAnswer(
        question: 'Seberapa sering Anda menggunakan platform ini?',
        answer: 'Saya menggunakan platform ini hampir setiap hari untuk belajar.',
      ),
      QuestionAnswer(
        question: 'Fitur apa yang paling sering Anda gunakan?',
        answer: 'Saya paling sering menggunakan fitur Cermat Paper untuk bimbingan penulisan paper.',
      ),
      QuestionAnswer(
        question: 'Apakah ada saran untuk pengembangan platform?',
        answer: 'Mungkin bisa ditambahkan fitur notifikasi untuk reminder jadwal bimbingan.',
      ),
    ],
  ),
  Kuesioner(
    id: 'k3',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    answers: [
      QuestionAnswer(
        question: 'Bagaimana kualitas bimbingan yang Anda terima?',
        answer: 'Kualitas bimbingan sangat baik dan mentor sangat responsif.',
      ),
      QuestionAnswer(
        question: 'Apakah Anda akan merekomendasikan platform ini kepada teman?',
        answer: 'Tentu saja, saya sudah merekomendasikan ke beberapa teman.',
      ),
    ],
  ),
];
