import 'package:flutter/material.dart';

import 'mentor_detail_view.dart';

class UserDetailView extends StatelessWidget {
  const UserDetailView({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return AdminAccountDetailView(userId: userId, isMentor: false);
  }
}
