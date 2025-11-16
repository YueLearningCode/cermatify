import 'package:flutter/material.dart';
import 'package:cermatify/app/data/widgets/custom_button.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_styles.dart';

/// [CustomButtonSimple] is a simplified button widget that matches
/// the expected API for login/register forms
class CustomButtonSimple extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomButtonSimple({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onTap: onPressed ?? () {},
      height: 50,
      width: double.infinity,
      color: onPressed != null ? AppColors.primaryColor : AppColors.disabledColor,
      widget: Center(
        child: Text(
          text,
          style: AppStyles.body1(
            color: onPressed != null ? AppColors.whiteColor : AppColors.grey2Color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
