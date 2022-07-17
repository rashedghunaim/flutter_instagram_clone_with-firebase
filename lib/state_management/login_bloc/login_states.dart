abstract class LoginStates {}

class LoginInitialState extends LoginStates {}

class TogglePasswordVisibilityLoginState extends LoginStates {}

class LoginWaitingResponseState extends LoginStates {}

class LoginUserSuccessState extends LoginStates {
  final String? userToken;
  final String? currentUserID;
  LoginUserSuccessState({
    required this.userToken,
    required this.currentUserID,
  });
}

class LoginUserErrorState extends LoginStates {
  final String error;
  LoginUserErrorState(this.error);
}
