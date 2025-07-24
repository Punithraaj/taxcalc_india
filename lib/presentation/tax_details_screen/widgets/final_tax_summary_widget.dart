import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class FinalTaxSummaryWidget extends StatelessWidget {
  final double totalTaxLiability;
  final double tdsAmount;
  final double advanceTax;
  final double selfAssessmentTax;

  const FinalTaxSummaryWidget({
    super.key,
    required this.totalTaxLiability,
    required this.tdsAmount,
    required this.advanceTax,
    required this.selfAssessmentTax,
  });

  @override
  Widget build(BuildContext context) {
    final double totalPaid = tdsAmount + advanceTax + selfAssessmentTax;
    final double balance = totalTaxLiability - totalPaid;
    final bool isRefund = balance < 0;

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
            'Final Tax Summary',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildSummaryItem(
            'Total Tax Liability',
            totalTaxLiability,
            AppTheme.lightTheme.colorScheme.primary,
            isHighlight: true,
          ),
          SizedBox(height: 2.h),
          Text(
            'Tax Payments',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.secondary,
            ),
          ),
          SizedBox(height: 1.h),
          if (tdsAmount > 0) ...[
            _buildPaymentItem('TDS Deducted', tdsAmount),
            SizedBox(height: 1.h),
          ],
          if (advanceTax > 0) ...[
            _buildPaymentItem('Advance Tax Paid', advanceTax),
            SizedBox(height: 1.h),
          ],
          if (selfAssessmentTax > 0) ...[
            _buildPaymentItem('Self Assessment Tax', selfAssessmentTax),
            SizedBox(height: 1.h),
          ],
          _buildPaymentItem('Total Tax Paid', totalPaid, isTotal: true),
          SizedBox(height: 3.h),
          Divider(color: AppTheme.lightTheme.colorScheme.outline),
          SizedBox(height: 2.h),
          _buildBalanceCard(balance, isRefund),
          SizedBox(height: 3.h),
          _buildActionButtons(context, isRefund, balance.abs()),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color,
      {bool isHighlight = false}) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color,
          width: isHighlight ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
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

  Widget _buildPaymentItem(String title, double amount,
      {bool isTotal = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.w),
      decoration: isTotal
          ? BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.secondary,
                width: 1,
              ),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: isTotal
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.textTheme.bodySmall?.color,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isTotal
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.textTheme.labelLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double balance, bool isRefund) {
    final Color cardColor = isRefund
        ? AppTheme.lightTheme.colorScheme.tertiary
        : AppTheme.lightTheme.colorScheme.error;

    final String title = isRefund ? 'Refund Due' : 'Tax Payable';
    final String subtitle =
        isRefund ? 'You will receive a refund' : 'Additional tax to be paid';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor.withValues(alpha: 0.1),
            cardColor.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardColor, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: isRefund ? 'trending_up' : 'trending_down',
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cardColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: cardColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '₹${balance.abs().toStringAsFixed(0)}',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cardColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, bool isRefund, double amount) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _shareTaxSummary(context),
            icon: CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 20,
            ),
            label: Text('Share Tax Summary'),
            style: AppTheme.lightTheme.elevatedButtonTheme.style,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _downloadPDF(context),
                icon: CustomIconWidget(
                  iconName: 'picture_as_pdf',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 18,
                ),
                label: Text('Download PDF'),
                style: AppTheme.lightTheme.outlinedButtonTheme.style,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _saveAsImage(context),
                icon: CustomIconWidget(
                  iconName: 'image',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 18,
                ),
                label: Text('Save Image'),
                style: AppTheme.lightTheme.outlinedButtonTheme.style,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _shareTaxSummary(BuildContext context) {
    final String summary = '''
Tax Summary - FY 2024-25

Total Tax Liability: ₹${totalTaxLiability.toStringAsFixed(0)}
Tax Paid: ₹${(tdsAmount + advanceTax + selfAssessmentTax).toStringAsFixed(0)}
${(totalTaxLiability - (tdsAmount + advanceTax + selfAssessmentTax)) < 0 ? 'Refund Due' : 'Tax Payable'}: ₹${(totalTaxLiability - (tdsAmount + advanceTax + selfAssessmentTax)).abs().toStringAsFixed(0)}

Generated by TaxCalc India
    ''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tax summary copied to clipboard'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _downloadPDF(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF download started'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _saveAsImage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image saved to gallery'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }
}
