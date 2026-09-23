import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/notifications/firebase_notification_service.dart';
import 'services/websocket/websocket_bootstrap_service.dart';

import 'app/routes/app_pages.dart';
import 'shared/app_theme.dart';

_SocketLifecycleKeeper? _socketLifecycleKeeper;

class _SocketLifecycleKeeper with WidgetsBindingObserver {
  _SocketLifecycleKeeper(this._bootstrapService);

  final WebSocketBootstrapService _bootstrapService;

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    await _bootstrapService.connectForAuthenticatedUser();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bootstrapService.connectForAuthenticatedUser();
    }
  }
}

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('❌ Unhandled async error: $error');
        return true;
      };

      await GetStorage.init();

      print('🚀 App starting...');

      // Initialize Firebase
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('✅ Firebase initialized successfully');
      } catch (e) {
        if (e.toString().contains('duplicate-app')) {
          print('✅ Firebase already initialized by native plugin');
        } else {
          print('❌ Firebase initialization error: $e');
        }
      }

      // Register background message handler (must be top-level before runApp)
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Initialize FCM and native local notifications service
      final fcmService = Get.isRegistered<FirebaseNotificationService>()
          ? Get.find<FirebaseNotificationService>()
          : Get.put(FirebaseNotificationService(), permanent: true);
      await fcmService.initialize();

      final wsBootstrap = Get.isRegistered<WebSocketBootstrapService>()
          ? Get.find<WebSocketBootstrapService>()
          : Get.put(WebSocketBootstrapService(), permanent: true);

      _socketLifecycleKeeper = _SocketLifecycleKeeper(wsBootstrap);
      print('🔌 Initializing WebSocket bootstrap...');
      await _socketLifecycleKeeper!.init();
      print('🔌 WebSocket bootstrap initialized');

      runApp(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) {
            return GetMaterialApp(
              title: "Application",
              theme: appTheme(),
              initialRoute: AppPages.INITIAL,
              getPages: AppPages.routes,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      );
    },
    (error, stack) {
      debugPrint('❌ Zone error caught: $error');
    },
  );
}
