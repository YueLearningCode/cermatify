import 'package:intl/intl.dart';

/// [AppFormat] adalah class utilitas untuk memformat berbagai tipe data,
/// seperti angka, harga, dan tanggal, dengan dukungan untuk simbol mata uang
/// yang dinamis berdasarkan pengaturan aplikasi.
class AppFormats {
  /// Memformat harga panjang dengan simbol mata uang dinamis.
  /// Contoh hasil: "Rp 1.2jt".
  static String hargaPanjang(num harga) {
    // Mengakses simbol mata uang dari controller.

    return NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  /// Memformat harga pendek dengan simbol mata uang dinamis.
  /// Contoh hasil: "Rp 120.000".
  static String hargaPendek(num harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  /// Mengembalikan tanggal dalam format sederhana.
  /// Contoh hasil: "2023-02-10".
  static String justDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  /// Memformat tanggal berdasarkan sumber data (String atau DateTime).
  /// Format hasil: "Monday, 2 Jan 23".
  static String edMy(source) {
    switch (source.runtimeType) {
      case const (String):
        return DateFormat('EEEE, d MM yy', 'id_ID').format(DateTime.parse(source));
      case const (DateTime):
        return DateFormat('EEEE, d MM yy', 'id_ID').format(source);
      default:
        return 'not valid';
    }
  }

  /// Memformat tanggal dengan format lengkap.
  /// Format hasil: "Monday, 2 January 2023".
  static String fulledMy(source) {
    switch (source.runtimeType) {
      case const (String):
        return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.parse(source));
      case const (DateTime):
        return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(source);
      default:
        return 'not valid';
    }
  }

  /// Memformat string tanggal menjadi format lokal.
  /// Contoh input: "2022-02-05".
  /// Contoh hasil: "5 Feb 2022".
  static String date(String stringDate) {
    DateTime dateTime = DateTime.parse(stringDate);
    return DateFormat('d MMM yyyy', 'id_ID').format(dateTime);
  }

  /// Memformat angka menjadi format mata uang dengan pilihan simbol.
  /// [withSymbol]: true jika ingin menyertakan simbol mata uang.
  /// Contoh hasil: "Rp 1.000,00".
  static String currency(String number, {required bool withSymbol}) {
    // Mengakses simbol mata uang dari controller.

    return NumberFormat.currency(
      decimalDigits: 2,
      locale: 'id_ID',
      symbol: withSymbol ? 'Rp ' : '', // Menyesuaikan simbol sesuai parameter.
    ).format(double.parse(number));
  }

  /// Memformat tanggal menjadi format "dd/MM/yyyy".
  /// Contoh hasil: "10/02/2023".
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Memformat tanggal dengan jam menjadi format "dd/MM/yyyy, hh:mm".
  /// Contoh hasil: "10/02/2023, 14:30".
  static String formatDateHours(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy, hh:mm').format(date);
  }
}
