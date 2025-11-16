import 'package:cermatify/app/data/models/chat_model.dart';

final List<ChatMessage> dummyChats = [
  ChatMessage(
    id: 'c1',
    senderId: 'u1',
    receiverId: 'm1',
    message: 'Halo, saya ingin bertanya tentang bimbingan paper',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  ChatMessage(
    id: 'c2',
    senderId: 'm1',
    receiverId: 'u1',
    message: 'Halo! Tentu, saya akan membantu Anda. Silakan jelaskan topik paper Anda',
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
  ),
  ChatMessage(
    id: 'c3',
    senderId: 'u1',
    receiverId: 'm1',
    message: 'Saya sedang menulis paper tentang machine learning',
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
  ),
  ChatMessage(
    id: 'c4',
    senderId: 'm1',
    receiverId: 'u1',
    message: 'Bagus! Machine learning adalah topik yang menarik. Bagian mana yang ingin Anda diskusikan?',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  ChatMessage(
    id: 'c5',
    senderId: 'u1',
    receiverId: 'm2',
    message: 'Apakah ada beasiswa yang tersedia untuk semester ini?',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ChatMessage(
    id: 'c6',
    senderId: 'm2',
    receiverId: 'u1',
    message: 'Ya, ada beberapa beasiswa yang bisa Anda daftar. Saya akan kirimkan informasinya',
    timestamp: DateTime.now().subtract(const Duration(hours: 23)),
  ),
  ChatMessage(
    id: 'c7',
    senderId: 'u1',
    receiverId: 'm3',
    message: 'Terima kasih atas bimbingannya kemarin',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
  ),
  ChatMessage(
    id: 'c8',
    senderId: 'm3',
    receiverId: 'u1',
    message: 'Sama-sama! Semoga paper Anda berjalan lancar',
    timestamp: DateTime.now().subtract(const Duration(days: 2, hours: -1)),
  ),
];
