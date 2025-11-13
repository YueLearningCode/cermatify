import 'package:flutter/material.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_styles.dart';
import 'package:cermatify/app/data/widgets/custom_text_input_formatter.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Icon? prefixIcon;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int? maxLines;
  final bool isPassword;
  final TextInputType keyType;
  final Function(String)? onChanged;
  final bool isDropdown;
  final List<String>? dropdownItems;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.validator,
    this.maxLength,
    this.maxLines,
    this.isPassword = false,
    required this.keyType,
    this.onChanged,
    this.isDropdown = false,
    this.dropdownItems,
    this.readOnly = false,
    this.onTap,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    if (widget.isDropdown && widget.dropdownItems != null && widget.dropdownItems!.isNotEmpty) {
      if (widget.controller.text.isNotEmpty && !widget.dropdownItems!.contains(widget.controller.text)) {
        widget.controller.text = widget.dropdownItems!.first;
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDropdown && widget.dropdownItems != null && widget.dropdownItems!.isNotEmpty) {
      return DropdownButtonFormField<String>(
        value: widget.controller.text.isNotEmpty && widget.dropdownItems!.contains(widget.controller.text)
            ? widget.controller.text
            : widget.dropdownItems!.first,
        hint: Text(widget.hintText, style: AppStyles.body1().copyWith(color: Colors.grey)),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          prefixIcon: IconTheme(
            data: IconThemeData(
              color: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                if (states.contains(MaterialState.focused) || widget.controller.text.isNotEmpty) {
                  return AppColors.primaryColor;
                }
                return Colors.grey;
              }),
            ),
            child: widget.prefixIcon ?? SizedBox.shrink(),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.secondaryColor, width: 1.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        items: widget.dropdownItems!.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: AppStyles.body1()),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            widget.controller.text = newValue;
            if (widget.onChanged != null) {
              widget.onChanged!(newValue);
            }
          }
          setState(() {});
        },
        validator: widget.validator,
      );
    }

    return TextFormField(
      obscureText: widget.isPassword ? _obscureText : false,
      style: AppStyles.body1(),
      keyboardType: widget.keyType,
      onChanged: widget.onChanged,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      inputFormatters: [if (widget.keyType == TextInputType.number) ThousandsSeparatorInputFormatter()],
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        prefixIcon: IconTheme(
          data: IconThemeData(
            color: MaterialStateColor.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.focused) || widget.controller.text.isNotEmpty) {
                return AppColors.primaryColor;
              }
              return Colors.grey;
            }),
          ),
          child: widget.prefixIcon ?? SizedBox.shrink(),
        ),
        hintText: widget.hintText,
        hintStyle: AppStyles.body1(),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(30.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondaryColor, width: 1.0),
          borderRadius: BorderRadius.circular(30.0),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: AppColors.secondaryColor),
                onPressed: _togglePasswordVisibility,
              )
            : null,
      ),
      controller: widget.controller,
      validator: widget.validator ?? (input) => input == '' ? "Tidak boleh kosong" : null,
    );
  }
}
