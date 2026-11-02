abstract final class AccountPolicy {
  static const version = '2026-11-01';
  static bool isActive(Map<String, dynamic>? data) =>
      data?['status'] == 'active' && data?['accountStatus'] != 'disabled';
  static bool hasConsent(Map<String, dynamic>? data) =>
      data?['adultConfirmed'] == true &&
      data?['termsVersion'] == version &&
      data?['termsAcceptedAt'] != null;
  static bool canUseAccount(Map<String, dynamic>? data) =>
      isActive(data) &&
      (data?['role'] != 'mentor' || data?['verificationStatus'] == 'verified');
}
