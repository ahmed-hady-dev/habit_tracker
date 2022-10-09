import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/core/hive_helper/hive_helper.dart';
import 'view/home/home_view.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_cubit.dart';

import 'core/blocObserver/bloc_observer.dart';
import 'core/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //===============================================================
  await EasyLocalization.ensureInitialized();
  //===============================================================
  await HiveHelper.init();
  await HiveHelper.getTheme ?? await HiveHelper.cacheTheme(value: false);
  bool? isDark = await HiveHelper.getTheme;
  //===============================================================
  BlocOverrides.runZoned(
    () {
      runApp(EasyLocalization(
        path: 'assets/translation',
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'EG')],
        fallbackLocale: const Locale('en', 'US'),
        child: MyApp(isDark: isDark!),
      ));
    },
    blocObserver: MyBlocObserver(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, this.isDark}) : super(key: key);
  final bool? isDark;
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeCubit()..changeTheme(themeModeFromCache: isDark)),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            bool themeCubit = ThemeCubit.get(context).isDark;
            return MaterialApp(
              title: 'Habit Tracker',
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              onGenerateRoute: onGenerateRoute,
              themeMode: themeCubit ? ThemeMode.dark : ThemeMode.light,
              theme: lightTheme(context),
              darkTheme: darkTheme(context),
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: const HomeView(),
            );
          },
        ));
  }
}
