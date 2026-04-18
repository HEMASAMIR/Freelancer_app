import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AdminEmailService {
  late final Set<String> _adminSet;

  AdminEmailService();

  /// Load admin emails from the JSON asset. Call this once during app startup.
  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/config/admin_emails.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final List<dynamic> emails = data['adminEmails'] ?? [];
    _adminSet = emails.map((e) => (e as String).toLowerCase().trim()).toSet();
  }

  bool isAdmin(String email) {
    return _adminSet.contains(email.toLowerCase().trim());
  }
}
