const mentorServiceTypes = ['complink', 'paperlink'];

/// Browse both fields before choosing a mentor role; keep unknown types out.
List<Map<String, String>> availableMentorServices(
  Iterable<Map<String, String>> services,
  String role,
) => services
    .where(
      (service) =>
          (service['id'] ?? '').isNotEmpty &&
          (service['name'] ?? '').trim().isNotEmpty &&
          mentorServiceTypes.contains(service['type']) &&
          (role.isEmpty || service['type'] == role),
    )
    .toList(growable: false);

/// A valid first service determines the role; later choices stay in that role.
String? mentorRoleForServiceSelection(
  Iterable<Map<String, String>> services,
  String serviceId,
  String currentRole,
) {
  for (final service in availableMentorServices(services, currentRole)) {
    if (service['id'] == serviceId) return service['type'];
  }
  return null;
}
