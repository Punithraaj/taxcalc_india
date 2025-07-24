import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AdditionalTaxesWidget extends StatelessWidget {
  final double baseTax;
  final double surcharge;
  final double healthEducationCess;
  final List<Map<String, dynamic>> specialRateTaxes;

  const AdditionalTaxesWidget({
    super.key,
    required this.baseTax,
    required this.surcharge,
    required this.healthEducationCess,
    required this.specialRateTaxes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
            'Additional Taxes & Charges',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildTaxItem(
            'Income Tax (Slab Rate)',
            baseTax,
            '',
            AppTheme.lightTheme.colorScheme.primary,
          ),
          if (surcharge > 0) ...[
            SizedBox(height: 2.h),
            _buildTaxItem(
              'Surcharge',
              surcharge,
              _getSurchargeRate(),
              AppTheme.lightTheme.colorScheme.secondary,
            ),
          ],
          if (healthEducationCess > 0) ...[
            SizedBox(height: 2.h),
            _buildTaxItem(
              'Health & Education Cess',
              healthEducationCess,
              '4%',
              AppTheme.lightTheme.colorScheme.tertiary,
            ),
          ],
          if (specialRateTaxes.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              'Special Rate Taxes',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ...specialRateTaxes
                .map((tax) => Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: _buildSpecialTaxItem(tax),
                    ))
                .toList(),
          ],
          SizedBox(height: 2.h),
          Divider(color: AppTheme.lightTheme.colorScheme.outline),
          SizedBox(height: 2.h),
          _buildTotalTaxRow(),
        ],
      ),
    );
  }

  Widget _buildTaxItem(String title, double amount, String rate, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (rate.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    'Rate: $rate',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialTaxItem(Map<String, dynamic> tax) {
    final String type = tax['type'] as String;
    final double amount = tax['amount'] as double;
    final String rate = tax['rate'] as String;
    final Color color = _getSpecialTaxColor(type);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Rate: $rate',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTaxRow() {
    final double totalTax = baseTax +
        surcharge +
        healthEducationCess +
        specialRateTaxes.fold(
            0.0, (sum, tax) => sum + (tax['amount'] as double));

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppTheme.lightTheme.colorScheme.primary, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Tax Liability',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          Text(
            '₹${totalTax.toStringAsFixed(0)}',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _getSurchargeRate() {
    if (baseTax > 10000000) return '37%';
    if (baseTax > 5000000) return '25%';
    if (baseTax > 1000000) return '15%';
    return '10%';
  }

  Color _getSpecialTaxColor(String type) {
    switch (type.toLowerCase()) {
      case 'short term capital gains (normal)':
        return Colors.orange;
      case 'short term capital gains (20%)':
        return Colors.deepOrange;
      case 'long term capital gains (12.5%)':
        return Colors.green;
      case 'long term capital gains (20%)':
        return Colors.teal;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }
}
