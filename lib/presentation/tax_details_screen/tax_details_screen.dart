import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/additional_taxes_widget.dart';
import './widgets/final_tax_summary_widget.dart';
import './widgets/regime_comparison_widget.dart';
import './widgets/tax_flowchart_widget.dart';
import './widgets/tax_slab_widget.dart';

class TaxDetailsScreen extends StatefulWidget {
  const TaxDetailsScreen({super.key});

  @override
  State<TaxDetailsScreen> createState() => _TaxDetailsScreenState();
}

class _TaxDetailsScreenState extends State<TaxDetailsScreen> {
  String selectedFinancialYear = 'FY 2024-25';
  String selectedRegime = 'New';

  // Mock tax calculation data
  final Map<String, dynamic> mockTaxData = {
    'grossIncome': 1200000.0,
    'basicSalary': 800000.0,
    'hra': 200000.0,
    'bonus': 100000.0,
    'otherAllowances': 100000.0,
    'businessIncome': 0.0,
    'capitalGains': 50000.0,
    'otherSources': 25000.0,
    'standardDeduction': 50000.0,
    'section80C': 150000.0,
    'section80D': 25000.0,
    'section80G': 10000.0,
    'section80E': 20000.0,
    'hraExemption': 80000.0,
    'totalDeductions': 335000.0,
    'taxableIncome': 865000.0,
    'oldRegimeTax': 112500.0,
    'newRegimeTax': 78000.0,
    'surcharge': 0.0,
    'healthEducationCess': 3120.0,
    'tdsAmount': 45000.0,
    'advanceTax': 30000.0,
    'selfAssessmentTax': 0.0,
  };

  final List<Map<String, dynamic>> specialRateTaxes = [
    {
      'type': 'Short Term Capital Gains (Normal)',
      'amount': 15000.0,
      'rate': '30%',
    },
    {
      'type': 'Long Term Capital Gains (12.5%)',
      'amount': 6250.0,
      'rate': '12.5%',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double currentRegimeTax = selectedRegime == 'New'
        ? mockTaxData['newRegimeTax'] as double
        : mockTaxData['oldRegimeTax'] as double;

    final double totalTaxLiability = currentRegimeTax +
        (mockTaxData['surcharge'] as double) +
        (mockTaxData['healthEducationCess'] as double) +
        specialRateTaxes.fold(
            0.0, (sum, tax) => sum + (tax['amount'] as double));

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              RegimeComparisonWidget(
                selectedRegime: selectedRegime,
                oldRegimeTax: mockTaxData['oldRegimeTax'] as double,
                newRegimeTax: mockTaxData['newRegimeTax'] as double,
                onRegimeToggle: _toggleRegime,
              ),
              TaxFlowchartWidget(
                grossIncome: mockTaxData['grossIncome'] as double,
                totalDeductions: mockTaxData['totalDeductions'] as double,
                taxableIncome: mockTaxData['taxableIncome'] as double,
                totalTax: totalTaxLiability,
              ),
              TaxSlabWidget(
                regime: selectedRegime,
                taxableIncome: mockTaxData['taxableIncome'] as double,
              ),
              AdditionalTaxesWidget(
                baseTax: currentRegimeTax,
                surcharge: mockTaxData['surcharge'] as double,
                healthEducationCess:
                    mockTaxData['healthEducationCess'] as double,
                specialRateTaxes: specialRateTaxes,
              ),
              FinalTaxSummaryWidget(
                totalTaxLiability: totalTaxLiability,
                tdsAmount: mockTaxData['tdsAmount'] as double,
                advanceTax: mockTaxData['advanceTax'] as double,
                selfAssessmentTax: mockTaxData['selfAssessmentTax'] as double,
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
      elevation: AppTheme.lightTheme.appBarTheme.elevation,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
          size: 24,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tax Details',
            style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
          ),
          Text(
            '$selectedFinancialYear • $selectedRegime Regime',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.appBarTheme.foregroundColor
                  ?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: _onFinancialYearSelected,
          icon: CustomIconWidget(
            iconName: 'calendar_today',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 22,
          ),
          itemBuilder: (context) => [
            'FY 2024-25',
            'FY 2023-24',
            'FY 2022-23',
            'FY 2021-22',
            'FY 2020-21',
            'FY 2019-20',
          ]
              .map((year) => PopupMenuItem(
                    value: year,
                    child: Text(
                      year,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: year == selectedFinancialYear
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: year == selectedFinancialYear
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ))
              .toList(),
        ),
        IconButton(
          onPressed: _showTaxBreakdownInfo,
          icon: CustomIconWidget(
            iconName: 'info_outline',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 22,
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  void _toggleRegime() {
    setState(() {
      selectedRegime = selectedRegime == 'New' ? 'Old' : 'New';
    });
  }

  void _onFinancialYearSelected(String year) {
    setState(() {
      selectedFinancialYear = year;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to $year'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showTaxBreakdownInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Tax Calculation Info',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoItem('Gross Income',
                  'Total income from all sources before deductions'),
              _buildInfoItem('Total Deductions',
                  'Sum of all eligible deductions under various sections'),
              _buildInfoItem('Taxable Income',
                  'Income after deducting all eligible deductions'),
              _buildInfoItem('Surcharge',
                  'Additional tax on high income earners (above ₹50 lakhs)'),
              _buildInfoItem('Health & Education Cess',
                  '4% cess on total tax + surcharge'),
              _buildInfoItem('Special Rate Taxes',
                  'Capital gains and other income taxed at special rates'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: AppTheme.lightTheme.textButtonTheme.style?.textStyle
                  ?.resolve({})?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            description,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
