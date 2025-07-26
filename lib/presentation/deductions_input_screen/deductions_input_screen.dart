import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/tax_data_manager.dart';
import './widgets/hra_deduction_card.dart';
import './widgets/other_deductions_card.dart';
import './widgets/section_80c_card.dart';
import './widgets/section_80d_card.dart';
import './widgets/tax_impact_summary.dart';

class DeductionsInputScreen extends StatefulWidget {
  const DeductionsInputScreen({Key? key}) : super(key: key);

  @override
  State<DeductionsInputScreen> createState() => _DeductionsInputScreenState();
}

class _DeductionsInputScreenState extends State<DeductionsInputScreen> {
  final ScrollController _scrollController = ScrollController();
  final TaxDataManager _dataManager = TaxDataManager();

  // Mock data for current financial year and income
  final String _currentFinancialYear = 'FY 2024-25';
  double _grossIncome = 1200000.0; // Will be loaded from saved data
  final double _standardDeduction = 50000.0;
  int _currentProfileId = 1;
  bool _isLoading = true;

  // Deduction amounts
  double _section80CAmount = 0.0;
  double _section80DAmount = 0.0;
  double _hraAmount = 0.0;
  double _otherDeductionsAmount = 0.0;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Get current profile ID from arguments or data manager
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _currentProfileId =
          args?['profileId'] ?? await _dataManager.getCurrentProfile();

      // Load saved deductions data
      final deductionsData =
          await _dataManager.loadDeductionsData(_currentProfileId);

      // Load income data to calculate gross income
      final incomeData = await _dataManager.loadIncomeData(_currentProfileId);
      _grossIncome = _calculateGrossIncome(incomeData);

      setState(() {
        _section80CAmount = deductionsData['section_80c']?.toDouble() ?? 0.0;
        _section80DAmount = deductionsData['section_80d']?.toDouble() ?? 0.0;
        _hraAmount = deductionsData['hra_amount']?.toDouble() ?? 0.0;
        _otherDeductionsAmount =
            deductionsData['other_deductions']?.toDouble() ?? 0.0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Failed to load saved data');
    }
  }

  double _calculateGrossIncome(Map<String, Map<String, String>> incomeData) {
    double total = 0;
    for (String category in incomeData.keys) {
      for (String field in incomeData[category]!.keys) {
        String value = incomeData[category]![field] ?? '';
        String cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
        double? amount = double.tryParse(cleanValue);
        if (amount != null) {
          total += amount;
        }
      }
    }
    return total;
  }

  double get _totalDeductions =>
      _section80CAmount +
      _section80DAmount +
      _hraAmount +
      _otherDeductionsAmount +
      _standardDeduction;

  double get _taxableIncomeWithoutDeductions =>
      _grossIncome - _standardDeduction;

  double get _taxableIncomeWithDeductions =>
      _grossIncome - _totalDeductions > 0 ? _grossIncome - _totalDeductions : 0;

  double get _estimatedTaxSaving {
    double savingAmount =
        _taxableIncomeWithoutDeductions - _taxableIncomeWithDeductions;
    // Simplified tax calculation - assuming 30% tax bracket
    return savingAmount * 0.30;
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Future<void> _autoSaveDeductions() async {
    try {
      final deductionsData = {
        'section_80c': _section80CAmount,
        'section_80d': _section80DAmount,
        'hra_amount': _hraAmount,
        'other_deductions': _otherDeductionsAmount,
        'last_updated': DateTime.now().toIso8601String(),
      };

      await _dataManager.saveDeductionsData(_currentProfileId, deductionsData);
    } catch (e) {
      // Silent fail for auto-save
    }
  }

  Future<void> _saveDeductions() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Haptic feedback
      HapticFeedback.mediumImpact();

      final deductionsData = {
        'section_80c': _section80CAmount,
        'section_80d': _section80DAmount,
        'hra_amount': _hraAmount,
        'other_deductions': _otherDeductionsAmount,
        'last_updated': DateTime.now().toIso8601String(),
        'gross_income': _grossIncome,
        'total_deductions': _totalDeductions,
        'estimated_tax_saving': _estimatedTaxSaving,
      };

      await _dataManager.saveDeductionsData(_currentProfileId, deductionsData);

      setState(() {
        _isSaving = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Deductions saved successfully!'),
          backgroundColor: AppTheme.successLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
              label: 'View Details',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/tax-details-screen',
                    arguments: {'profileId': _currentProfileId});
              })));
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorMessage('Failed to save deductions. Please try again.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          CustomIconWidget(iconName: 'error', color: Colors.white, size: 20),
          SizedBox(width: 2.w),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3)));
  }

  void _onDeductionChanged(String type, double amount) {
    setState(() {
      switch (type) {
        case 'section_80c':
          _section80CAmount = amount;
          break;
        case 'section_80d':
          _section80DAmount = amount;
          break;
        case 'hra':
          _hraAmount = amount;
          break;
        case 'others':
          _otherDeductionsAmount = amount;
          break;
      }
    });

    // Auto-save after changes
    _autoSaveDeductions();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
          backgroundColor:
              isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
          body: Center(
              child: CircularProgressIndicator(
                  color: AppTheme.lightTheme.colorScheme.primary)));
    }

    return Scaffold(
        backgroundColor:
            isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        appBar: AppBar(
            title:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Deductions & Exemptions',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Text(_currentFinancialYear,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppTheme.textMediumEmphasisDark
                          : AppTheme.textMediumEmphasisLight)),
            ]),
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    size: 24,
                    color: isDark
                        ? AppTheme.textHighEmphasisDark
                        : AppTheme.textHighEmphasisLight)),
            actions: [
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: Text('Tax Deductions Guide',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              content: SingleChildScrollView(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                    Text(
                                        'Enter your eligible deductions to reduce taxable income:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium),
                                    SizedBox(height: 2.h),
                                    _buildGuideItem('Section 80C',
                                        'Investments like EPF, PPF, ELSS (₹1.5L limit)'),
                                    _buildGuideItem('Section 80D',
                                        'Medical insurance premiums'),
                                    _buildGuideItem('HRA',
                                        'House rent allowance exemption'),
                                    _buildGuideItem('Others',
                                        'Additional deductions like 80G, 80E, etc.'),
                                  ])),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Got it')),
                              ]);
                        });
                  },
                  icon: CustomIconWidget(
                      iconName: 'help_outline',
                      size: 24,
                      color: isDark
                          ? AppTheme.textHighEmphasisDark
                          : AppTheme.textHighEmphasisLight)),
            ]),
        body: SafeArea(
            child: Column(children: [
          // Header Summary
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              margin: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.1),
                      ]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.2))),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gross Income',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: isDark
                                            ? AppTheme.textMediumEmphasisDark
                                            : AppTheme
                                                .textMediumEmphasisLight)),
                            Text('₹${_formatAmount(_grossIncome)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Total Deductions',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: isDark
                                            ? AppTheme.textMediumEmphasisDark
                                            : AppTheme
                                                .textMediumEmphasisLight)),
                            Text('₹${_formatAmount(_totalDeductions)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary)),
                          ]),
                    ]),
              ])),

          // Scrollable Content
          Expanded(
              child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(children: [
                    // Section 80C Card
                    Section80CCard(
                        onTotalChanged: (amount) =>
                            _onDeductionChanged('section_80c', amount)),

                    // Section 80D Card
                    Section80DCard(
                        onTotalChanged: (amount) =>
                            _onDeductionChanged('section_80d', amount)),

                    // HRA Deduction Card
                    HRADeductionCard(
                        onTotalChanged: (amount) =>
                            _onDeductionChanged('hra', amount)),

                    // Other Deductions Card
                    OtherDeductionsCard(
                        onTotalChanged: (amount) =>
                            _onDeductionChanged('others', amount)),

                    // Tax Impact Summary
                    if (_totalDeductions > _standardDeduction)
                      TaxImpactSummary(
                          totalDeductions: _totalDeductions,
                          estimatedTaxSaving: _estimatedTaxSaving,
                          taxableIncomeWithoutDeductions:
                              _taxableIncomeWithoutDeductions,
                          taxableIncomeWithDeductions:
                              _taxableIncomeWithDeductions),

                    SizedBox(height: 10.h), // Space for floating button
                  ]))),
        ])),

        // Floating Save Button
        floatingActionButton: Container(
            width: 90.w,
            height: 6.h,
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            child: ElevatedButton(
                onPressed: _isSaving ? null : _saveDeductions,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                    elevation: 4,
                    shadowColor: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: _isSaving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.lightTheme.colorScheme.onPrimary)))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            CustomIconWidget(
                                iconName: 'save',
                                size: 20,
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary),
                            SizedBox(width: 2.w),
                            Text('Save Changes',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme
                                            .lightTheme.colorScheme.onPrimary)),
                          ]))),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }

  Widget _buildGuideItem(String title, String description) {
    return Padding(
        padding: EdgeInsets.only(bottom: 1.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary)),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
        ]));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
