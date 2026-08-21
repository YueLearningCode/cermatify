class ApiConstant {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cermatify.my.id/api/v1');

  static const String baseUrlImage = String.fromEnvironment('IMAGE_BASE_URL', defaultValue: 'https://cermatify.my.id/');
}
