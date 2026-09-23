import 'package:digaxy/app/modules/helper/home/bindings/helper_delivery_detail_binding.dart';
import 'package:digaxy/app/modules/helper/home/bindings/helper_registration_binding.dart';
import 'package:digaxy/app/modules/helper/home/views/helper_delivery_detail_view.dart';
import 'package:digaxy/app/modules/helper/notification/bindings/helper_notification_binding.dart';
import 'package:digaxy/app/modules/helper/settings/views/helper_help_ack_view.dart';
import 'package:digaxy/app/modules/mover/home/views/mover_notifications_view.dart';
import 'package:get/get.dart';

import '../modules/driver/home/bindings/driver_home_binding.dart';
import '../modules/driver/home/views/driver_home_view.dart';
import '../modules/driver/earnings/views/earnings_view(unused).dart';
import '../modules/driver/earnings/bindings/earnings_binding.dart';
import '../modules/driver/notification/views/notification_view.dart';
import '../modules/driver/notification/bindings/notification_binding.dart';
import '../modules/driver/profile/views/profile_view.dart';
import '../modules/driver/profile/bindings/profile_binding.dart';
import '../modules/driver/priority/views/priority_view.dart';
import '../modules/driver/priority/bindings/priority_binding.dart';
import '../modules/driver/settings/views/settings_view.dart';
import '../modules/driver/settings/bindings/settings_binding.dart';
import '../modules/driver/settings/views/change_password_view.dart';
import '../modules/driver/settings/views/privacy_view.dart';
import '../modules/driver/settings/views/terms_view.dart';
import '../modules/driver/settings/views/help_view.dart';
import '../modules/driver/settings/views/help_ack_view.dart';
import '../modules/driver/profile/views/edit_profile_view.dart';
import '../modules/driver/profile/bindings/edit_profile_binding.dart';
import '../modules/driver/task/views/task_detail_view.dart';
import '../modules/driver/task/bindings/task_binding.dart';
import '../modules/driver/task/views/task_active_view.dart';
import '../modules/driver/task/views/task_live_view.dart';
import '../modules/driver/task/bindings/task_live_binding.dart';
import '../modules/driver/task/bindings/task_active_binding.dart';
import '../modules/driver/earnings/views/payout_view.dart';
import '../modules/driver/earnings/bindings/payout_binding.dart';
import '../modules/driver/earnings/views/enter_amount_view.dart';
import '../modules/driver/earnings/views/confirm_payout_view.dart';
import '../modules/driver/earnings/views/payout_success_view.dart';
import '../modules/driver/home/views/delivery_detail_view.dart';
import '../modules/driver/home/bindings/delivery_detail_binding.dart';
import '../modules/helper/home/bindings/helper_home_binding.dart';
import '../modules/helper/home/views/helper_home_view.dart';
import '../modules/helper/home/views/helper_registration_view.dart';
import '../modules/helper/profile/bindings/helper_profile_binding.dart';
import '../modules/helper/profile/views/helper_profile_view.dart';
import '../modules/helper/profile/views/helper_edit_profile_view.dart';
import '../modules/helper/priority/bindings/helper_priority_binding.dart';
import '../modules/helper/priority/views/helper_priority_view.dart';
import '../modules/helper/settings/bindings/helper_settings_binding.dart';
import '../modules/helper/settings/views/helper_settings_view.dart';
import '../modules/helper/settings/views/helper_change_password_view.dart';
import '../modules/helper/settings/views/helper_privacy_view.dart';
import '../modules/helper/settings/views/helper_terms_view.dart';
import '../modules/helper/settings/views/helper_help_view.dart';
import '../modules/mover/home/bindings/mover_home_binding.dart';
import '../modules/mover/home/bindings/mover_notifications_binding.dart';
import '../modules/mover/home/bindings/mover_create_parcel_binding.dart';
import '../modules/mover/home/views/mover_home_view.dart';
import '../modules/mover/home/views/mover_create_parcel_view.dart';
import '../modules/helper/notification/views/helper_notification_view.dart';
import '../modules/helper/task/bindings/helper_task_binding.dart';
import '../modules/helper/task/views/helper_task_detail_view.dart';
import '../modules/helper/task/views/helper_task_active_view.dart';
import '../modules/helper/task/views/helper_task_live_view.dart';
import '../modules/helper/task/bindings/helper_task_active_binding.dart';
import '../modules/helper/task/bindings/helper_task_live_binding.dart';
import '../modules/helper/earnings/bindings/earnings_binding.dart';
import '../modules/helper/earnings/bindings/payout_binding.dart';
import '../modules/helper/earnings/views/earnings_view.dart';
import '../modules/helper/earnings/views/payout_view.dart';
import '../modules/helper/earnings/views/enter_amount_view.dart';
import '../modules/helper/earnings/views/confirm_payout_view.dart';
import '../modules/helper/earnings/views/payout_success_view.dart';
import '../modules/mover/home/views/mover_services_view.dart';
import '../modules/mover/home/views/mover_contact_moving_details_view.dart';
import '../modules/mover/home/views/mover_pickup_location_view.dart';
import '../modules/mover/home/views/mover_dropoff_location_view.dart';
import '../modules/mover/home/views/mover_estimate_view.dart';
import '../modules/mover/home/views/mover_schedule_view.dart';
import '../modules/mover/home/views/mover_booking_confirmed_view.dart';
import '../modules/mover/home/views/mover_parcel_tracking_view.dart';
import '../modules/mover/home/views/mover_city_detail_view.dart';
import '../modules/mover/profile/bindings/mover_profile_binding.dart';
import '../modules/mover/profile/views/mover_profile_view.dart';
import '../modules/mover/profile/bindings/mover_edit_profile_binding.dart';
import '../modules/mover/profile/views/mover_edit_profile_view.dart';
import '../modules/mover/settings/bindings/mover_settings_binding.dart';
import '../modules/mover/settings/views/mover_settings_view.dart';
import '../modules/mover/settings/views/mover_change_password_view.dart';
import '../modules/mover/settings/views/mover_privacy_view.dart';
import '../modules/mover/settings/views/mover_terms_view.dart';
import '../modules/mover/settings/views/mover_help_view.dart';
import '../modules/mover/settings/views/mover_help_ack_view.dart';

import '../modules/landing/bindings/splash1_binding.dart';
import '../modules/landing/views/splash1_view.dart';
import '../modules/landing/bindings/splash2_binding.dart';
import '../modules/landing/views/splash2_view.dart';
import '../modules/landing/bindings/role_selection_binding.dart';
import '../modules/landing/views/role_selection_view.dart';
import '../modules/landing/bindings/onboarding_binding.dart';
import '../modules/landing/views/onboarding_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/verify_email_view.dart';
import '../modules/auth/views/new_password_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // Start the app at the first splash screen
  static const INITIAL = Routes.LANDING_SPLASH1;

  static final routes = [
    GetPage(
      name: _Paths.LANDING_SPLASH1,
      page: () => const Splash1View(),
      binding: Splash1Binding(),
    ),
    GetPage(
      name: _Paths.LANDING_SPLASH2,
      page: () => const Splash2View(),
      binding: Splash2Binding(),
    ),
    GetPage(
      name: _Paths.LANDING_ROLE,
      page: () => const RoleSelectionView(),
      binding: RoleSelectionBinding(),
    ),
    GetPage(
      name: _Paths.LANDING_ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),

    // auth pages
    GetPage(
      name: _Paths.AUTH_LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_SIGNUP,
      page: () => const SignUpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_FORGOT,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_VERIFY,
      page: () => const VerifyEmailView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_NEW_PASSWORD,
      page: () => const NewPasswordView(),
      binding: AuthBinding(),
    ),

    // module home pages
    GetPage(
      name: _Paths.MOVER_HOME,
      page: () => const MoverHomeView(),
      binding: MoverHomeBinding(),
    ),
    GetPage(
      name: _Paths.MOVER_CREATE_PARCEL,
      page: () => const MoverCreateParcelView(),
      binding: MoverCreateParcelBinding(),
    ),
    GetPage(name: _Paths.MOVER_SERVICES, page: () => const MoverServicesView()),
    GetPage(
      name: _Paths.MOVER_CONTACT_DETAILS,
      page: () => const MoverContactMovingDetailsView(),
    ),
    GetPage(
      name: _Paths.MOVER_PICKUP_LOCATION,
      page: () => const MoverPickupLocationView(),
    ),
    GetPage(
      name: _Paths.MOVER_DROPOFF_LOCATION,
      page: () => const MoverDropoffLocationView(),
    ),
    GetPage(name: _Paths.MOVER_ESTIMATE, page: () => const MoverEstimateView()),
    GetPage(name: _Paths.MOVER_SCHEDULE, page: () => const MoverScheduleView()),
    GetPage(
      name: _Paths.MOVER_BOOKING_CONFIRMED,
      page: () => const MoverBookingConfirmedView(),
    ),
    GetPage(
      name: _Paths.MOVER_PARCEL_TRACKING,
      page: () => const MoverParcelTrackingView(),
    ),
    GetPage(
      name: _Paths.MOVER_NOTIFICATIONS,
      page: () => const MoverNotificationsView(),
      binding: MoverNotificationsBinding(),
    ),
    GetPage(
      name: _Paths.MOVER_CITY_DETAILS,
      page: () => const MoverCityDetailView(),
    ),
    // mover profile
    GetPage(
      name: _Paths.MOVER_PROFILE,
      page: () => const MoverProfileView(),
      binding: MoverProfileBinding(),
    ),
    GetPage(
      name: _Paths.MOVER_PROFILE_EDIT,
      page: () => const MoverEditProfileView(),
      binding: MoverEditProfileBinding(),
    ),
    // mover settings
    GetPage(
      name: _Paths.MOVER_SETTINGS,
      page: () => const MoverSettingsView(),
      binding: MoverSettingsBinding(),
    ),
    GetPage(
      name: _Paths.MOVER_SETTINGS_CHANGE_PASSWORD,
      page: () => const MoverChangePasswordView(),
      binding: MoverSettingsBinding(),
    ),
    GetPage(
      name: _Paths.MOVER_SETTINGS_PRIVACY,
      page: () => const MoverPrivacyView(),
      binding: MoverSettingsBinding(),
    ),
    GetPage(
      name: _Paths.MOVER_SETTINGS_TERMS,
      page: () => const MoverTermsView(),
      binding: MoverSettingsBinding(),
    ),
    GetPage(
      name: _Paths.MOVER_SETTINGS_HELP,
      page: () => const MoverHelpView(),
      binding: MoverSettingsBinding(),
    ),
    GetPage(
      name: '/mover/settings/help-ack',
      page: () => const MoverHelpAckView(),
      binding: MoverSettingsBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_HOME,
      page: () => const DriverHomeView(),
      binding: DriverHomeBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_EARNINGS,
      page: () => const EarningsView(),
      binding: EarningsBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_PRIORITY,
      page: () => const PriorityView(),
      binding: PriorityBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_SETTINGS_CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_SETTINGS_PRIVACY,
      page: () => const PrivacyView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_SETTINGS_TERMS,
      page: () => const TermsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_SETTINGS_HELP,
      page: () => const HelpView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: '/driver/settings/help-ack',
      page: () => const HelpAckView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_PROFILE_EDIT,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_TASK_DETAIL,
      page: () => const TaskDetailView(),
      binding: TaskBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_TASK_ACTIVE,
      page: () => const TaskActiveView(),
      binding: TaskActiveBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_TASK_LIVE,
      page: () => const TaskLiveView(),
      binding: TaskLiveBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_DELIVERY_DETAIL,
      page: () => const DeliveryDetailView(),
      binding: DeliveryDetailBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_PAYOUT,
      page: () => const PayoutView(),
      binding: PayoutBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_PAYOUT_AMOUNT,
      page: () => const EnterAmountView(),
      binding: PayoutBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_PAYOUT_CONFIRM,
      page: () => const ConfirmPayoutView(),
      binding: PayoutBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_PAYOUT_SUCCESS,
      page: () => const PayoutSuccessView(),
      binding: PayoutBinding(),
    ),
    // driver notifications
    GetPage(
      name: _Paths.DRIVER_NOTIFICATIONS,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_HOME,
      page: () => const HelperHomeView(),
      binding: HelperHomeBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_NOTIFICATIONS,
      page: () => const HelperNotificationView(),
      binding: HelperNotificationBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_DELIVERY_DETAIL,
      page: () => const HelperDeliveryDetailView(),
      binding: HelperDeliveryDetailBinding(),
    ),

    GetPage(
      name: _Paths.HELPER_REGISTRATION,
      page: () => const HelperRegistrationView(),
      binding: HelperRegistrationBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_PROFILE,
      page: () => const HelperProfileView(),
      binding: HelperProfileBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_PROFILE_EDIT,
      page: () => const HelperEditProfileView(),
      binding: HelperProfileBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_PRIORITY,
      page: () => const HelperPriorityView(),
      binding: HelperPriorityBinding(),
    ),
    GetPage(
      name: '/helper/notifications',
      page: () => const HelperNotificationView(),
    ),
    GetPage(
      name: _Paths.HELPER_SETTINGS,
      page: () => const HelperSettingsView(),
      binding: HelperSettingsBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_SETTINGS_CHANGE_PASSWORD,
      page: () => const HelperChangePasswordView(),
      binding: HelperSettingsBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_SETTINGS_PRIVACY,
      page: () => const HelperPrivacyView(),
    ),
    GetPage(
      name: _Paths.HELPER_SETTINGS_TERMS,
      page: () => const HelperTermsView(),
    ),
    GetPage(
      name: _Paths.HELPER_SETTINGS_HELP,
      page: () => const HelperHelpView(),
      binding: HelperSettingsBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_SETTINGS_HELP_ACK,
      page: () => const HelperHelpAckView(),
      binding: HelperSettingsBinding(),
    ),
    // Helper earnings
    GetPage(
      name: _Paths.HELPER_EARNINGS,
      page: () => const HelperEarningsView(),
      binding: HelperEarningsBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_PAYOUT,
      page: () => const HelperPayoutView(),
      binding: HelperPayoutBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_PAYOUT_AMOUNT,
      page: () => const HelperEnterAmountView(),
      binding: HelperPayoutBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_PAYOUT_CONFIRM,
      page: () => const HelperConfirmPayoutView(),
      binding: HelperPayoutBinding(),
    ),
    GetPage(
      name: _Paths.HELPER_PAYOUT_SUCCESS,
      page: () => const HelperPayoutSuccessView(),
      binding: HelperPayoutBinding(),
    ),
    // Helper task pages
    GetPage(
      name: '/helper/task/detail',
      page: () => const HelperTaskDetailView(),
      binding: HelperTaskBinding(),
    ),
    GetPage(
      name: '/helper/task/active',
      page: () => const HelperTaskActiveView(),
      binding: HelperTaskActiveBinding(),
    ),
    GetPage(
      name: '/helper/task/live',
      page: () => const HelperTaskLiveView(),
      binding: HelperTaskLiveBinding(),
    ),
  ];
}
