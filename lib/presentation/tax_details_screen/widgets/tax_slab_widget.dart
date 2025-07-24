import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TaxSlabWidget extends StatelessWidget {
  final String regime;
  final double taxableIncome;

  const TaxSlabWidget({
    super.key,
    required this.regime,
    required this.taxableIncome,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> taxSlabs = _getTaxSlabs();

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
            'Tax Slab Breakdown ($regime Regime)',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          ...taxSlabs.map((slab) => _buildSlabItem(slab)).toList(),
          SizedBox(height: 2.h),
          _buildTaxVisualization(taxSlabs),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getTaxSlabs() {
    if (regime == 'New') {
      return [
        {
          'range': '₹0 - ₹3,00,000',
          'rate': '0%',
          'color': Colors.green,
          'amount': 0.0,
          'applicable': taxableIncome > 0
        },
        {
          'range': '₹3,00,001 - ₹7,00,000',
          'rate': '5%',
          'color': Colors.blue,
          'amount': _calculateSlabTax(300000, 700000, 0.05),
          'applicable': taxableIncome > 300000
        },
        {
          'range': '₹7,00,001 - ₹10,00,000',
          'rate': '10%',
          'color': Colors.orange,
          'amount': _calculateSlabTax(700000, 1000000, 0.10),
          'applicable': taxableIncome > 700000
        },
        {
          'range': '₹10,00,001 - ₹12,00,000',
          'rate': '15%',
          'color': Colors.purple,
          'amount': _calculateSlabTax(1000000, 1200000, 0.15),
          'applicable': taxableIncome > 1000000
        },
        {
          'range': '₹12,00,001 - ₹15,00,000',
          'rate': '20%',
          'color': Colors.red,
          'amount': _calculateSlabTax(1200000, 1500000, 0.20),
          'applicable': taxableIncome > 1200000
        },
        {
          'range': 'Above ₹15,00,000',
          'rate': '30%',
          'color': Colors.deepPurple,
          'amount': _calculateSlabTax(1500000, double.infinity, 0.30),
          'applicable': taxableIncome > 1500000
        },
      ];
    } else {
      return [
        {
          'range': '₹0 - ₹2,50,000',
          'rate': '0%',
          'color': Colors.green,
          'amount': 0.0,
          'applicable': taxableIncome > 0
        },
        {
          'range': '₹2,50,001 - ₹5,00,000',
          'rate': '5%',
          'color': Colors.blue,
          'amount': _calculateSlabTax(250000, 500000, 0.05),
          'applicable': taxableIncome > 250000
        },
        {
          'range': '₹5,00,001 - ₹10,00,000',
          'rate': '20%',
          'color': Colors.orange,
          'amount': _calculateSlabTax(500000, 1000000, 0.20),
          'applicable': taxableIncome > 500000
        },
        {
          'range': 'Above ₹10,00,000',
          'rate': '30%',
          'color': Colors.red,
          'amount': _calculateSlabTax(1000000, double.infinity, 0.30),
          'applicable': taxableIncome > 1000000
        },
      ];
    }
  }

  double _calculateSlabTax(double lowerLimit, double upperLimit, double rate) {
    if (taxableIncome <= lowerLimit) return 0.0;

    final double applicableIncome = taxableIncome > upperLimit
        ? upperLimit - lowerLimit
        : taxableIncome - lowerLimit;

    return applicableIncome * rate;
  }

  Widget _buildSlabItem(Map<String, dynamic> slab) {
    final bool isApplicable = slab['applicable'] as bool;
    final double amount = slab['amount'] as double;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isApplicable
            ? (slab['color'] as Color).withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: isApplicable
            ? Border.all(color: slab['color'] as Color, width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 6.h,
            decoration: BoxDecoration(
              color: isApplicable
                  ? slab['color'] as Color
                  : AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      slab['range'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isApplicable
                            ? AppTheme.lightTheme.textTheme.bodyMedium?.color
                            : AppTheme.lightTheme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: slab['color'] as Color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        slab['rate'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (amount > 0) ...[
                  SizedBox(height: 1.h),
                  Text(
                    'Tax: ₹${amount.toStringAsFixed(0)}',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: slab['color'] as Color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxVisualization(List<Map<String, dynamic>> taxSlabs) {
    final double totalTax =
        taxSlabs.fold(0.0, (sum, slab) => sum + (slab['amount'] as double));

    if (totalTax == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tax Distribution',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          height: 3.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: taxSlabs
                  .where((slab) => (slab['amount'] as double) > 0)
                  .map((slab) {
                final double percentage = (slab['amount'] as double) / totalTax;
                return Expanded(
                  flex: (percentage * 100).round(),
                  child: Container(
                    color: slab['color'] as Color,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Total Tax: ₹${totalTax.toStringAsFixed(0)}',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
