import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './deduction_category_card.dart';
import './deduction_input_field.dart';

class Section80CCard extends StatefulWidget {
  final Function(double) onTotalChanged;

  const Section80CCard({
    Key? key,
    required this.onTotalChanged,
  }) : super(key: key);

  @override
  State<Section80CCard> createState() => _Section80CCardState();
}

class _Section80CCardState extends State<Section80CCard> {
  final TextEditingController _epfController = TextEditingController();
  final TextEditingController _ppfController = TextEditingController();
  final TextEditingController _elssController = TextEditingController();
  final TextEditingController _lifeInsuranceController =
      TextEditingController();
  final TextEditingController _nscController = TextEditingController();
  final TextEditingController _taxSaverFdController = TextEditingController();
  final TextEditingController _tuitionFeesController = TextEditingController();
  final TextEditingController _homeLoanPrincipalController =
      TextEditingController();

  double _totalAmount = 0.0;
  final double _limit = 150000.0;

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    _epfController.addListener(_calculateTotal);
    _ppfController.addListener(_calculateTotal);
    _elssController.addListener(_calculateTotal);
    _lifeInsuranceController.addListener(_calculateTotal);
    _nscController.addListener(_calculateTotal);
    _taxSaverFdController.addListener(_calculateTotal);
    _tuitionFeesController.addListener(_calculateTotal);
    _homeLoanPrincipalController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    double total = 0.0;

    total += _parseAmount(_epfController.text);
    total += _parseAmount(_ppfController.text);
    total += _parseAmount(_elssController.text);
    total += _parseAmount(_lifeInsuranceController.text);
    total += _parseAmount(_nscController.text);
    total += _parseAmount(_taxSaverFdController.text);
    total += _parseAmount(_tuitionFeesController.text);
    total += _parseAmount(_homeLoanPrincipalController.text);

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
            'Section 80C Deductions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Maximum deduction limit: ₹1,50,000 per financial year',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Eligible investments include:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 1.h),
                _buildInfoItem('• EPF contributions (employee share)'),
                _buildInfoItem('• PPF investments'),
                _buildInfoItem('• ELSS mutual funds'),
                _buildInfoItem('• Life insurance premiums'),
                _buildInfoItem('• NSC investments'),
                _buildInfoItem('• Tax saver fixed deposits'),
                _buildInfoItem('• Children\'s tuition fees'),
                _buildInfoItem('• Home loan principal repayment'),
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

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DeductionCategoryCard(
      title: 'Section 80C',
      description: 'Investments and expenses eligible for tax deduction',
      currentAmount: _formatAmount(_totalAmount),
      limitAmount: _formatAmount(_limit),
      progressValue: _totalAmount / _limit,
      onInfoTap: _showInfoDialog,
      inputFields: [
        DeductionInputField(
          label: 'EPF Contribution',
          hint: 'Employee Provident Fund',
          controller: _epfController,
        ),
        DeductionInputField(
          label: 'PPF Investment',
          hint: 'Public Provident Fund',
          controller: _ppfController,
        ),
        DeductionInputField(
          label: 'ELSS Mutual Funds',
          hint: 'Equity Linked Savings Scheme',
          controller: _elssController,
        ),
        DeductionInputField(
          label: 'Life Insurance Premium',
          hint: 'Annual premium amount',
          controller: _lifeInsuranceController,
        ),
        DeductionInputField(
          label: 'NSC Investment',
          hint: 'National Savings Certificate',
          controller: _nscController,
        ),
        DeductionInputField(
          label: 'Tax Saver FD',
          hint: '5-year tax saver fixed deposit',
          controller: _taxSaverFdController,
        ),
        DeductionInputField(
          label: 'Children Tuition Fees',
          hint: 'Maximum 2 children',
          controller: _tuitionFeesController,
        ),
        DeductionInputField(
          label: 'Home Loan Principal',
          hint: 'Principal repayment amount',
          controller: _homeLoanPrincipalController,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _epfController.dispose();
    _ppfController.dispose();
    _elssController.dispose();
    _lifeInsuranceController.dispose();
    _nscController.dispose();
    _taxSaverFdController.dispose();
    _tuitionFeesController.dispose();
    _homeLoanPrincipalController.dispose();
    super.dispose();
  }
}
