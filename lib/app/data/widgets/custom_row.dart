import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_styles.dart';
import 'package:flutter/widgets.dart';

/// [CustomRow] adalah widget custom untuk baris data
class CustomRow extends StatelessWidget {
  final String title;
  final String value;
  const CustomRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppStyles.body1(fontWeight: FontWeight.normal, color: AppColors.greyTextSecondaryColor),
        ),
        Spacer(),
        LimitedBox(
          maxWidth: 200,
          child: Text(
            value,
            maxLines: 2,
            textAlign: TextAlign.right,
            style: AppStyles.body1(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
