import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FinancialYearDropdownWidget extends StatelessWidget {
  final String selectedYear;
  final Function(String) onYearChanged;

  const FinancialYearDropdownWidget({
    super.key,
    required this.selectedYear,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> financialYears = [
      'FY 2019-20',
      'FY 2020-21',
      'FY 2021-22',
      'FY 2022-23',
      'FY 2023-24',
      'FY 2024-25',
      'FY 2025-26',
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedYear,
          icon: CustomIconWidget(
            iconName: 'keyboard_arrow_down',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 20,
          ),
          style: AppTheme.lightTheme.textTheme.titleMedium,
          onChanged: (String? newValue) {
            if (newValue != null) {
              onYearChanged(newValue);
            }
          },
          items: financialYears.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
