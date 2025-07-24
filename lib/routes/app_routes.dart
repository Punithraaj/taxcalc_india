import 'package:flutter/material.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/income_input_screen/income_input_screen.dart';
import '../presentation/profile_selection_screen/profile_selection_screen.dart';
import '../presentation/main_dashboard/main_dashboard.dart';
import '../presentation/tax_details_screen/tax_details_screen.dart';
import '../presentation/deductions_input_screen/deductions_input_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String authenticationScreen = '/authentication-screen';
  static const String incomeInputScreen = '/income-input-screen';
  static const String profileSelectionScreen = '/profile-selection-screen';
  static const String mainDashboard = '/main-dashboard';
  static const String taxDetailsScreen = '/tax-details-screen';
  static const String deductionsInputScreen = '/deductions-input-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => AuthenticationScreen(),
    authenticationScreen: (context) => AuthenticationScreen(),
    incomeInputScreen: (context) => IncomeInputScreen(),
    profileSelectionScreen: (context) => ProfileSelectionScreen(),
    mainDashboard: (context) => MainDashboard(),
    taxDetailsScreen: (context) => TaxDetailsScreen(),
    deductionsInputScreen: (context) => DeductionsInputScreen(),
    // TODO: Add your other routes here
  };
}
