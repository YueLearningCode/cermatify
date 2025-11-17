import 'package:get/get.dart';

class FaqController extends GetxController {
  final List<Map<String, String>> faqs = const [
    {
      'question': 'Apa itu program mentoring Cermat Paper?',
      'answer':
          'Cermat Paper adalah program mentoring yang membantu mahasiswa dan peneliti mengembangkan karya ilmiah dengan bimbingan mentor berpengalaman.',
    },
    {
      'question': 'Bagaimana cara saya menemukan mentor yang sesuai?',
      'answer':
          'Kamu bisa memilih mentor berdasarkan bidang minat di halaman Beranda, lalu melihat profil mereka sebelum memulai sesi chat atau mentoring.',
    },
    {
      'question': 'Apakah program ini gratis?',
      'answer':
          'Sebagian fitur Cermat Paper dapat diakses secara gratis, namun beberapa mentor mungkin memiliki tarif mentoring yang ditentukan secara individual.',
    },
    {
      'question': 'Bagaimana cara mengisi kuesioner setelah sesi mentoring?',
      'answer':
          'Kuesioner bisa diakses melalui menu "Kuesioner" di bawah. Kamu cukup isi feedback sesuai pengalaman mentoring yang telah dijalani.',
    },
    {
      'question': 'Apakah data saya aman di aplikasi ini?',
      'answer':
          'Ya, semua data pengguna dan hasil kuesioner disimpan secara aman menggunakan sistem autentikasi dan enkripsi berbasis Firebase.',
    },
  ];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
