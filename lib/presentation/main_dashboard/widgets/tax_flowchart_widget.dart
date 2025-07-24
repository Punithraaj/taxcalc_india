import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaxFlowchartWidget extends StatelessWidget {
  final double grossIncome;
  final double totalDeductions;
  final double taxableIncome;
  final double totalTax;
  final String selectedRegime;

  const TaxFlowchartWidget({
    super.key,
    required this.grossIncome,
    required this.totalDeductions,
    required this.taxableIncome,
    required this.totalTax,
    required this.selectedRegime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.getCardShadow(isLight: true),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tax Calculation Flow ($selectedRegime)',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildFlowStep(
            title: 'Gross Total Income',
            amount: grossIncome,
            color: AppTheme.lightTheme.colorScheme.secondary,
            isFirst: true,
          ),
          _buildArrow(),
          _buildFlowStep(
            title: 'Less: Deductions',
            amount: totalDeductions,
            color: AppTheme.lightTheme.colorScheme.tertiary,
            isDeduction: true,
          ),
          _buildArrow(),
          _buildFlowStep(
            title: 'Taxable Income',
            amount: taxableIncome,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          _buildArrow(),
          _buildFlowStep(
            title: 'Total Tax Payable',
            amount: totalTax,
            color: AppTheme.lightTheme.colorScheme.error,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFlowStep({
    required String title,
    required double amount,
    required Color color,
    bool isFirst = false,
    bool isLast = false,
    bool isDeduction = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${isDeduction ? '-' : ''}₹${amount.toStringAsFixed(0)}',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: CustomIconWidget(
        iconName: 'keyboard_arrow_down',
        color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
        size: 24,
      ),
    );
  }
}
