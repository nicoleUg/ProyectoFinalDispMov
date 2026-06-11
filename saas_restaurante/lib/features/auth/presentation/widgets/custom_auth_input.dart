import 'package:flutter/material.dart';

class CustomAuthInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final VoidCallback? onToggleVisibility;
  final bool obscureText;

  const CustomAuthInput({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.onToggleVisibility,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFB02F00);
    final Color surfaceContainer = const Color(0xFFEDEEEF);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: surfaceContainer,
        border: const UnderlineInputBorder(),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}