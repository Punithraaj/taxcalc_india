import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class TaxFlowchartWidget extends StatefulWidget {
  final double grossIncome;
  final double totalDeductions;
  final double taxableIncome;
  final double totalTax;

  const TaxFlowchartWidget({
    super.key,
    required this.grossIncome,
    required this.totalDeductions,
    required this.taxableIncome,
    required this.totalTax,
  });

  @override
  State<TaxFlowchartWidget> createState() => _TaxFlowchartWidgetState();
}

class _TaxFlowchartWidgetState extends State<TaxFlowchartWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
            'Tax Calculation Flow',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  _buildFlowStep(
                    'Gross Income',
                    widget.grossIncome,
                    AppTheme.lightTheme.colorScheme.secondary,
                    0,
                    _progressAnimation.value >= 0.25,
                  ),
                  _buildFlowArrow(_progressAnimation.value >= 0.25),
                  _buildFlowStep(
                    'Less: Total Deductions',
                    widget.totalDeductions,
                    AppTheme.lightTheme.colorScheme.tertiary,
                    1,
                    _progressAnimation.value >= 0.5,
                  ),
                  _buildFlowArrow(_progressAnimation.value >= 0.5),
                  _buildFlowStep(
                    'Taxable Income',
                    widget.taxableIncome,
                    AppTheme.lightTheme.colorScheme.primary,
                    2,
                    _progressAnimation.value >= 0.75,
                  ),
                  _buildFlowArrow(_progressAnimation.value >= 0.75),
                  _buildFlowStep(
                    'Total Tax Payable',
                    widget.totalTax,
                    AppTheme.lightTheme.colorScheme.error,
                    3,
                    _progressAnimation.value >= 1.0,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFlowStep(
      String title, double amount, Color color, int step, bool isVisible) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isVisible ? color : color.withValues(alpha: 0.3),
            width: isVisible ? 2 : 1,
          ),
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
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '₹${amount.toStringAsFixed(0)}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            if (isVisible)
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${step + 1}',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowArrow(bool isVisible) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h),
        child: CustomIconWidget(
          iconName: 'keyboard_arrow_down',
          color: isVisible
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline,
          size: 24,
        ),
      ),
    );
  }
}
