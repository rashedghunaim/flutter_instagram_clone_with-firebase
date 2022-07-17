import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:full_stack_instagram_clone/layout/mobile_home_screen_layout.dart';
import 'package:full_stack_instagram_clone/modules/register_screen.dart';
import 'package:full_stack_instagram_clone/shared/show_toast.dart';
import 'package:full_stack_instagram_clone/state_management/login_bloc/login_cubit.dart';
import 'package:full_stack_instagram_clone/util/theme_data.dart';
import '../cash/cash_helper.dart';
import '../shared/primary_InputField.dart';
import '../shared/primary_button.dart';
import '../state_management/login_bloc/login_states.dart';

class LoginScreen extends StatefulWidget {
  static final routeName = './Login_Screen';
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentModeDark =
        CashHelper.getSavedCashData(key: 'userLatestThemeMode');
    return BlocProvider(
      create: (context) => LoginCubit(LoginInitialState()),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (context, state) async {
          if (state is LoginUserSuccessState) {
            if (state.userToken != null && state.currentUserID != null) {
              await CashHelper.saveDataInCash(
                key: 'currentUserID',
                value: state.currentUserID,
              );
              final bool isSuccess = await CashHelper.saveDataInCash(
                key: 'userToken',
                value: state.userToken,
              );
              if (isSuccess == true) {
                Navigator.of(context).pushReplacementNamed(
                  MobileHomeScreenLayout.routeName,
                );
              }
            }
          } else if (state is LoginUserErrorState) {
            showToast(message: state.error, state: ToastStates.ERROR);
          }
        },
        builder: (context, state) {
          final loginCubit = LoginCubit.getLoginCubit(context);
          return Scaffold(
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              width: double.infinity,
              child: Column(
                children: [
                  Flexible(child: Container(), flex: 2),
                  SvgPicture.asset(
                    'lib/assets/images/ic_instagram.svg',
                    color: isCurrentModeDark ? primaryColor : Colors.black,
                    height: 60.0,
                  ),
                  const SizedBox(
                    height: 65.0,
                  ),
                  primaryInputField(
                    context: context,
                    controller: _emailController,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    hintText: 'Email address',
                    keyBoardType: TextInputType.emailAddress,
                    focusBorder:
                        Theme.of(context).inputDecorationTheme.focusedBorder,
                    enabledBorder:
                        Theme.of(context).inputDecorationTheme.enabledBorder,
                    onChanged: (_) {
                      setState(
                        () {},
                      );
                    },
                    maxLines: 1,
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    child: primaryInputField(
                      context: context,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      maxLines: 1,
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: loginCubit.isPasswordShown,
                      focusBorder:
                          Theme.of(context).inputDecorationTheme.focusedBorder,
                      enabledBorder:
                          Theme.of(context).inputDecorationTheme.enabledBorder,
                      suffixIcon: IconButton(
                        onPressed: () {
                          loginCubit.togglePsswordVisibility();
                        },
                        icon: Icon(
                          loginCubit.isPasswordShown
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      onChanged: (_) {
                        setState(
                          () {},
                        );
                      },
                      onFieldSubmitted: (_) {
                        loginCubit.loginUser(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Conditional.single(
                    context: context,
                    conditionBuilder: (context) => loginCubit.isWaiting,
                    widgetBuilder: (context) => Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 0.4,
                      ),
                    ),
                    fallbackBuilder: (context) {
                      return primaryButton(
                        title: 'Log In',
                        onTap: _emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty
                            ? () {
                                loginCubit.loginUser(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                              }
                            : null,
                        context: context,
                        isTitleUpperCase: false,
                        height: 50.0,
                        backGroundColor: _emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty
                            ? blueColor
                            : isCurrentModeDark
                                ? blueColor.withOpacity(0.25)
                                : Colors.blue[300]!,
                        hintStyle: TextStyle(color: Colors.white),
                        titleColor: _emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty
                            ? Colors.white
                            : isCurrentModeDark
                                ? Colors.white54
                                : Colors.white70,
                      );
                    },
                  ),
                  Flexible(child: Container(), flex: 2),
                  Divider(
                    thickness: 0.2,
                    color: isCurrentModeDark ? Colors.grey : Colors.black,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account ?',
                          style:
                              Theme.of(context).textTheme.subtitle2!.copyWith(
                                    fontWeight: FontWeight.normal,
                                  ),
                        ),
                        InkWell(
                          onTap: () {


                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) {
                                  return RegisterScreen();
                                },
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              'Sign Up .',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
