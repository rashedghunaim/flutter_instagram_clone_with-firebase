import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:full_stack_instagram_clone/layout/mobile_home_screen_layout.dart';
import 'package:full_stack_instagram_clone/modules/login_screen.dart';
import 'package:full_stack_instagram_clone/shared/show_toast.dart';
import 'package:full_stack_instagram_clone/state_management/register_bloc/register_cubit.dart';
import 'package:full_stack_instagram_clone/state_management/register_bloc/register_states.dart';
import 'package:full_stack_instagram_clone/util/theme_data.dart';
import '../cash/cash_helper.dart';
import '../shared/primary_InputField.dart';
import '../shared/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  static final String routeName = './SignUp_Screen';
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentModeDark =
        CashHelper.getSavedCashData(key: 'userLatestThemeMode');
    return BlocProvider(
      create: (context) => RegisterCubit(RegisterInitialState()),
      child: BlocConsumer<RegisterCubit, RegisterStates>(
        listener: (BuildContext context, RegisterStates state) async {
          if (state is RegisterNewUserDocumentSuccessState) {
            if (state.userToken != null && state.currentUserID != null) {
              await CashHelper.saveDataInCash(
                key: 'currentUserID',
                value: state.currentUserID,
              );
              final bool isSuccess = await CashHelper.saveDataInCash(
                key: 'userToken',
                value: state.userToken,
              );
              if (isSuccess == true)
                Navigator.of(context).pushReplacementNamed(
                  MobileHomeScreenLayout.routeName,
                );
            }
          } else if (state is RegisterNewUserErrorState) {
            showToast(message: state.error, state: ToastStates.ERROR);
          }
        },
        builder: (BuildContext context, RegisterStates state) {
          final registerCubit = RegisterCubit.getRegisterCubit(context);
          return Scaffold(
            body: Container(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 100),
              width: double.infinity,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Container(), flex: 2),
                    SvgPicture.asset(
                      'lib/assets/images/ic_instagram.svg',
                      color: isCurrentModeDark ? primaryColor : Colors.black,
                      height: 60.0,
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    Stack(
                      children: [
                        registerCubit.selectedImage != null
                            ? CircleAvatar(
                                radius: 75.0,
                                backgroundImage:
                                    MemoryImage(registerCubit.selectedImage!),
                              )
                            : Icon(
                                Icons.account_circle_rounded,
                                size: 170,
                                color: Colors.grey.shade400,
                              ),
                        Positioned(
                          bottom: 10.0,
                          left: 100,
                          child: IconButton(
                            onPressed: registerCubit.registerSelectProfileImage,
                            icon: Icon(
                              Icons.add_circle,
                              color: isCurrentModeDark
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50.0,
                    ),
                    primaryInputField(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      maxLines: 1,
                      context: context,
                      controller: _bioController,
                      hintText: 'Bio',
                      focusBorder:
                          Theme.of(context).inputDecorationTheme.focusedBorder,
                      enabledBorder:
                          Theme.of(context).inputDecorationTheme.enabledBorder,
                      onChanged: (_) {
                        setState(
                          () {},
                        );
                      },
                      keyBoardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    primaryInputField(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      context: context,
                      controller: _userNameController,
                      focusBorder:
                          Theme.of(context).inputDecorationTheme.focusedBorder,
                      enabledBorder:
                          Theme.of(context).inputDecorationTheme.enabledBorder,
                      hintText: 'User name',
                      onChanged: (_) {
                        setState(
                          () {},
                        );
                      },
                      keyBoardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    primaryInputField(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      maxLines: 1,
                      context: context,
                      controller: _emailController,
                      hintText: 'Email address',
                      focusBorder:
                          Theme.of(context).inputDecorationTheme.focusedBorder,
                      enabledBorder:
                          Theme.of(context).inputDecorationTheme.enabledBorder,
                      onChanged: (_) {
                        setState(
                          () {},
                        );
                      },
                      keyBoardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20.0),
                    primaryInputField(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      maxLines: 1,
                      context: context,
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: registerCubit.isPasswordVisible,
                      focusBorder:
                          Theme.of(context).inputDecorationTheme.focusedBorder,
                      enabledBorder:
                          Theme.of(context).inputDecorationTheme.enabledBorder,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            registerCubit.togglePsswordVisibility(),
                        icon: Icon(
                          registerCubit.isPasswordVisible
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
                        registerCubit.registeringNewUser(
                          userName: _userNameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                          bio: _bioController.text,
                          file: registerCubit.selectedImage,
                        );
                      },
                      keyBoardType: TextInputType.visiblePassword,
                    ),
                    const SizedBox(height: 20.0),
                    Conditional.single(
                      context: context,
                      conditionBuilder: (context) => registerCubit.isLoading,
                      widgetBuilder: (context) => Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 0.4,
                        ),
                      ),
                      fallbackBuilder: (context) {
                        return primaryButton(
                          title: 'Sign Up',
                          onTap: _emailController.text.isNotEmpty &&
                                  _passwordController.text.isNotEmpty &&
                                  _bioController.text.isNotEmpty &&
                                  _userNameController.text.isNotEmpty
                              ? () {
                                  registerCubit.registeringNewUser(
                                    userName: _userNameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    bio: _bioController.text,
                                    file: registerCubit.selectedImage,
                                  );
                                }
                              : null,
                          context: context,
                          isTitleUpperCase: false,
                          height: 50.0,
                          backGroundColor: _emailController.text.isNotEmpty &&
                                  _passwordController.text.isNotEmpty &&
                                  _bioController.text.isNotEmpty &&
                                  _userNameController.text.isNotEmpty
                              ? blueColor
                              : isCurrentModeDark
                                  ? blueColor.withOpacity(0.25)
                                  : Colors.blue[300]!,
                          hintStyle: TextStyle(color: Colors.white),
                          titleColor: _emailController.text.isNotEmpty &&
                                  _passwordController.text.isNotEmpty &&
                                  _bioController.text.isNotEmpty &&
                                  _userNameController.text.isNotEmpty
                              ? Colors.white
                              : isCurrentModeDark
                                  ? Colors.white54
                                  : Colors.white70,
                        );
                      },
                    ),
                    const SizedBox(height: 70.0),
                    Divider(
                      thickness: 0.2,
                      color: isCurrentModeDark ? Colors.grey : Colors.black,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account ?',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            InkWell(
                              onTap: () =>
                                  Navigator.of(context).pushReplacement(

                                MaterialPageRoute(
                                  builder: (context) {
                                    return LoginScreen();
                                  },
                                  
                                ),

                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  'Login.',
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
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
