import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class IncomeInputCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> fields;
  final bool isMonthly;
  final Function(String fieldKey, String value) onFieldChanged;
  final Widget? additionalContent;

  const IncomeInputCard({
    super.key,
    required this.title,
    required this.fields,
    required this.isMonthly,
    required this.onFieldChanged,
    this.additionalContent,
  });

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';

    // Remove any non-digit characters except decimal point
    String cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');

    if (cleanValue.isEmpty) return '';

    // Parse the number
    double? number = double.tryParse(cleanValue);
    if (number == null) return value;

    // Format with Indian number system
    String formatted = number.toStringAsFixed(0);

    // Add commas in Indian format (1,00,000)
    if (formatted.length > 3) {
      String result = '';
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        if (count == 3) {
          result = ',$result';
          count = 0;
        }
        result = formatted[i] + result;
        count++;

        if (count == 2 && i > 1) {
          result = ',$result';
          count = 0;
        }
      }
      formatted = result;
    }

    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'account_balance_wallet',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            ...fields.map((field) => _buildInputField(field)).toList(),
            if (additionalContent != null) ...[
              SizedBox(height: 2.h),
              additionalContent!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(Map<String, dynamic> field) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  field['label'] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (field['tooltip'] != null)
                Tooltip(
                  message: field['tooltip'] as String,
                  child: CustomIconWidget(
                    iconName: 'info_outline',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 16,
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          TextFormField(
            initialValue: field['value'] as String? ?? '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              hintText: isMonthly ? 'Monthly amount' : 'Yearly amount',
              suffixIcon: field['value'] != null &&
                      (field['value'] as String).isNotEmpty
                  ? GestureDetector(
                      onTap: () => onFieldChanged(field['key'] as String, ''),
                      child: CustomIconWidget(
                        iconName: 'clear',
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                        size: 20,
                      ),
                    )
                  : null,
            ),
            onChanged: (value) {
              String formattedValue = _formatCurrency(value);
              onFieldChanged(field['key'] as String, formattedValue);
            },
            style: AppTheme.dataTextStyle(
              isLight: true,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
