import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:myshetra/Pages/SplashScreen.dart';
import 'package:myshetra/Providers/AuthProvider.dart';
import 'package:myshetra/Services/LanguaugeService.dart';
import 'package:myshetra/bloc/login/login_bloc.dart';
import 'package:myshetra/bloc/signup/signup_bloc.dart';
import 'package:myshetra/dependency_injection.dart';
import 'package:myshetra/helpers/languages.dart';
import 'package:newrelic_mobile/config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'Services/Authservices.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';

void main() async {
  var appToken = "";

  if (Platform.isAndroid) {
    appToken = "AA6978bdfccb7ab30f4845cbb531e14f07d5ffbf72-NRMA";
  } else if (Platform.isIOS) {
    appToken = "AA84ba73ab7269103b981fdee1ad273c0f81a3a637-NRMA";
  }

  Config config = Config(
    accessToken: appToken,

    //Android Specific
    // Optional:Enable or disable collection of event data.
    analyticsEventEnabled: true,

    // Optional:Enable or disable reporting network and HTTP request errors to the MobileRequestError event type.
    networkErrorRequestEnabled: true,

    // Optional:Enable or disable reporting successful HTTP requests to the MobileRequest event type.
    networkRequestEnabled: true,

    // Optional:Enable or disable crash reporting.
    crashReportingEnabled: true,

    // Optional:Enable or disable interaction tracing. Trace instrumentation still occurs, but no traces are harvested. This will disable default and custom interactions.
    interactionTracingEnabled: true,

    // Optional:Enable or disable capture of HTTP response bodies for HTTP error traces, and MobileRequestError events.
    httpResponseBodyCaptureEnabled: true,

    // Optional: Enable or disable agent logging.
    loggingEnabled: true,

    //iOS Specific
    // Optional:Enable/Disable automatic instrumentation of WebViews
    webViewInstrumentation: true,

    //Optional: Enable or Disable Print Statements as Analytics Events
    printStatementAsEventsEnabled: true,

    // Optional:Enable/Disable automatic instrumentation of Http Request
    httpInstrumentationEnabled: true,

    // Optional : Enable or disable reporting data using different endpoints for US government clients
    fedRampEnabled: false,

    // Optional: Enable or disable offline data storage when no internet connection is available.
    offlineStorageEnabled: true,

    // iOS Specific
    // Optional: Enable or disable background reporting functionality.
    backgroundReportingEnabled: true,

    // iOS Specific
    // Optional: Enable or disable to use our new, more stable, event system for iOS agent.
    newEventSystemEnabled: true,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getTemporaryDirectory(),
  );
  NewrelicMobile.instance.start(config, () {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          BlocProvider(create: (_) => LoginBloc()),
          BlocProvider(create: (_) => SignupBloc()),
        ],
        child: MyApp(),
      ),
    );
    DependencyInjection.init();
  });
}

Future<void> initServices() async {
  Get.put(AuthService());
  Get.put(LocaleController());
  await Get.find<AuthService>().loadTokensFromStorage();
  await Get.find<LocaleController>().getLocaleFromStorage();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      locale: Locale(Get.find<LocaleController>().locale.value,
          Get.find<LocaleController>().countryCode.value),
      fallbackLocale: Locale('en', 'US'),
      translations: Language(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFF5252)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
