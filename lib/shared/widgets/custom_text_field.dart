import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final bool enabled;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.enabled = true,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);


    List<TextInputFormatter> effectiveFormatters = [];
    if (inputFormatters != null) {
      effectiveFormatters.addAll(inputFormatters!);
    }
    
    if (keyboardType == TextInputType.phone) {
      effectiveFormatters.add(_PhoneInputFormatter());
    } else if (keyboardType == TextInputType.number) {
      effectiveFormatters.add(FilteringTextInputFormatter.digitsOnly);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          enabled: enabled,
          keyboardType: keyboardType ?? TextInputType.text,
          inputFormatters: effectiveFormatters,
          textCapitalization: textCapitalization == TextCapitalization.none && !isPassword 
              ? TextCapitalization.sentences 
              : textCapitalization,
          textInputAction: textInputAction,
          autocorrect: true,
          enableSuggestions: true,
          style: TextStyle(
            color: enabled 
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.5)
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20,
                color: theme.colorScheme.primary.withValues(alpha: 0.7)) : null,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 14,
            ),
            filled: true,
            fillColor: enabled ? theme.colorScheme.surface : theme.dividerColor
                .withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              borderSide: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 11) return oldValue;

    String formatted = '';
    if (text.isNotEmpty) {
      formatted += '(';
      if (text.length <= 2) {
        formatted += text;
      } else {
        formatted += '${text.substring(0, 2)}) ';
        if (text.length <= 3) {
          formatted += text.substring(2);
        } else if (text.length <= 7) {
          formatted += '${text.substring(2, 3)} ${text.substring(3)}';
        } else {
          formatted += '${text.substring(2, 3)} ${text.substring(3, 7)}-${text.substring(7)}';
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
