import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/capital_gains_selector.dart';
import './widgets/city_tier_selector.dart';
import './widgets/income_category_header.dart';
import './widgets/income_input_card.dart';
import './widgets/tax_impact_preview.dart';

class IncomeInputScreen extends StatefulWidget {
  const IncomeInputScreen({super.key});

  @override
  State<IncomeInputScreen> createState() => _IncomeInputScreenState();
}

class _IncomeInputScreenState extends State<IncomeInputScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isMonthly = true;
  String _selectedCityTier = 'metro';
  String _selectedCapitalGainsType = 'short_term_normal';

  // Income data storage
  final Map<String, Map<String, String>> _incomeData = {
    'salary': {
      'basic_da': '',
      'hra': '',
      'bonus': '',
      'other_allowances': '',
    },
    'business': {
      'business_income': '',
      'professional_income': '',
      'other_business': '',
    },
    'capital_gains': {
      'capital_gains_amount': '',
    },
    'other_sources': {
      'savings_interest': '',
      'fixed_deposits': '',
      'other_income': '',
    },
  };

  final List<Map<String, dynamic>> _incomeCategories = [
    {
      'title': 'Salary & Income',
      'key': 'salary',
      'fields': [
        {
          'key': 'basic_da',
          'label': 'Basic + DA',
          'tooltip': 'Basic salary plus Dearness Allowance',
        },
        {
          'key': 'hra',
          'label': 'House Rent Allowance (HRA)',
          'tooltip': 'HRA received from employer',
        },
        {
          'key': 'bonus',
          'label': 'Bonus & Incentives',
          'tooltip': 'Annual bonus and performance incentives',
        },
        {
          'key': 'other_allowances',
          'label': 'Other Allowances',
          'tooltip': 'Transport, medical, and other allowances',
        },
      ],
    },
    {
      'title': 'Business & Profession',
      'key': 'business',
      'fields': [
        {
          'key': 'business_income',
          'label': 'Business Income',
          'tooltip': 'Income from business activities',
        },
        {
          'key': 'professional_income',
          'label': 'Professional Income',
          'tooltip': 'Income from professional services',
        },
        {
          'key': 'other_business',
          'label': 'Other Business Income',
          'tooltip': 'Any other business-related income',
        },
      ],
    },
    {
      'title': 'Capital Gains',
      'key': 'capital_gains',
      'fields': [
        {
          'key': 'capital_gains_amount',
          'label': 'Capital Gains Amount',
          'tooltip': 'Gains from sale of capital assets',
        },
      ],
    },
    {
      'title': 'Other Sources',
      'key': 'other_sources',
      'fields': [
        {
          'key': 'savings_interest',
          'label': 'Savings Bank Interest',
          'tooltip': 'Interest earned from savings accounts',
        },
        {
          'key': 'fixed_deposits',
          'label': 'Fixed Deposits Interest',
          'tooltip': 'Interest from FDs and term deposits',
        },
        {
          'key': 'other_income',
          'label': 'Other Income',
          'tooltip': 'Any other miscellaneous income',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _incomeCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFieldChanged(String category, String fieldKey, String value) {
    setState(() {
      _incomeData[category]?[fieldKey] = value;
    });
  }

  void _onToggleChanged(bool isMonthly) {
    setState(() {
      _isMonthly = isMonthly;
      // Convert existing values
      _convertAllValues();
    });
  }

  void _convertAllValues() {
    for (String category in _incomeData.keys) {
      for (String field in _incomeData[category]!.keys) {
        String currentValue = _incomeData[category]![field] ?? '';
        if (currentValue.isNotEmpty) {
          double? amount = _parseAmount(currentValue);
          if (amount != null) {
            double convertedAmount = _isMonthly ? amount / 12 : amount * 12;
            _incomeData[category]![field] =
                _formatCurrency(convertedAmount.toString());
          }
        }
      }
    }
  }

  double? _parseAmount(String value) {
    String cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanValue);
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';

    String cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleanValue.isEmpty) return '';

    double? number = double.tryParse(cleanValue);
    if (number == null) return value;

    String formatted = number.toStringAsFixed(0);

    if (formatted.length > 3) {
      String result = '';
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        if (count == 3) {
          result = ',$result';
          count = 0;
        }
        result = formatted[i] + result;
        count++;

        if (count == 2 && i > 1) {
          result = ',$result';
          count = 0;
        }
      }
      formatted = result;
    }

    return formatted;
  }

  double _calculateTotalIncome() {
    double total = 0;
    for (String category in _incomeData.keys) {
      for (String field in _incomeData[category]!.keys) {
        String value = _incomeData[category]![field] ?? '';
        double? amount = _parseAmount(value);
        if (amount != null) {
          total += amount;
        }
      }
    }
    return total;
  }

  double _calculateEstimatedTax(double income) {
    // Simplified tax calculation for preview
    if (income <= 250000) return 0;
    if (income <= 500000) return (income - 250000) * 0.05;
    if (income <= 1000000) return 12500 + (income - 500000) * 0.20;
    return 112500 + (income - 1000000) * 0.30;
  }

  void _saveAndContinue() {
    // Auto-save functionality
    _showSaveConfirmation();

    // Navigate to deductions screen
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushNamed(context, '/deductions-input-screen');
    });
  }

  void _showSaveConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.tertiary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            const Text('Income data saved successfully!'),
          ],
        ),
        backgroundColor:
            AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalIncome = _calculateTotalIncome();
    double estimatedTax = _calculateEstimatedTax(totalIncome);

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          IncomeCategoryHeader(
            categoryTitle: _incomeCategories[_tabController.index]['title'],
            isMonthly: _isMonthly,
            onToggleChanged: _onToggleChanged,
            onBackPressed: () => Navigator.pop(context),
          ),
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              tabs: _incomeCategories.map((category) {
                return Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Text(
                      category['title'],
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                );
              }).toList(),
              onTap: (index) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _incomeCategories.map((category) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),
                      IncomeInputCard(
                        title: category['title'],
                        fields:
                            (category['fields'] as List<Map<String, dynamic>>)
                                .map((field) {
                          return {
                            ...field,
                            'value': _incomeData[category['key']]
                                    ?[field['key']] ??
                                '',
                          };
                        }).toList(),
                        isMonthly: _isMonthly,
                        onFieldChanged: (fieldKey, value) =>
                            _onFieldChanged(category['key'], fieldKey, value),
                        additionalContent:
                            _buildAdditionalContent(category['key']),
                      ),
                      SizedBox(height: 2.h),
                      TaxImpactPreview(
                        totalIncome: totalIncome,
                        estimatedTax: estimatedTax,
                        isMonthly: _isMonthly,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              offset: const Offset(0, -2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _saveAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Save & Continue',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  CustomIconWidget(
                    iconName: 'arrow_forward',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildAdditionalContent(String categoryKey) {
    switch (categoryKey) {
      case 'salary':
        return CityTierSelector(
          selectedTier: _selectedCityTier,
          onTierChanged: (tier) {
            setState(() {
              _selectedCityTier = tier;
            });
          },
        );
      case 'capital_gains':
        return CapitalGainsSelector(
          selectedType: _selectedCapitalGainsType,
          onTypeChanged: (type) {
            setState(() {
              _selectedCapitalGainsType = type;
            });
          },
        );
      default:
        return null;
    }
  }
}
