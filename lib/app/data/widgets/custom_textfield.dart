import 'package:flutter/material.dart';
import 'package:cermatify/app/data/widgets/custom_textformfield.dart';

/// [CustomTextField] is a wrapper widget that provides a simpler API
/// matching the expected interface for login/register forms
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      key: key,
      controller: controller,
      hintText: hintText,
      prefixIcon: Icon(icon),
      keyType: keyboardType,
      validator: validator,
      isPassword: obscureText,
    );
  }
}
