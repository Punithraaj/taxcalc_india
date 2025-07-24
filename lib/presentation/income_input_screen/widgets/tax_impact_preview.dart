import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaxImpactPreview extends StatelessWidget {
  final double totalIncome;
  final double estimatedTax;
  final bool isMonthly;

  const TaxImpactPreview({
    super.key,
    required this.totalIncome,
    required this.estimatedTax,
    required this.isMonthly,
  });

  String _formatAmount(double amount) {
    if (amount == 0) return '₹0';

    String formatted = amount.toStringAsFixed(0);

    // Add commas in Indian format
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

    return '₹$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'trending_up',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Live Tax Impact',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildImpactItem(
                  'Total Income',
                  _formatAmount(totalIncome),
                  isMonthly ? '(Monthly)' : '(Yearly)',
                  AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              Container(
                width: 1,
                height: 6.h,
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
              Expanded(
                child: _buildImpactItem(
                  'Est. Tax',
                  _formatAmount(estimatedTax),
                  isMonthly ? '(Monthly)' : '(Yearly)',
                  AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ],
          ),
          if (totalIncome > 0) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Flexible(
                    child: Text(
                      'Tax rate: ${((estimatedTax / totalIncome) * 100).toStringAsFixed(1)}%',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImpactItem(
      String label, String amount, String period, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 0.5.h),
        Text(
          amount,
          style: AppTheme.dataTextStyle(
            isLight: true,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ).copyWith(color: color),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          period,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
