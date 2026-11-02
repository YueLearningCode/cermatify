import 'package:cermatify/app/data/content/help_content.dart';
import 'package:get/get.dart';

class FaqController extends GetxController {
  final List<Map<String, String>> faqs = HelpContent.dashboard;
}
