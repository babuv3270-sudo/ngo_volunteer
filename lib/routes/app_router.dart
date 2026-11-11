import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/opportunity.dart';
import '../models/volunteer_event.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/ngo/edit_ngo_profile_screen.dart';
import '../screens/ngo/event_form_screen.dart';
import '../screens/ngo/event_registrations_screen.dart';
import '../screens/ngo/ngo_shell.dart';
import '../screens/ngo/opportunity_applicants_screen.dart';
import '../screens/ngo/opportunity_form_screen.dart';
import '../screens/shared/splash_screen.dart';
import '../screens/volunteer/edit_profile_screen.dart';
import '../screens/volunteer/event_details_screen.dart';
import '../screens/volunteer/opportunity_details_screen.dart';
import '../screens/volunteer/settings_screen.dart';
import '../screens/volunteer/volunteer_shell.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _route(const SplashScreen());
      case AppRoutes.onboarding:
        return _route(const OnboardingScreen());
      case AppRoutes.roleSelection:
        return _route(const RoleSelectionScreen());
      case AppRoutes.login:
        return _route(const LoginScreen());
      case AppRoutes.forgotPassword:
        return _route(const ForgotPasswordScreen());
      case AppRoutes.register:
        final UserRole role = settings.arguments is UserRole
            ? settings.arguments as UserRole
            : UserRole.volunteer;
        return _route(RegisterScreen(role: role));
      case AppRoutes.volunteerHome:
        return _route(const VolunteerShell());
      case AppRoutes.opportunityDetails:
        return _route(OpportunityDetailsScreen(
          opportunityId: settings.arguments as String,
        ));
      case AppRoutes.eventDetails:
        return _route(EventDetailsScreen(
          eventId: settings.arguments as String,
        ));
      case AppRoutes.editProfile:
        return _route(const EditProfileScreen());
      case AppRoutes.settings:
        return _route(const SettingsScreen());
      case AppRoutes.editNgoProfile:
        return _route(const EditNgoProfileScreen());
      case AppRoutes.ngoSettings:
        return _route(
          const SettingsScreen(
            profileTitle: 'Organization profile',
            profileSubtitle: 'About, contact and location',
            editProfileRoute: AppRoutes.editNgoProfile,
          ),
        );
      case AppRoutes.ngoOpportunityForm:
        return _route(OpportunityFormScreen(
          existing: settings.arguments as Opportunity?,
        ));
      case AppRoutes.ngoApplicants:
        return _route(OpportunityApplicantsScreen(
          opportunityId: settings.arguments as String,
        ));
      case AppRoutes.ngoEventForm:
        return _route(EventFormScreen(
          existing: settings.arguments as VolunteerEvent?,
        ));
      case AppRoutes.ngoRegistrations:
        return _route(EventRegistrationsScreen(
          eventId: settings.arguments as String,
        ));
      case AppRoutes.ngoHome:
        return _route(const NgoShell());
      default:
        return _route(const SplashScreen());
    }
  }

  static MaterialPageRoute<dynamic> _route(Widget screen) {
    return MaterialPageRoute<dynamic>(builder: (_) => screen);
  }
}