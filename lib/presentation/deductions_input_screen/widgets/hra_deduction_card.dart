import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './deduction_category_card.dart';
import './deduction_input_field.dart';

class HRADeductionCard extends StatefulWidget {
  final Function(double) onTotalChanged;

  const HRADeductionCard({
    Key? key,
    required this.onTotalChanged,
  }) : super(key: key);

  @override
  State<HRADeductionCard> createState() => _HRADeductionCardState();
}

class _HRADeductionCardState extends State<HRADeductionCard> {
  final TextEditingController _hraReceivedController = TextEditingController();
  final TextEditingController _rentPaidController = TextEditingController();
  final TextEditingController _basicSalaryController = TextEditingController();

  String _selectedCity = 'Metro';
  double _eligibleDeduction = 0.0;

  final List<String> _cityTypes = ['Metro', 'Non-Metro'];

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    _hraReceivedController.addListener(_calculateHRADeduction);
    _rentPaidController.addListener(_calculateHRADeduction);
    _basicSalaryController.addListener(_calculateHRADeduction);
  }

  void _calculateHRADeduction() {
    double hraReceived = _parseAmount(_hraReceivedController.text);
    double rentPaid = _parseAmount(_rentPaidController.text);
    double basicSalary = _parseAmount(_basicSalaryController.text);

    if (hraReceived == 0 || rentPaid == 0 || basicSalary == 0) {
      setState(() {
        _eligibleDeduction = 0.0;
      });
      widget.onTotalChanged(0.0);
      return;
    }

    // HRA calculation as per IT rules
    double exemptionPercentage = _selectedCity == 'Metro' ? 0.50 : 0.40;
    double basicSalaryExemption = basicSalary * exemptionPercentage;
    double rentExcess = rentPaid - (basicSalary * 0.10);

    double eligibleAmount = [
      hraReceived,
      basicSalaryExemption,
      rentExcess > 0 ? rentExcess : 0,
    ].reduce((a, b) => a < b ? a : b).toDouble();

    setState(() {
      _eligibleDeduction = eligibleAmount > 0 ? eligibleAmount : 0.0;
    });

    widget.onTotalChanged(_eligibleDeduction);
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
            'HRA Deduction Calculation',
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
                  'HRA exemption is the minimum of:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 1.h),
                _buildInfoItem('• Actual HRA received'),
                _buildInfoItem(
                    '• 50% of basic salary (Metro) / 40% (Non-Metro)'),
                _buildInfoItem('• Rent paid minus 10% of basic salary'),
                SizedBox(height: 2.h),
                Text(
                  'Conditions:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 1.h),
                _buildInfoItem('• You must be paying rent'),
                _buildInfoItem('• You should not own a house in the same city'),
                _buildInfoItem('• Rent receipts may be required as proof'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DeductionCategoryCard(
      title: 'HRA Deduction',
      description: 'House Rent Allowance exemption calculation',
      currentAmount: _formatAmount(_eligibleDeduction),
      limitAmount: 'No Limit',
      progressValue: 0.0, // HRA has no fixed limit
      onInfoTap: _showInfoDialog,
      inputFields: [
        DeductionInputField(
          label: 'HRA Received',
          hint: 'Annual HRA amount from employer',
          controller: _hraReceivedController,
          isRequired: true,
        ),
        DeductionInputField(
          label: 'Basic Salary',
          hint: 'Annual basic salary',
          controller: _basicSalaryController,
          isRequired: true,
        ),
        DeductionInputField(
          label: 'Rent Paid',
          hint: 'Annual rent amount',
          controller: _rentPaidController,
          isRequired: true,
        ),

        // City Type Selection
        Container(
          margin: EdgeInsets.only(bottom: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'City Type',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppTheme.textHighEmphasisDark
                          : AppTheme.textHighEmphasisLight,
                    ),
              ),
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.surfaceVariantDark
                      : AppTheme.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isDark ? AppTheme.outlineDark : AppTheme.outlineLight,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    isExpanded: true,
                    items: _cityTypes.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(
                          city,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppTheme.textHighEmphasisDark
                                        : AppTheme.textHighEmphasisLight,
                                  ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCity = newValue;
                        });
                        _calculateHRADeduction();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Calculation Result
        if (_eligibleDeduction > 0) ...[
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calculation Breakdown:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                ),
                SizedBox(height: 1.h),
                _buildCalculationRow('HRA Received',
                    _formatAmount(_parseAmount(_hraReceivedController.text))),
                _buildCalculationRow(
                    '${_selectedCity == 'Metro' ? '50%' : '40%'} of Basic Salary',
                    _formatAmount(_parseAmount(_basicSalaryController.text) *
                        (_selectedCity == 'Metro' ? 0.50 : 0.40))),
                _buildCalculationRow(
                    'Rent - 10% of Basic',
                    _formatAmount(_parseAmount(_rentPaidController.text) -
                        (_parseAmount(_basicSalaryController.text) * 0.10))),
                Divider(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3)),
                _buildCalculationRow(
                  'Eligible Deduction',
                  _formatAmount(_eligibleDeduction),
                  isResult: true,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCalculationRow(String label, String amount,
      {bool isResult = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isResult ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
          Text(
            '₹$amount',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isResult ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isResult ? AppTheme.lightTheme.colorScheme.primary : null,
                ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hraReceivedController.dispose();
    _rentPaidController.dispose();
    _basicSalaryController.dispose();
    super.dispose();
  }
}