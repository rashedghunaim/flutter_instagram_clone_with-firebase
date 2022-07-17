import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_stack_instagram_clone/layout/mobile_home_screen_layout.dart';
import 'package:full_stack_instagram_clone/modules/explore_module/explored_post_details_screen.dart';
import 'package:full_stack_instagram_clone/modules/register_screen.dart';
import 'package:full_stack_instagram_clone/modules/login_screen.dart';
import 'package:full_stack_instagram_clone/state_management/block_observer.dart';
import 'package:full_stack_instagram_clone/state_management/layout_bloc/home_layout_cubit.dart';
import 'package:full_stack_instagram_clone/state_management/layout_bloc/layout_states.dart';
import 'package:full_stack_instagram_clone/state_management/user_bloc/user_cubit.dart';
import 'package:full_stack_instagram_clone/util/Responsive.dart';
import 'package:full_stack_instagram_clone/util/theme_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cash/cash_helper.dart';
import 'layout/web_home_screen_layout.dart';
import 'state_management/user_bloc/user_cubit_states.dart';

void main() {
  BlocOverrides.runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      Widget? _startingWidget;
      if (kIsWeb) {
        // so idea simply is that for the web we must give some meta data for the firstore .
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyAXylU6DKR1WoHmGzj3QkpFv7nCWucY1GM',
            appId: '1:503539566884:web:5903caefb79a13d08ecbb1',
            messagingSenderId: '503539566884',
            projectId: 'instagram-clone-2772f',
            storageBucket: 'instagram-clone-2772f.appspot.com',
          ),
        );
      } else {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.white,
            statusBarColor: Colors.white,
          ),
        );
        await Firebase.initializeApp();
        CashHelper.sharedPref = await SharedPreferences.getInstance();
        await CashHelper.saveDataInCash(
          key: 'userLatestThemeMode',
          value: false,
        );
        final userID = CashHelper.getSavedCashData(key: 'currentUserID');
        final currenttUserToken = CashHelper.getSavedCashData(key: 'userToken');
        if (currenttUserToken != null && userID != null) {
          _startingWidget = ResponsiveLayout(
            mobileScreenLayout: MobileHomeScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          );
        } else {
          _startingWidget = LoginScreen();
        }
      }

      runApp(AppRoot(_startingWidget!));
    },
    blocObserver: MyBlocObserver(),
  );
}

class AppRoot extends StatelessWidget {
  final Widget staringWidget;
  AppRoot(this.staringWidget);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              UserCubit(UserInitialState())..fetchCurrentUserPersonalData(),
        ),
        BlocProvider(
          create: (context) => LayoutCubit(HomeLayoutInitialState()),
        ),
      ],
      child: BlocConsumer<LayoutCubit, LayoutStates>(
        listener: (context, state) {},
        builder: (context, state) {
          bool isCurrentModeDark = CashHelper.getSavedCashData(
            key: 'userLatestThemeMode',
          );
          if (state is SwitchThemeModeState) {
            isCurrentModeDark = state.isDarkMode;
          }
          return MaterialApp(
            title: 'Instagram Clone ',
            debugShowCheckedModeBanner: false,
            theme: isCurrentModeDark ? darkModeTheme : lightTheme,
            home: staringWidget,
            routes: {
              RegisterScreen.routeName: (context) => RegisterScreen(),
              LoginScreen.routeName: (context) => LoginScreen(),
              MobileHomeScreenLayout.routeName: (context) =>
                  MobileHomeScreenLayout(),
              ExploredPostDetailsScreen.routeName: (context) =>
                  ExploredPostDetailsScreen(),
            },
          );
        },
      ),
    );
  }
}
