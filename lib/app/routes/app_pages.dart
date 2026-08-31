// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/complink/bindings/complink_binding.dart';
import '../modules/complink/views/complink_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/faq/bindings/faq_binding.dart';
import '../modules/faq/views/faq_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/kuesioner/bindings/kuesioner_binding.dart';
import '../modules/kuesioner/views/kuesioner_view.dart';
import '../modules/landing/views/landing_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/not_found/views/not_found_view.dart';
import '../modules/paperlink/bindings/paperlink_binding.dart';
import '../modules/paperlink/views/paperlink_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/sourcelink/bindings/sourcelink_binding.dart';
import '../modules/sourcelink/views/sourcelink_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/admin_dashboard/bindings/admin_dashboard_binding.dart';
import '../modules/admin_dashboard/views/admin_dashboard_view.dart';
import '../modules/order/bindings/order_binding.dart';
import '../modules/order/views/order_history_view.dart';
import '../modules/admin_kuesioner/bindings/admin_kuesioner_binding.dart';
import '../modules/admin_kuesioner/views/admin_kuesioner_view.dart';
import '../modules/admin_orders/bindings/admin_orders_binding.dart';
import '../modules/admin_orders/views/admin_orders_view.dart';
import '../modules/admin_withdraw/bindings/admin_withdraw_binding.dart';
import '../modules/admin_withdraw/views/admin_withdraw_view.dart';
import '../modules/users/bindings/users_binding.dart';
import '../modules/users/views/mentor_detail_view.dart';
import '../modules/users/views/user_detail_view.dart';
import '../modules/profile/views/change_password_view.dart';
import '../modules/profile/views/edit_profile_view.dart';
import 'route_access_middleware.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LANDING;

  static final unknownRoute = GetPage(
    name: _Paths.NOT_FOUND,
    page: () => const NotFoundView(),
  );

  static final routes = [
    GetPage(name: _Paths.LANDING, page: () => const LandingView()),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      middlewares: [GuestOnlyMiddleware()],
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
      middlewares: [GuestOnlyMiddleware()],
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthenticatedMiddleware()],
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [
        AuthenticatedMiddleware(allowedRoles: {'customer', 'mentor'}),
      ],
    ),
    GetPage(
      name: _Paths.ADMIN_DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
      middlewares: [
        AuthenticatedMiddleware(allowedRoles: {'admin'}),
      ],
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
      middlewares: [AuthenticatedMiddleware()],
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthenticatedMiddleware()],
    ),
    GetPage(
      name: _Paths.KUESIONER,
      page: () => const KuesionerView(),
      binding: KuesionerBinding(),
      middlewares: [AuthenticatedMiddleware()],
    ),
    GetPage(
      name: _Paths.FAQ,
      page: () => const FaqView(),
      binding: FaqBinding(),
      middlewares: [AuthenticatedMiddleware()],
    ),
    GetPage(
      name: _Paths.PAPERLINK,
      page: () => const PaperlinkView(),
      binding: PaperlinkBinding(),
      middlewares: [AuthenticatedMiddleware()],
    ),
    GetPage(
      name: _Paths.COMPLINK,
      page: () => const ComplinkView(),
      binding: ComplinkBinding(),
      middlewares: [AuthenticatedMiddleware()],
    ),
    GetPage(
      name: _Paths.SOURCELINK,
      page: () => const SourcelinkView(),
      binding: SourcelinkBinding(),
      middlewares: [AuthenticatedMiddleware()],
    ),
    GetPage(
      name: _Paths.ORDER_HISTORY,
      page: () => const OrderHistoryView(),
      binding: OrderBinding(),
      middlewares: [AuthenticatedMiddleware()],
    ),
    GetPage(
      name: _Paths.ADMIN_KUESIONER,
      page: () => const AdminKuesionerView(),
      binding: AdminKuesionerBinding(),
      middlewares: [
        AuthenticatedMiddleware(allowedRoles: {'admin'}),
      ],
    ),
    GetPage(
      name: _Paths.ADMIN_ORDERS,
      page: () => const AdminOrdersView(),
      binding: AdminOrdersBinding(),
      middlewares: [
        AuthenticatedMiddleware(allowedRoles: {'admin'}),
      ],
    ),
    GetPage(
      name: _Paths.ADMIN_WITHDRAW,
      page: () => const AdminWithdrawView(),
      binding: AdminWithdrawBinding(),
      middlewares: [
        AuthenticatedMiddleware(allowedRoles: {'admin'}),
      ],
    ),
    GetPage(
      name: _Paths.ADMIN_USER_DETAIL,
      page: () => UserDetailView(userId: Get.parameters['userId'] ?? ''),
      binding: UsersBinding(),
      middlewares: [
        AuthenticatedMiddleware(allowedRoles: {'admin'}),
      ],
    ),
    GetPage(
      name: _Paths.ADMIN_MENTOR_DETAIL,
      page: () => MentorDetailView(mentorId: Get.parameters['mentorId'] ?? ''),
      binding: UsersBinding(),
      middlewares: [
        AuthenticatedMiddleware(allowedRoles: {'admin'}),
      ],
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthenticatedMiddleware()],
    ),
    GetPage(
      name: _Paths.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: ProfileBinding(),
      middlewares: [AuthenticatedMiddleware()],
    ),
  ];
}
