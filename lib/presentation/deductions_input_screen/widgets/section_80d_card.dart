import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './deduction_category_card.dart';
import './deduction_input_field.dart';

class Section80DCard extends StatefulWidget {
  final Function(double) onTotalChanged;

  const Section80DCard({
    Key? key,
    required this.onTotalChanged,
  }) : super(key: key);

  @override
  State<Section80DCard> createState() => _Section80DCardState();
}

class _Section80DCardState extends State<Section80DCard> {
  final TextEditingController _selfController = TextEditingController();
  final TextEditingController _parentsController = TextEditingController();
  final TextEditingController _preventiveHealthController =
      TextEditingController();

  double _totalAmount = 0.0;
  bool _isSelfSenior = false;
  bool _isParentSenior = false;

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    _selfController.addListener(_calculateTotal);
    _parentsController.addListener(_calculateTotal);
    _preventiveHealthController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    double total = 0.0;

    // Self and family limit
    double selfAmount = _parseAmount(_selfController.text);
    double selfLimit = _isSelfSenior ? 50000.0 : 25000.0;
    total += selfAmount > selfLimit ? selfLimit : selfAmount;

    // Parents limit
    double parentsAmount = _parseAmount(_parentsController.text);
    double parentsLimit = _isParentSenior ? 50000.0 : 25000.0;
    total += parentsAmount > parentsLimit ? parentsLimit : parentsAmount;

    // Preventive health checkup (included in respective limits)
    double preventiveAmount = _parseAmount(_preventiveHealthController.text);
    total += preventiveAmount > 5000.0 ? 5000.0 : preventiveAmount;

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

  double _getTotalLimit() {
    double selfLimit = _isSelfSenior ? 50000.0 : 25000.0;
    double parentsLimit = _isParentSenior ? 50000.0 : 25000.0;
    return selfLimit + parentsLimit + 5000.0; // Including preventive health
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Section 80D Deductions',
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
                  'Medical insurance premium deductions:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 1.h),
                _buildInfoItem(
                    '• Self & Family: ₹25,000 (₹50,000 if senior citizen)'),
                _buildInfoItem(
                    '• Parents: ₹25,000 (₹50,000 if senior citizen)'),
                _buildInfoItem(
                    '• Preventive Health Checkup: ₹5,000 additional'),
                SizedBox(height: 2.h),
                Text(
                  'Note: Senior citizen age is 60 years and above',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                ),
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
      title: 'Section 80D',
      description: 'Medical insurance premium and health checkup expenses',
      currentAmount: _formatAmount(_totalAmount),
      limitAmount: _formatAmount(_getTotalLimit()),
      progressValue: _totalAmount / _getTotalLimit(),
      onInfoTap: _showInfoDialog,
      inputFields: [
        // Self and Family Section
        Container(
          padding: EdgeInsets.all(3.w),
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.surfaceVariantDark.withValues(alpha: 0.5)
                : AppTheme.surfaceVariantLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Self & Family',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Senior Citizen',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(width: 2.w),
                      Switch(
                        value: _isSelfSenior,
                        onChanged: (value) {
                          setState(() {
                            _isSelfSenior = value;
                          });
                          _calculateTotal();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                'Limit: ₹${_formatAmount(_isSelfSenior ? 50000.0 : 25000.0)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
              ),
              SizedBox(height: 1.h),
              DeductionInputField(
                label: 'Medical Insurance Premium',
                hint: 'Annual premium for self and family',
                controller: _selfController,
              ),
            ],
          ),
        ),

        // Parents Section
        Container(
          padding: EdgeInsets.all(3.w),
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.surfaceVariantDark.withValues(alpha: 0.5)
                : AppTheme.surfaceVariantLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Parents',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Senior Citizen',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(width: 2.w),
                      Switch(
                        value: _isParentSenior,
                        onChanged: (value) {
                          setState(() {
                            _isParentSenior = value;
                          });
                          _calculateTotal();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                'Limit: ₹${_formatAmount(_isParentSenior ? 50000.0 : 25000.0)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
              ),
              SizedBox(height: 1.h),
              DeductionInputField(
                label: 'Parents Medical Insurance',
                hint: 'Annual premium for parents',
                controller: _parentsController,
              ),
            ],
          ),
        ),

        // Preventive Health Checkup
        DeductionInputField(
          label: 'Preventive Health Checkup',
          hint: 'Maximum ₹5,000',
          controller: _preventiveHealthController,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _selfController.dispose();
    _parentsController.dispose();
    _preventiveHealthController.dispose();
    super.dispose();
  }
}
