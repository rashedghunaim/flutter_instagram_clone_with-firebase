abstract class RegisterStates {}

class RegisterInitialState extends RegisterStates {}

class TogglePasswordVisibiltyState extends RegisterStates {}

class RegisterSelectProfileImageState extends RegisterStates {}

class RegisterUplaodProfileImageState extends RegisterStates {}

class RegisterWaitingResponseState extends RegisterStates {}

class RegisterNewUserSuccessState extends RegisterStates {}

class RegisterNewUserErrorState extends RegisterStates {
  final String error;
  RegisterNewUserErrorState(this.error);
}

class RegisterNewUserDocumentSuccessState extends RegisterStates {
  final String? userToken;
  final String? currentUserID;
  RegisterNewUserDocumentSuccessState({
    required this.userToken,
    required this.currentUserID,
  });
}

class RegisterNewUserDocumentErrorState extends RegisterStates {}
