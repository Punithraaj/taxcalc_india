import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class DeductionCategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String currentAmount;
  final String limitAmount;
  final double progressValue;
  final List<Widget> inputFields;
  final VoidCallback? onInfoTap;

  const DeductionCategoryCard({
    Key? key,
    required this.title,
    required this.description,
    required this.currentAmount,
    required this.limitAmount,
    required this.progressValue,
    required this.inputFields,
    this.onInfoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color getProgressColor() {
      if (progressValue >= 1.0) return AppTheme.lightTheme.colorScheme.error;
      if (progressValue >= 0.8) return AppTheme.warningLight;
      return AppTheme.lightTheme.colorScheme.primary;
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.getCardShadow(isLight: !isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppTheme.textHighEmphasisDark
                                      : AppTheme.textHighEmphasisLight,
                                ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppTheme.textMediumEmphasisDark
                                  : AppTheme.textMediumEmphasisLight,
                            ),
                      ),
                    ],
                  ),
                ),
                if (onInfoTap != null)
                  GestureDetector(
                    onTap: onInfoTap,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CustomIconWidget(
                        iconName: 'info_outline',
                        size: 20,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Progress Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Utilized: ₹$currentAmount',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: getProgressColor(),
                          ),
                    ),
                    Text(
                      'Limit: ₹$limitAmount',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppTheme.textMediumEmphasisDark
                                : AppTheme.textMediumEmphasisLight,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressValue > 1.0 ? 1.0 : progressValue,
                    backgroundColor:
                        isDark ? AppTheme.outlineDark : AppTheme.outlineLight,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(getProgressColor()),
                    minHeight: 6,
                  ),
                ),
                if (progressValue > 1.0) ...[
                  SizedBox(height: 1.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'warning',
                          size: 16,
                          color: AppTheme.lightTheme.colorScheme.error,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Amount exceeds limit by ₹${(double.parse(currentAmount.replaceAll(',', '')) - double.parse(limitAmount.replaceAll(',', ''))).toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Input Fields Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: inputFields,
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
