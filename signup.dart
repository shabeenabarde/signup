import 'dart:convert';

import 'package:digi_protect/components/custom_text_form_field.dart';
import 'package:digi_protect/models/arguments/args.dart';
import 'package:digi_protect/models/responses/signup_response.dart';
import 'package:digi_protect/models/user.dart';
import 'package:digi_protect/network/endpoints.dart';
import 'package:digi_protect/utils/constants.dart';
import 'package:digi_protect/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart' as validator;
import '../utils/colors.dart';
import '../utils/routes.dart';

enum ScreenState { INPUT, LOADING, RESPONSE }

enum ResponseStatus { SUCCESS, FAILED }

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  var firstNameController = new TextEditingController();

  final _lastNameFN = FocusNode();
  final _phoneNoFN = FocusNode();
  final _emailFN = FocusNode();
  final _passwordFN = FocusNode();
  final _confirmPassFN = FocusNode();
  final _cityFN = FocusNode();
  final _areaFN = FocusNode();
  final _streetFN = FocusNode();
  final _buildingNameFN = FocusNode();
  final _floorFN = FocusNode();

  final _formKey = GlobalKey<FormState>();
  String passwordOne, passwordTwo;
  String phoneNumber = "";
  bool passwordsMatch;
  bool phoneValid = false;

  User user = User();
  String userPhoneNumber = "";
  String userId = "";

  String errorMessage = "";

  var screenState = ScreenState.INPUT;
  var responseStatus;

  String phoneNumberErrorMessage = "Phone number not valid";
  var phoneNumberController = TextEditingController();
  IconData statusIcon = Icons.info;
  var statusColor = Colors.white;

  IconData passwordStatusIcon = Icons.info;
  var passwordStatusColor = Colors.white;

  var firstPasswordController = TextEditingController();
  var secondPasswordController = TextEditingController();

  @override
  void initState() {
    user.prepareDeviceInformation();
    phoneNumberController.addListener(_checkIfPhoneNumberIsValid);
    secondPasswordController.addListener(_checkIfPasswordMatch);
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
  }

  _checkIfPasswordMatch() {
    String secondPassword = secondPasswordController.text;
    String firstPassword = firstPasswordController.text;
    if (secondPassword == firstPassword) {
      setState(() {
        passwordStatusColor = Colors.green;
        passwordStatusIcon = Icons.check_circle;
      });
    } else {
      setState(() {
        passwordStatusColor = Colors.red;
        passwordStatusIcon = Icons.info;
      });
    }
  }

  _checkIfPhoneNumberIsValid() {
    String number = phoneNumberController.text;

    if (number.length == 9) {
      setState(() {
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        phoneNumberErrorMessage = "";
      });
    } else {
      setState(() {
        statusColor = Colors.red;
        statusIcon = Icons.info;
        phoneNumberErrorMessage = "Phone number not valid";
      });
    }
    print(" Entered number " + phoneNumberController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        // backgroundColor: Colors.green[100],
      ),
      body: SingleChildScrollView(
        child: getContent(),
      ),
    );
  }

  Widget getContent() {
    switch (screenState) {
      case ScreenState.INPUT:
        return getSignUpForm();
        break;
      case ScreenState.LOADING:
        return getLoadingScreen();
        break;
      case ScreenState.RESPONSE:
        return getResponceScreen();
        break;
    }
  }

  Widget getLoadingScreen() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "Signing you up...",
                style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child:
                  CircularProgressIndicator(backgroundColor: Colors.grey[600]),
            )
          ],
        ),
      ),
    );
  }

  Widget getResponceScreen() {
    switch (responseStatus) {
      case ResponseStatus.SUCCESS:
        return sendToOtpScreen();
        break;
      case ResponseStatus.FAILED:
        return getFailedResposeWidget();
        break;
    }
  }

  Widget sendToOtpScreen() {
    return Center(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
        child: Card(
          margin: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.only(bottom: 16, top: 16),
                child: Text(
                  "Congratulations\nUser has been signed up successfully!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors().mainColor,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                width: double.infinity,
                color: AppColors().mainColor,
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(top: 16),
                child: FlatButton(
                    onPressed: () {
                      var arguments = OtpArgs();
                      arguments.phoneNumber = userPhoneNumber;
                      arguments.otpArgsMbusId = userId;
                      Navigator.pushReplacementNamed(
                        context,
                        Routes.OTP,
                        arguments: arguments,
                      );
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getFailedResposeWidget() {
    return Center(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
        child: Card(
          margin: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.only(bottom: 16, top: 16),
                child: Text(
                  "Failed to Signup please try again : ${errorMessage}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                width: double.infinity,
                color: AppColors().mainColor,
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(top: 16),
                child: FlatButton(
                    onPressed: () {
                      setState(() {
                        phoneNumberController = TextEditingController();
                        screenState = ScreenState.INPUT;
                      });
                    },
                    child: Text(
                      "TRY AGAIN",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Container(
      height: 40,
      margin: EdgeInsets.only(left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: AppColors().mainColor,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            title,
            style: TextStyle(
                color: AppColors().mainColor,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(
            width: 8,
          ),
          Flexible(
            fit: FlexFit.loose,
            flex: 1,
            child: Container(
              height: 1,
              color: AppColors().mainColor,
              margin: EdgeInsets.only(right: 16),
            ),
          )
        ],
      ),
    );
  }

  Widget getSignUpForm() {
    final halfMediaWidth = MediaQuery.of(context).size.width / 2.0;
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          sectionTitle("Personal Details", Icons.person),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              width: halfMediaWidth,
              /*--------------------------FIRST NAME------------------------- */
              child: CustomTextFormField(
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_lastNameFN);
                },
                controller: firstNameController,
                hintText: 'First Name',
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Enter your first name';
                  }
                  return null;
                },
                onSaved: (String value) {
                  user.firstName = value;
                },
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              width: halfMediaWidth,
              /*--------------------------LAST NAME------------------------- */

              child: CustomTextFormField(
                focusNode: _lastNameFN,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_phoneNoFN);
                },
                textInputAction: TextInputAction.next,
                hintText: 'Last Name',
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Enter your Last name';
                  }
                  return null;
                },
                onSaved: (String value) {
                  user.lastName = value;
                },
              ),
            )
          ]),
          Container(
            height: 70.0,
            padding: EdgeInsets.only(left: 16, right: 16, top: 8),
            margin: EdgeInsets.only(left: 8, right: 8),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300], width: 1)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: InternationalPhoneNumberInput.withCustomDecoration(
                    focusNode: _phoneNoFN,
                    // onFieldSubmitted: (_) =>
                    //     FocusScope.of(context).requestFocus(_emailFN),
                    keyboardAction: TextInputAction.next,
                    onInputChanged: (PhoneNumber number) {
                      phoneNumber = number.phoneNumber;
                    },
                    onInputValidated: (bool value) {
                      phoneValid = value;
                    },
                    initialCountry2LetterCode: "TZ",
                    countries: ["TZ", "KE", "UG"],
                    inputDecoration: InputDecoration(
                        border: InputBorder.none, hintText: "Phone Number"),
                    isEnabled: true,
                    autoValidate: false,
                    formatInput: false,
                    textFieldController: phoneNumberController,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: 40,
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                  ),
                )
              ],
            ),
          ),
          CustomTextFormField(
            textInputAction: TextInputAction.next,
            focusNode: _emailFN,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFN);
            },
            hintText: 'Email',
            isEmail: true,
            validator: (String value) {
              if (!validator.isEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onSaved: (String value) {
              user.email = value;
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 32),
            child: sectionTitle("Password", Icons.security),
          ),
          CustomTextFormField(
            textInputAction: TextInputAction.next,
            focusNode: _passwordFN,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_confirmPassFN);
            },
            hintText: 'Password',
            isPassword: true,
            controller: firstPasswordController,
            validator: (String value) {
              if (value.length < 7) {
                return 'Password should be minimum 7 characters';
              }
              return null;
            },
            onSaved: (String value) {
              //Set the first Password
              passwordOne = value;
            },
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[700], width: 0.2)),
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: Container(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      focusNode: _confirmPassFN,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_cityFN);
                      },
                      decoration: InputDecoration(
                          hintText: "Confirm password",
                          contentPadding: EdgeInsets.all(15.0),
                          border: InputBorder.none),
                      obscureText: true,
                      validator: (String value) {
                        if (value.length < 7) {
                          return 'Password should be minimum 7 characters';
                        } else if (passwordOne != null &&
                            value != passwordOne) {
                          setState(() {});
                          return 'Password not matched';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        passwordTwo = value;
                      },
                      controller: secondPasswordController,
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: 40,
                  child: Icon(
                    passwordStatusIcon,
                    color: passwordStatusColor,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 32),
            child: sectionTitle("Address", Icons.location_city),
          ),
          CustomTextFormField(
            textInputAction: TextInputAction.next,
            focusNode: _cityFN,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_areaFN);
            },
            hintText: 'City',
            validator: (String value) {
              if (value.isEmpty) {
                return 'Enter City Name';
              }
              return null;
            },
            onSaved: (String value) {
              user.city = value;
            },
          ),
          CustomTextFormField(
            textInputAction: TextInputAction.next,
            focusNode: _areaFN,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_streetFN);
            },
            hintText: 'Area',
            validator: (String value) {
              if (value.isEmpty) {
                return 'Enter your Area Name';
              }
              return null;
            },
            onSaved: (String value) {
              user.area = value;
            },
          ),
          CustomTextFormField(
            textInputAction: TextInputAction.next,
            focusNode: _streetFN,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_buildingNameFN);
            },
            hintText: 'Street',
            validator: (String value) {
              if (value.isEmpty) {
                return 'Enter your Street Name';
              }
              return null;
            },
            onSaved: (String value) {
              user.street = value;
            },
          ),
          CustomTextFormField(
            textInputAction: TextInputAction.next,
            focusNode: _buildingNameFN,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_floorFN);
            },
            hintText: 'Building Name',
            validator: (String value) {
              if (value.isEmpty) {
                return 'Enter Building Name';
              }
              return null;
            },
            onSaved: (String value) {
              user.building = value;
            },
          ),
          CustomTextFormField(
            textInputAction: TextInputAction.done,
            focusNode: _floorFN,
            hintText: 'Floor/Unit',
            validator: (String value) {
              if (value.isEmpty) {
                return 'Enter Floor/Unit';
              }
              return null;
            },
            onSaved: (String value) {
              user.floor = value;
            },
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.yellow)),
            margin: const EdgeInsets.all(15.0),
            child: FlatButton(
              child: Text(
                'SIGN UP',
                style: TextStyle(
                  fontSize: 16.0,
                  //fontFamily: 'Roboto', fontWeight: FontWeight.w800
                ),
              ),
              onPressed: () {
                // loginClickEvent();
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  if (passwordOne != passwordTwo) {
                    setState(() {
                      passwordsMatch = false;
                    });
                    return;
                  } else {
                    print(passwordOne);
                    user.watchWord = Util.toBase64(passwordOne);
                    signupUser();
                  }
                }
              },
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
              color: Color.fromRGBO(226, 236, 28, 1),
            ),
          ),
        ],
      ),
    );
  }

  void signupUser() async {
    user.phoneNumber = phoneNumber;

    setState(() {
      screenState = ScreenState.LOADING;
    });

    await Endpoints().sendRequest(User().userToJson(user)).then((value) {
      var l = jsonDecode(value) as List;
      List resps = l.map((e) => e).toList();
      String responseCode = resps[0]["respcode"].toString();
      print("response : $value");
      if (responseCode == "0000") {
        SignupResponses responses = SignupResponses.fromJson(value.toString());
        if (responses.response.length > 0) {
          SignUpResponse response = responses.response[0];
          if (response.respcode == Constants().STATUS_SUCCESS) {
            print(value.toString());

            userPhoneNumber = user.phoneNumber;
            userId = response.identity;

            SharedPreferences.getInstance().then((preference){

              preference.setString(Constants.USER_NAME, user.getUserNames());
              preference.setString(Constants.USER_EMAIL, user.email);
              preference.setString(Constants.USER_ID, response.identity);


              setState(() {
                responseStatus = ResponseStatus.SUCCESS;
                screenState = ScreenState.RESPONSE;
              });

            });
          } else {
            print(value.toString());
            setState(() {
              responseStatus = ResponseStatus.FAILED;
              screenState = ScreenState.RESPONSE;
            });
          }
        }
      }
    }, onError: (error) {
      print(error.toString());
      setState(() {
        screenState = ScreenState.INPUT;
      });
    });
  }
}
