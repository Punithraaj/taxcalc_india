import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './deduction_category_card.dart';
import './deduction_input_field.dart';

class OtherDeductionsCard extends StatefulWidget {
  final Function(double) onTotalChanged;

  const OtherDeductionsCard({
    Key? key,
    required this.onTotalChanged,
  }) : super(key: key);

  @override
  State<OtherDeductionsCard> createState() => _OtherDeductionsCardState();
}

class _OtherDeductionsCardState extends State<OtherDeductionsCard> {
  final TextEditingController _section80GController = TextEditingController();
  final TextEditingController _section80EController = TextEditingController();
  final TextEditingController _section80UController = TextEditingController();
  final TextEditingController _section80GGController = TextEditingController();
  final TextEditingController _section24BController = TextEditingController();
  final TextEditingController _npsController = TextEditingController();

  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    _section80GController.addListener(_calculateTotal);
    _section80EController.addListener(_calculateTotal);
    _section80UController.addListener(_calculateTotal);
    _section80GGController.addListener(_calculateTotal);
    _section24BController.addListener(_calculateTotal);
    _npsController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    double total = 0.0;

    // Section 80G - No limit but depends on donation type
    total += _parseAmount(_section80GController.text);

    // Section 80E - No limit
    total += _parseAmount(_section80EController.text);

    // Section 80U - Fixed limits based on disability
    double section80U = _parseAmount(_section80UController.text);
    total += section80U > 125000 ? 125000 : section80U;

    // Section 80GG - Minimum of rent paid or 5000 per month
    double section80GG = _parseAmount(_section80GGController.text);
    total += section80GG > 60000 ? 60000 : section80GG;

    // Section 24B - No limit
    total += _parseAmount(_section24BController.text);

    // NPS 80CCD(1B) - Limit 50000
    double nps = _parseAmount(_npsController.text);
    total += nps > 50000 ? 50000 : nps;

    setState(() {
      _totalAmount = total;
    });

    widget.onTotalChanged(total);
  }

  double _parseAmount(String text) {
    if (text.isEmpty) return 0.0;
    return double.tryParse(text.replaceAll(',', '')) ?? 0.0;
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Other Deductions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSectionInfo('80G - Donations',
                    'Donations to eligible institutions (50% or 100% deduction)'),
                _buildSectionInfo('80E - Education Loan',
                    'Interest on education loan (No limit)'),
                _buildSectionInfo('80U - Disability',
                    'Person with disability (₹75,000 or ₹1,25,000)'),
                _buildSectionInfo('80GG - Rent',
                    'Rent paid when no HRA (Min of rent or ₹5,000/month)'),
                _buildSectionInfo(
                    '24B - Home Loan', 'Interest on home loan (No limit)'),
                _buildSectionInfo('80CCD(1B) - NPS',
                    'Additional NPS contribution (₹50,000 limit)'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionInfo(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DeductionCategoryCard(
      title: 'Other Deductions',
      description: 'Additional tax deductions under various sections',
      currentAmount: _formatAmount(_totalAmount),
      limitAmount: 'Varies',
      progressValue: 0.0, // No fixed total limit
      onInfoTap: _showInfoDialog,
      inputFields: [
        DeductionInputField(
          label: 'Section 80G - Donations',
          hint: 'Donations to eligible institutions',
          controller: _section80GController,
        ),
        DeductionInputField(
          label: 'Section 80E - Education Loan Interest',
          hint: 'Interest paid on education loan',
          controller: _section80EController,
        ),
        DeductionInputField(
          label: 'Section 80U - Disability',
          hint: 'Deduction for person with disability',
          controller: _section80UController,
        ),
        DeductionInputField(
          label: 'Section 80GG - Rent Paid',
          hint: 'Rent when no HRA received',
          controller: _section80GGController,
        ),
        DeductionInputField(
          label: 'Section 24B - Home Loan Interest',
          hint: 'Interest on home loan',
          controller: _section24BController,
        ),
        DeductionInputField(
          label: 'Section 80CCD(1B) - NPS',
          hint: 'Additional NPS contribution (Max ₹50,000)',
          controller: _npsController,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _section80GController.dispose();
    _section80EController.dispose();
    _section80UController.dispose();
    _section80GGController.dispose();
    _section24BController.dispose();
    _npsController.dispose();
    super.dispose();
  }
}
