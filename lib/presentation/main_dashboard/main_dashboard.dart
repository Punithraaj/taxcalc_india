import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/deduction_card_widget.dart';
import './widgets/financial_year_dropdown_widget.dart';
import './widgets/income_category_chip_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/regime_comparison_card_widget.dart';
import './widgets/tax_flowchart_widget.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  String selectedFinancialYear = 'FY 2024-25';
  String selectedProfile = 'Rahul Sharma';
  String profileType = 'Salaried Professional';
  bool isRefreshing = false;

  // Mock tax calculation data
  final Map<String, dynamic> taxCalculationData = {
    "oldRegime": {
      "totalTax": 125000.0,
      "effectiveRate": 18.5,
      "grossIncome": 850000.0,
      "totalDeductions": 175000.0,
      "taxableIncome": 675000.0,
    },
    "newRegime": {
      "totalTax": 98000.0,
      "effectiveRate": 14.8,
      "grossIncome": 850000.0,
      "totalDeductions": 50000.0,
      "taxableIncome": 800000.0,
    },
  };

  final List<Map<String, dynamic>> incomeCategories = [
    {
      "name": "Salary",
      "completionPercentage": 100.0,
      "isCompleted": true,
      "route": "/income-input-screen",
    },
    {
      "name": "Business",
      "completionPercentage": 0.0,
      "isCompleted": false,
      "route": "/income-input-screen",
    },
    {
      "name": "Capital Gains",
      "completionPercentage": 65.0,
      "isCompleted": false,
      "route": "/income-input-screen",
    },
    {
      "name": "Other Sources",
      "completionPercentage": 100.0,
      "isCompleted": true,
      "route": "/income-input-screen",
    },
  ];

  final List<Map<String, dynamic>> deductionsList = [
    {
      "type": "Standard Deduction",
      "code": "Standard",
      "utilized": 50000.0,
      "limit": 50000.0,
      "description": "Standard deduction available to all salaried individuals",
    },
    {
      "type": "Life Insurance Premium",
      "code": "Section 80C",
      "utilized": 150000.0,
      "limit": 150000.0,
      "description": "Investment in PPF, ELSS, Life Insurance, etc.",
    },
    {
      "type": "Health Insurance Premium",
      "code": "Section 80D",
      "utilized": 25000.0,
      "limit": 25000.0,
      "description": "Medical insurance premium for self and family",
    },
    {
      "type": "House Rent Allowance",
      "code": "HRA",
      "utilized": 120000.0,
      "limit": 0.0,
      "description": "HRA exemption based on actual rent paid",
    },
    {
      "type": "Education Loan Interest",
      "code": "Section 80E",
      "utilized": 0.0,
      "limit": 0.0,
      "description": "Interest paid on education loan",
    },
    {
      "type": "Donations to Charity",
      "code": "Section 80G",
      "utilized": 15000.0,
      "limit": 0.0,
      "description": "Donations to approved charitable institutions",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final oldRegimeData =
        taxCalculationData["oldRegime"] as Map<String, dynamic>;
    final newRegimeData =
        taxCalculationData["newRegime"] as Map<String, dynamic>;
    final bool isNewRegimeBetter = (newRegimeData["totalTax"] as double) <
        (oldRegimeData["totalTax"] as double);
    final double savingsAmount = (oldRegimeData["totalTax"] as double) -
        (newRegimeData["totalTax"] as double);

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: CustomIconWidget(
              iconName: 'menu',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'TaxCalc India',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'notifications_outlined',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                children: [
                  Expanded(
                    child: ProfileHeaderWidget(
                      profileName: selectedProfile,
                      profileType: profileType,
                      onProfileTap: () {
                        Navigator.pushNamed(
                            context, '/profile-selection-screen');
                      },
                    ),
                  ),
                  SizedBox(width: 3.w),
                  FinancialYearDropdownWidget(
                    selectedYear: selectedFinancialYear,
                    onYearChanged: (String newYear) {
                      setState(() {
                        selectedFinancialYear = newYear;
                      });
                      _recalculateTax();
                    },
                  ),
                ],
              ),
              SizedBox(height: 3.h),

              // Regime Comparison Section
              Text(
                'Tax Regime Comparison',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: RegimeComparisonCardWidget(
                      regimeType: 'Old Regime',
                      totalTax: oldRegimeData["totalTax"] as double,
                      effectiveRate: oldRegimeData["effectiveRate"] as double,
                      isBetterOption: !isNewRegimeBetter,
                      savingsAmount:
                          isNewRegimeBetter ? 0.0 : savingsAmount.abs(),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: RegimeComparisonCardWidget(
                      regimeType: 'New Regime',
                      totalTax: newRegimeData["totalTax"] as double,
                      effectiveRate: newRegimeData["effectiveRate"] as double,
                      isBetterOption: isNewRegimeBetter,
                      savingsAmount:
                          isNewRegimeBetter ? savingsAmount.abs() : 0.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),

              // Income Categories Section
              Text(
                'Income Categories',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                height: 8.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: incomeCategories.length,
                  itemBuilder: (context, index) {
                    final category =
                        incomeCategories[index];
                    return IncomeCategoryChipWidget(
                      categoryName: category["name"] as String,
                      completionPercentage:
                          category["completionPercentage"] as double,
                      isCompleted: category["isCompleted"] as bool,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(
                            context, category["route"] as String);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 4.h),

              // Exemptions & Deductions Section
              Text(
                'Exemptions & Deductions',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: deductionsList.length,
                itemBuilder: (context, index) {
                  final deduction =
                      deductionsList[index];
                  return DeductionCardWidget(
                    deductionType: deduction["type"] as String,
                    deductionCode: deduction["code"] as String,
                    utilizedAmount: deduction["utilized"] as double,
                    limitAmount: deduction["limit"] as double,
                    description: deduction["description"] as String,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, '/deductions-input-screen');
                    },
                  );
                },
              ),
              SizedBox(height: 4.h),

              // Tax Flowchart Section
              Text(
                'Tax Calculation Breakdown',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              TaxFlowchartWidget(
                grossIncome: isNewRegimeBetter
                    ? newRegimeData["grossIncome"] as double
                    : oldRegimeData["grossIncome"] as double,
                totalDeductions: isNewRegimeBetter
                    ? newRegimeData["totalDeductions"] as double
                    : oldRegimeData["totalDeductions"] as double,
                taxableIncome: isNewRegimeBetter
                    ? newRegimeData["taxableIncome"] as double
                    : oldRegimeData["taxableIncome"] as double,
                totalTax: isNewRegimeBetter
                    ? newRegimeData["totalTax"] as double
                    : oldRegimeData["totalTax"] as double,
                selectedRegime: isNewRegimeBetter ? 'New Regime' : 'Old Regime',
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(context, '/tax-details-screen');
        },
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        icon: CustomIconWidget(
          iconName: 'visibility',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 20,
        ),
        label: Text(
          'View Tax Details',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        selectedProfile.isNotEmpty
                            ? selectedProfile[0].toUpperCase()
                            : 'U',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    selectedProfile,
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    profileType,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                children: [
                  _buildDrawerItem(
                    icon: 'person',
                    title: 'Profiles',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile-selection-screen');
                    },
                  ),
                  _buildDrawerItem(
                    icon: 'settings',
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: 'contact_support',
                    title: 'Contact & About',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: 'login',
                    title: 'Login / Sign Up',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/authentication-screen');
                    },
                  ),
                  _buildDrawerItem(
                    icon: 'star',
                    title: 'Go Premium',
                    onTap: () {
                      Navigator.pop(context);
                    },
                    isHighlighted: true,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: Text(
                'Version 1.0.0',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: isHighlighted
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          color: isHighlighted
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.onSurface,
          fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 0.5.h),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isRefreshing = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate recalculation
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isRefreshing = false;
    });
  }

  void _recalculateTax() {
    HapticFeedback.lightImpact();
    // Simulate tax recalculation based on selected financial year
    // In a real app, this would trigger actual tax calculations
  }
}
