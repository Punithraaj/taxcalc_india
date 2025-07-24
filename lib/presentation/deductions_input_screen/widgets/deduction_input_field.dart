import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DeductionInputField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String? errorText;
  final bool isRequired;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final int? maxLines;

  const DeductionInputField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.onChanged,
    this.errorText,
    this.isRequired = false,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.suffixIcon,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppTheme.textHighEmphasisDark
                          : AppTheme.textHighEmphasisLight,
                    ),
              ),
              if (isRequired) ...[
                SizedBox(width: 1.w),
                Text(
                  '*',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.error,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters ??
                [
                  if (keyboardType == TextInputType.number) ...[
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty) return newValue;
                      final number =
                          int.tryParse(newValue.text.replaceAll(',', ''));
                      if (number == null) return oldValue;
                      final formatted = _formatIndianNumber(number);
                      return TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }),
                  ],
                ],
            maxLines: maxLines,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textHighEmphasisDark
                      : AppTheme.textHighEmphasisLight,
                ),
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: suffixIcon,
              prefixText: keyboardType == TextInputType.number ? '₹ ' : null,
              prefixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.textMediumEmphasisDark
                        : AppTheme.textMediumEmphasisLight,
                  ),
              errorText: errorText,
              filled: true,
              fillColor: isDark
                  ? AppTheme.surfaceVariantDark
                  : AppTheme.surfaceVariantLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.error,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatIndianNumber(int number) {
    String numStr = number.toString();
    if (numStr.length <= 3) return numStr;

    String result = '';
    int count = 0;

    for (int i = numStr.length - 1; i >= 0; i--) {
      if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
        result = ',$result';
      }
      result = numStr[i] + result;
      count++;
    }

    return result;
  }
}
