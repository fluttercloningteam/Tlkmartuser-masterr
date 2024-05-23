// import 'dart:async';
// import 'dart:convert';
//
// import 'package:tlkmartuser/Helper/Color.dart';
// import 'package:tlkmartuser/Helper/Constant.dart';
// import 'package:tlkmartuser/Helper/cropped_container.dart';
// import 'package:tlkmartuser/Provider/SettingProvider.dart';
// import 'package:tlkmartuser/Screen/Details.dart';
// import 'package:tlkmartuser/Screen/Set_Password.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart';
// import 'package:provider/provider.dart';
// import 'package:sms_autofill/sms_autofill.dart';
//
// import '../Helper/AppBtn.dart';
// import '../Helper/Session.dart';
// import '../Helper/String.dart';
// import 'SignUp.dart';

// class VerifyOtp extends StatefulWidget {
//   final String? mobileNumber, countryCode, title;
// final otp;
//   VerifyOtp(
//       {Key? key,
//       required String this.mobileNumber,
//       this.countryCode,
//       this.title, this.otp})
//       : assert(mobileNumber != null),
//         super(key: key);
//
//   @override
//   _MobileOTPState createState() => _MobileOTPState();
// }

// class _MobileOTPState extends State<VerifyOtp> with TickerProviderStateMixin {
//   final dataKey = GlobalKey();
//   String? password;
//   String? otp;
//   bool isCodeSent = false;
//   late String _verificationId;
//   String signature = "";
//   bool _isClickable = false;
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   Animation? buttonSqueezeanimation;
//   AnimationController? buttonController;
//
//   @override
//   void initState() {
//     super.initState();
//     getUserDetails();
//     getSingature();
//     _onVerifyCode();
//     Future.delayed(Duration(seconds: 60)).then((_) {
//       _isClickable = true;
//     });
//     buttonController = AnimationController(
//         duration: Duration(milliseconds: 2000), vsync: this);
//
//     buttonSqueezeanimation = Tween(
//       begin: deviceWidth! * 0.7,
//       end: 50.0,
//     ).animate(CurvedAnimation(
//       parent: buttonController!,
//       curve: Interval(
//         0.0,
//         0.150,
//       ),
//     ));
//   }
//
//   Future<void> getVerifyUser() async {
//     try {
//       var data = {MOBILE: widget.mobileNumber, "forgot_otp": "false"};
//       Response response =
//       await post(getVerifyUserApi, body: data, headers: headers)
//           .timeout(Duration(seconds: timeOut));
//       print(getVerifyUserApi.toString());
//       print(data.toString());
//
//       var getdata = json.decode(response.body);
//       bool? error = getdata["error"];
//       String? msg = getdata["message"];
//       await buttonController!.reverse();
//
//       SettingProvider settingsProvider =
//       Provider.of<SettingProvider>(context, listen: false);
//
//       if(widget.checkForgot == "false"){
//         if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
//           if (!error!) {
//             String otp = getdata["data"];
//             setSnackbar(otp.toString());
//             Fluttertoast.showToast(msg: otp.toString(),
//                 backgroundColor: colors.primary
//             );
//             setSnackbar(msg!);
//             settingsProvider.setPrefrence(MOBILE, mobile!);
//             settingsProvider.setPrefrence(COUNTRY_CODE, countrycode!);
//
//             Future.delayed(Duration(seconds: 1)).then((_) {
//               Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => VerifyOtp(
//                         otp: otp,
//                         mobileNumber: widget.mobileNumber!,
//                         countryCode: widget.countryCode,
//                         title: getTranslated(context, 'SEND_OTP_TITLE'),
//                       )));
//             });
//           } else {
//             setSnackbar(msg!);
//           }
//         }
//        else {
//         if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')) {
//           if (!error!) {
//             String otp = getdata["data"];
//             Fluttertoast.showToast(msg: otp.toString(),
//                 backgroundColor: colors.primary
//             );
//             setSnackbar(otp.toString());
//             settingsProvider.setPrefrence(MOBILE, mobile!);
//             settingsProvider.setPrefrence(COUNTRY_CODE, countrycode!);
//             Future.delayed(Duration(seconds: 1)).then((_) {
//               Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => VerifyOtp(
//                         otp: otp,
//                         mobileNumber: widget.mobileNumber!,
//                         countryCode: widget.countryCode,
//                         title: getTranslated(context, 'FORGOT_PASS_TITLE'),
//                       )));
//             });
//           } else {
//             setSnackbar(getTranslated(context, 'FIRSTSIGNUP_MSG')!);
//           }
//         }
//       }
//     } on TimeoutException catch (_) {
//       setSnackbar(getTranslated(context, 'somethingMSg')!);
//       await buttonController!.reverse();
//     }
//   }
//
//   Future<void> getSingature() async {
//     signature = await SmsAutoFill().getAppSignature;
//     await SmsAutoFill().listenForCode;
//   }
//
//   getUserDetails() async {
//     SettingProvider settingsProvider =
//         Provider.of<SettingProvider>(context, listen: false);
//
//     if (mounted) setState(() {});
//   }
//   Future<void> checkNetworkOtp() async {
//     bool avail = await isNetworkAvailable();
//     if (avail) {
//       if (_isClickable) {
//         // _onVerifyCode();
//         getVerifyUser();
//          // otpCheck();
//       } else {
//         setSnackbar(getTranslated(context, 'OTPWR')!);
//       }
//     } else {
//       if (mounted) setState(() {});
//
//       Future.delayed(Duration(seconds: 60)).then((_) async {
//         bool avail = await isNetworkAvailable();
//         if (avail) {
//           if (_isClickable)
//             _onVerifyCode();
//              otpCheck();
//             getVerifyUser();
//           else {
//             setSnackbar(getTranslated(context, 'OTPWR')!);
//           }
//         } else {
//           await buttonController!.reverse();
//           setSnackbar(getTranslated(context, 'somethingMSg')!);
//         }
//       });
//     }
//   }
//
//   Widget verifyBtn() {
//     return AppBtn(
//         title: getTranslated(context, 'VERIFY_AND_PROCEED'),
//         btnAnim: buttonSqueezeanimation,
//         btnCntrl: buttonController,
//         onBtnSelected: () async {
//           _onFormSubmitted();
//           otpCheck();
//           // Details();
//         });
//   }
//
//   setSnackbar(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(
//         msg,
//         textAlign: TextAlign.center,
//         style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
//       ),
//       backgroundColor: Theme.of(context).colorScheme.lightWhite,
//       elevation: 1.0,
//     ));
//   }
//
//   otpCheck ()async {
//     if (widget.otp.toString() == otp.toString()) {
//       SettingProvider settingsProvider =
//       Provider.of<SettingProvider>(context, listen: false);
//
//       // setSnackbar(getTranslated(context, 'OTPMSG')!);
//       Fluttertoast.showToast(msg: getTranslated(context, 'OTPMSG')!,
//           backgroundColor: colors.primary
//       );
//       settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
//       settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!);
//       if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
//         Future.delayed(Duration(seconds: 2)).then((_) {
//           Navigator.pushReplacement(
//               context, MaterialPageRoute(builder: (context) => Details()));
//         // });
//         // Navigator.push(context, MaterialPageRoute(builder: (context) => Details()));
//         // Future.delayed(Duration(seconds: 2)).then((_) {
//         //   Navigator.pushReplacement(
//         //       context, MaterialPageRoute(builder: (context) => SignUp()));
//         });
//       } else if (widget.title ==
//           getTranslated(context, 'FORGOT_PASS_TITLE')) {
//         Future.delayed(Duration(seconds: 2)).then((_) {
//           Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (context) =>
//                       SetPass(mobileNumber: widget.mobileNumber!)));
//         });
//       }
//     }else{
//
//     }
//   }
//
//   void _onVerifyCode() async {
//     if (mounted)
//       setState(() {
//         isCodeSent = true;
//       });
//     final PhoneVerificationCompleted verificationCompleted =
//         (AuthCredential phoneAuthCredential) {
//       _firebaseAuth
//           .signInWithCredential(phoneAuthCredential)
//           .then((UserCredential value) {
//         if (value.user != null) {
//           SettingProvider settingsProvider =
//               Provider.of<SettingProvider>(context, listen: false);
//
//           setSnackbar(getTranslated(context, 'OTPMSG')!);
//           settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
//           settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!);
//           if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
//             Future.delayed(Duration(seconds: 2)).then((_) {
//               Navigator.pushReplacement(
//                   context, MaterialPageRoute(builder: (context) => SignUp()));
//             });
//           } else if (widget.title ==
//               getTranslated(context, 'FORGOT_PASS_TITLE')) {
//             Future.delayed(Duration(seconds: 2)).then((_) {
//               Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           SetPass(mobileNumber: widget.mobileNumber!)));
//             });
//           }
//         } else {
//           setSnackbar(getTranslated(context, 'OTPERROR')!);
//         }
//       }).catchError((error) {
//         setSnackbar("OTP is not correct");
//         setSnackbar(error.toString());
//       });
//     };
//     final PhoneVerificationFailed verificationFailed =
//         (FirebaseAuthException authException) {
//       setSnackbar("OTP is not correct");
//
//       if (mounted)
//         setState(() {
//           isCodeSent = false;
//         });
//     };
//
//     final PhoneCodeSent codeSent =
//         (String verificationId, [int? forceResendingToken]) async {
//       _verificationId = verificationId;
//       if (mounted)
//         setState(() {
//           _verificationId = verificationId;
//         });
//     };
//     final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
//         (String verificationId) {
//       _verificationId = verificationId;
//       if (mounted)
//         setState(() {
//           _isClickable = true;
//           _verificationId = verificationId;
//         });
//     };
//
//     await _firebaseAuth.verifyPhoneNumber(
//         phoneNumber: "+${widget.countryCode}${widget.mobileNumber}",
//         timeout: const Duration(seconds: 60),
//         verificationCompleted: verificationCompleted,
//         verificationFailed: verificationFailed,
//         codeSent: codeSent,
//         codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
//   }
//
//   void _onFormSubmitted() async {
//     String code = otp!.trim();
//
//     if (code.length == 6) {
//       _playAnimation();
//       AuthCredential _authCredential = PhoneAuthProvider.credential(
//           verificationId: _verificationId, smsCode: code);
//
//       _firebaseAuth
//           .signInWithCredential(_authCredential)
//           .then((UserCredential value) async {
//         if (value.user != null) {
//           SettingProvider settingsProvider =
//               Provider.of<SettingProvider>(context, listen: false);
//
//           await buttonController!.reverse();
//           setSnackbar(getTranslated(context, 'OTPMSG')!);
//           settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
//           settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!);
//           if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
//             Future.delayed(Duration(seconds: 2)).then((_) {
//               Navigator.pushReplacement(
//                   context, MaterialPageRoute(builder: (context) => SignUp()));
//             });
//           } else if (widget.title ==
//               getTranslated(context, 'FORGOT_PASS_TITLE')) {
//             Future.delayed(Duration(seconds: 2)).then((_) {
//               Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           SetPass(mobileNumber: widget.mobileNumber!)));
//             });
//           }
//         } else {
//           setSnackbar(getTranslated(context, 'OTPERROR')!);
//           await buttonController!.reverse();
//         }
//       }).catchError((error) async {
//         setSnackbar(getTranslated(context, 'WRONGOTP')!);
//
//         await buttonController!.reverse();
//       });
//     } else {
//       // setSnackbar(getTranslated(context, 'ENTEROTP')!);
//     }
//   }
//
//   Future<Null> _playAnimation() async {
//     try {
//       await buttonController!.forward();
//     } on TickerCanceled {}
//   }
//
//   getImage() {
//     return Expanded(
//       flex: 4,
//       child: Center(
//         child: Image.asset('assets/images/homelogo.png'),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     buttonController!.dispose();
//     super.dispose();
//   }
//
//   monoVarifyText() {
//     return Padding(
//         padding: EdgeInsetsDirectional.only(
//           top: 20.0,
//         ),
//         child: Center(
//           child: Text(getTranslated(context, 'MOBILE_NUMBER_VARIFICATION')!,
//               style: Theme.of(context).textTheme.subtitle1!.copyWith(
//                   color: colors.primary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 25)),
//         ));
//   }
//
//   otpText() {
//     return Padding(
//         padding: EdgeInsetsDirectional.only(top: 30.0, start: 20.0, end: 20.0),
//         child: Center(
//           child: Text(getTranslated(context, 'SENT_VERIFY_CODE_TO_NO_LBL')!,
//               style: Theme.of(context).textTheme.subtitle2!.copyWith(
//                   color: Theme.of(context).colorScheme.fontColor,
//                   fontWeight: FontWeight.normal)),
//         ));
//   }
//
//   mobText() {
//     return Padding(
//       padding: EdgeInsetsDirectional.only(
//           bottom: 10.0, start: 20.0, end: 20.0, top: 10.0),
//       child: Center(
//         child: Text("+${widget.countryCode}-${widget.mobileNumber}",
//             style: Theme.of(context).textTheme.subtitle1!.copyWith(
//                 color: Theme.of(context).colorScheme.fontColor,
//                 fontWeight: FontWeight.normal)),
//       ),
//     );
//   }
//
//   Widget otpLayout() {
//     return Padding(
//         padding: EdgeInsetsDirectional.only(
//           start: 50.0,
//           end: 50.0,
//         ),
//         child: Center(
//             child: PinFieldAutoFill(
//                 decoration: UnderlineDecoration(
//                   textStyle: TextStyle(
//                       fontSize: 20,
//                       color: Theme.of(context).colorScheme.fontColor),
//                   colorBuilder: FixedColorBuilder(colors.primary),
//                 ),
//                 currentCode: otp,
//                 codeLength: 4,
//                 onCodeChanged: (String? code) {
//                   otp = code;
//                 },
//                 onCodeSubmitted: (String code) {
//                   otp = code;
//                 })));
//   }
//
//   Widget resendText() {
//     return Padding(
//       padding: EdgeInsetsDirectional.only(
//           bottom: 30.0, start: 25.0, end: 25.0, top: 10.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             getTranslated(context, 'DIDNT_GET_THE_CODE')!,
//             style: Theme.of(context).textTheme.caption!.copyWith(
//                 color: Theme.of(context).colorScheme.fontColor,
//                 fontWeight: FontWeight.normal),
//           ),
//           InkWell(
//               onTap: () async {
//                 await buttonController!.reverse();
//                 checkNetworkOtp();
//               },
//               child: Text(
//                 getTranslated(context, 'RESEND_OTP')!,
//                 style: Theme.of(context).textTheme.caption!.copyWith(
//                     color: Theme.of(context).colorScheme.fontColor,
//                     decoration: TextDecoration.underline,
//                     fontWeight: FontWeight.normal),
//               ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   expandedBottomView() {
//     return Expanded(
//       flex: 6,
//       child: Container(
//         alignment: Alignment.bottomCenter,
//         child: ScrollConfiguration(
//             behavior: MyBehavior(),
//             child: SingleChildScrollView(
//               child: Card(
//                 elevation: 0.5,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//                 margin: EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     monoVarifyText(),
//                     otpText(),
//                     mobText(),
//                     otpLayout(),
//                     verifyBtn(),
//                     resendText(),
//                   ],
//                 ),
//               ),
//             )),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         resizeToAvoidBottomInset: false,
//         key: _scaffoldKey,
//         body: Stack(
//           children: [
//             Container(
//               width: double.infinity,
//               height: double.infinity,
//               decoration: back(),
//             ),
//             Image.asset(
//               'assets/images/doodle.png',
//               fit: BoxFit.fill,
//               width: double.infinity,
//               height: double.infinity,
//             ),
//             getLoginContainer(),
//             getLogo(),
//           ],
//         ));
//   }
//
//   getLoginContainer() {
//     return Positioned.directional(
//       start: MediaQuery.of(context).size.width * 0.025,
//       // end: width * 0.025,
//       // top: width * 0.45,
//       top: MediaQuery.of(context).size.height * 0.2, //original
//       //    bottom: height * 0.1,
//       textDirection: Directionality.of(context),
//       child: ClipPath(
//         clipper: ContainerClipper(),
//         child: Container(
//           alignment: Alignment.center,
//           padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom * 0.6),
//           height: MediaQuery.of(context).size.height * 0.7,
//           width: MediaQuery.of(context).size.width * 0.95,
//           color: Theme.of(context).colorScheme.white,
//           child: Form(
//             // key: _formkey,
//             child: ScrollConfiguration(
//               behavior: MyBehavior(),
//               child: SingleChildScrollView(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(
//                     maxHeight: MediaQuery.of(context).size.height * 2,
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.10,
//                       ),
//                       monoVarifyText(),
//                       otpText(),
//                       mobText(),
//                       otpLayout(),
//                       verifyBtn(),
//                       resendText(),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.10,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget getLogo() {
//     return Positioned(
//       // textDirection: Directionality.of(context),
//       left: (MediaQuery.of(context).size.width / 2) - 50,
//       // right: ((MediaQuery.of(context).size.width /2)-55),
//
//       top: (MediaQuery.of(context).size.height * 0.2) - 50,
//       //  bottom: height * 0.1,
//       child: SizedBox(
//         width: 100,
//         height: 100,
//         child: Image.asset(
//           'assets/images/loginlogo.png',
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tlkmartuser/Helper/Color.dart';
import 'package:tlkmartuser/Helper/Constant.dart';
import 'package:tlkmartuser/Helper/cropped_container.dart';
import 'package:tlkmartuser/Provider/SettingProvider.dart';
import 'package:tlkmartuser/Screen/Details.dart';
import 'package:tlkmartuser/Screen/Set_Password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Provider/UserProvider.dart';
import 'SignUp.dart';

class VerifyOtp extends StatefulWidget {
  final String? mobileNumber, countryCode, title;
  final otp;
  VerifyOtp(
      {Key? key,
      required String this.mobileNumber,
      this.countryCode,
      this.title,
      this.otp})
      : assert(mobileNumber != null),
        super(key: key);

  @override
  _MobileOTPState createState() => _MobileOTPState();
}

class _MobileOTPState extends State<VerifyOtp> with TickerProviderStateMixin {
  final dataKey = GlobalKey();
  String? password;
  String? otp;
  bool isCodeSent = false;
  late String _verificationId;
  String signature = "";
  bool _isClickable = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  @override
  void initState() {
    print("==logintitle============${widget.title}===========");
    otppp = widget.otp.toString();
    super.initState();
    getUserDetails();
    getSingature();
    // _onVerifyCode();
    Future.delayed(Duration(seconds: 60)).then((_) {
      _isClickable = true;
    });
    buttonController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: Interval(
        0.0,
        0.150,
      ),
    ));
  }

  Future<void> getVerifyUser() async {
    try {
      var data = {MOBILE: widget.mobileNumber, "forgot_otp": "false"};
      Response response =
          await post(getVerifyUserApi, body: data, headers: headers)
              .timeout(Duration(seconds: timeOut));
      print(getVerifyUserApi.toString());
      print(data.toString());
      print(getVerifyUserApi);
      print(data);
      var getdata = json.decode(response.body);
      bool? error = getdata["error"];
      String? msg = getdata["message"];
      await buttonController!.reverse();

      SettingProvider settingsProvider =
          Provider.of<SettingProvider>(context, listen: false);

      // if(widget.checkForgot == "false"){
      if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
        if (!error!) {
          String otp = getdata["data"];
          // setSnackbar(otp.toString());
          Fluttertoast.showToast(
              msg: otp.toString(), backgroundColor: colors.primary);
          // setSnackbar(msg!);
          // settingsProvider.setPrefrence(MOBILE, mobile!);
          // settingsProvider.setPrefrence(COUNTRY_CODE, countrycode!);
          Future.delayed(Duration(seconds: 1)).then((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyOtp(
                  otp: otp,
                  mobileNumber: widget.mobileNumber!,
                  countryCode: widget.countryCode,
                  title: getTranslated(context, 'SEND_OTP_TITLE'),
                ),
              ),
            );
          });
        } else {
          setSnackbar(msg!);
        }
      } else {
        if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')) {
          if (!error!) {
            String otp = getdata["data"];
            Fluttertoast.showToast(
                msg: otp.toString(), backgroundColor: colors.primary);
            // setSnackbar(otp.toString());
            // settingsProvider.setPrefrence(MOBILE, mobile!);
            // settingsProvider.setPrefrence(COUNTRY_CODE, countrycode!);
            Future.delayed(Duration(seconds: 1)).then((_) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VerifyOtp(
                            otp: otp,
                            mobileNumber: widget.mobileNumber!,
                            countryCode: widget.countryCode,
                            title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                          )));
            });
          } else {
            setSnackbar(getTranslated(context, 'FIRSTSIGNUP_MSG')!);
          }
        }
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
      await buttonController!.reverse();
    }
  }

  Future<void> getSingature() async {
    signature = await SmsAutoFill().getAppSignature;
    await SmsAutoFill().listenForCode;
  }

  getUserDetails() async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);

    if (mounted) setState(() {});
  }

  Future<void> checkNetworkOtp() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      if (_isClickable) {
        // _onVerifyCode();

        if (widget.title == "isloging") {
          resendinLogin();
        } else {
          getVerifyUser();
        }

        // otpCheck();
      } else {
        setSnackbar(getTranslated(context, 'OTPWR')!);
      }
    } else {
      if (mounted) setState(() {});

      Future.delayed(Duration(seconds: 60)).then((_) async {
        bool avail = await isNetworkAvailable();
        if (avail) {
          if (_isClickable)
            // _onVerifyCode();
            //  otpCheck();
            getVerifyUser();
          else {
            setSnackbar(getTranslated(context, 'OTPWR')!);
          }
        } else {
          await buttonController!.reverse();
          setSnackbar(getTranslated(context, 'somethingMSg')!);
        }
      });
    }
  }

  Widget verifyBtn() {
    return AppBtn(
        title: getTranslated(context, 'VERIFY_AND_PROCEED'),
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          _onFormSubmitted();
          otpCheck();
        });
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
      ),
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      elevation: 1.0,
    ));
  }

  otpCheck() async {
    // if (widget.otp.toString() == otp.toString()) {
    if (otppp.toString() == otp.toString()) {
      SettingProvider settingsProvider =
          Provider.of<SettingProvider>(context, listen: false);

      // setSnackbar(getTranslated(context, 'OTPMSG')!);
      Fluttertoast.showToast(
          msg: getTranslated(context, 'OTPMSG')!,
          backgroundColor: colors.primary);
      settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
      settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!);
      if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
        Future.delayed(Duration(seconds: 2)).then((_) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignUp()));
        });
        // Future.delayed(Duration(seconds: 2)).then((_) {
        //   Navigator.pushReplacement(
        //       context, MaterialPageRoute(builder: (context) => SignUp()));
        // });
      } else if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')) {
        Future.delayed(Duration(seconds: 2)).then((_) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SetPass(mobileNumber: widget.mobileNumber!)));
        });
      } else if (widget.title == "isloging") {
        Future.delayed(Duration(seconds: 2)).then((_) {
          verifyotpforLogin();
        });
      }
    } else {
      setSnackbar('Please Fill OTP Field');
    }
  }

  void _onVerifyCode() async {
    if (mounted)
      setState(() {
        isCodeSent = true;
      });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _firebaseAuth
          .signInWithCredential(phoneAuthCredential)
          .then((UserCredential value) {
        if (value.user != null) {
          SettingProvider settingsProvider =
              Provider.of<SettingProvider>(context, listen: false);

          setSnackbar(getTranslated(context, 'OTPMSG')!);
          settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
          settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!);
          if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
            Future.delayed(Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => SignUp()));
            });
          } else if (widget.title ==
              getTranslated(context, 'FORGOT_PASS_TITLE')) {
            Future.delayed(Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SetPass(mobileNumber: widget.mobileNumber!)));
            });
          }
        } else {
          setSnackbar(getTranslated(context, 'OTPERROR')!);
        }
      }).catchError((error) {
        setSnackbar("OTP is not correct");
        setSnackbar(error.toString());
      });
    };
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setSnackbar("OTP is not correct");

      if (mounted)
        setState(() {
          isCodeSent = false;
        });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      _verificationId = verificationId;
      if (mounted)
        setState(() {
          _verificationId = verificationId;
        });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      if (mounted)
        setState(() {
          _isClickable = true;
          _verificationId = verificationId;
        });
    };

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+${widget.countryCode}${widget.mobileNumber}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {
    String code = otp!.trim();

    if (code.length == 6) {
      _playAnimation();
      AuthCredential _authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: code);

      _firebaseAuth
          .signInWithCredential(_authCredential)
          .then((UserCredential value) async {
        if (value.user != null) {
          SettingProvider settingsProvider =
              Provider.of<SettingProvider>(context, listen: false);

          await buttonController!.reverse();
          setSnackbar(getTranslated(context, 'OTPMSG')!);
          settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
          settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!);
          if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
            Future.delayed(Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => SignUp()));
            });
          } else if (widget.title ==
              getTranslated(context, 'FORGOT_PASS_TITLE')) {
            Future.delayed(Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SetPass(mobileNumber: widget.mobileNumber!)));
            });
          }
        } else {
          setSnackbar(getTranslated(context, 'OTPERROR')!);
          await buttonController!.reverse();
        }
      }).catchError((error) async {
        setSnackbar(getTranslated(context, 'WRONGOTP')!);

        await buttonController!.reverse();
      });
    } else {
      // setSnackbar(getTranslated(context, 'ENTEROTP')!);
    }
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  getImage() {
    return Expanded(
      flex: 4,
      child: Center(
        child: Image.asset('assets/images/homelogo.png'),
      ),
    );
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  monoVarifyText() {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          top: 20.0,
        ),
        child: Center(
          child: Text(getTranslated(context, 'MOBILE_NUMBER_VARIFICATION')!,
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 25)),
        ));
  }

  otpText() {
    return Padding(
        padding: EdgeInsetsDirectional.only(top: 30.0, start: 20.0, end: 20.0),
        child: Center(
          child: Text(getTranslated(context, 'SENT_VERIFY_CODE_TO_NO_LBL')!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal)),
        ));
  }

  mobText() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          bottom: 10.0, start: 20.0, end: 20.0, top: 10.0),
      child: Center(
        child: Text("+${widget.countryCode}-${widget.mobileNumber}",
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal)),
      ),
    );
  }

  OTPText() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          bottom: 10.0, start: 20.0, end: 20.0, top: 10.0),
      child: Center(
        child: Text("OTP: ${otppp}",
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal)),
      ),
    );
  }

  Widget otpLayout() {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          start: 50.0,
          end: 50.0,
        ),
        child: Center(
            child: PinFieldAutoFill(
                decoration: UnderlineDecoration(
                  textStyle: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.fontColor),
                  colorBuilder: FixedColorBuilder(colors.primary),
                ),
                currentCode: otp,
                
                codeLength: 4,
                onCodeChanged: (String? code) {
                  otp = code;
                },
                onCodeSubmitted: (String code) {
                  otp = code;
                  otppp = otp;
                })));
  }

  Widget resendText() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          bottom: 30.0, start: 25.0, end: 25.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            getTranslated(context, 'DIDNT_GET_THE_CODE')!,
            style: Theme.of(context).textTheme.caption!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal),
          ),
          InkWell(
            onTap: () async {
              await buttonController!.reverse();
              checkNetworkOtp();
            },
            child: Text(
              getTranslated(context, 'RESEND_OTP')!,
              style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  expandedBottomView() {
    return Expanded(
      flex: 6,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              child: Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    monoVarifyText(),
                    otpText(),
                    mobText(),
                    OTPText(),
                    otpLayout(),
                    verifyBtn(),
                    resendText(),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body:

          // Stack(
          //   children: [
          //     Container(
          //       width: double.infinity,
          //       height: double.infinity,
          //       decoration: back(),
          //     ),
          //     Image.asset(
          //       'assets/images/doodle.png',
          //       fit: BoxFit.fill,
          //       width: double.infinity,
          //       height: double.infinity,
          //     ),
          //     getLoginContainer(),
          //     getLogo(),
          //   ],
          // )
          SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Stack(
                children: [
                  Image.asset('assets/images/Login.png'),
                  Padding(
                    padding: const EdgeInsets.only(top: 150, left: 15),
                    child: Image.asset('assets/images/titleicon.png'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 23),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 33),
                    child: Center(
                        child: Text(
                      'OTP Verification',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    )),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(
                'Enter verification\ncode',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(
                'Enter the OTP sent to +91 9556654328',
                style: TextStyle(color: Colors.black.withOpacity(0.5)),
              ),
            ),

            OTPText(),
            SizedBox(
              height: 25,
            ),
            otpLayout(),
            SizedBox(
              height: 30,
            ),
            verifyOtpButton(),
            //child: MyButton(onTap: () {}, text: "Send"),
          ],
        ),
      ),
    );
  }

  verifyOtpButton() {
    return GestureDetector(
      onTap: () {
        _onFormSubmitted();
        otpCheck();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade900,
        ),
        height: 56,
        child: Center(
          child: Text(
            getTranslated(context, 'SIGNIN_LBL') ?? '',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
    // return AppBtn(
    //   title: getTranslated(context, 'SIGNIN_LBL'),
    //   btnAnim: buttonSqueezeanimation,
    //   btnCntrl: buttonController,
    //   onBtnSelected: () async {
    //     validateAndSubmit();
    //   },
    // );
  }

  getLoginContainer() {
    return Positioned.directional(
      start: MediaQuery.of(context).size.width * 0.025,
      // end: width * 0.025,
      // top: width * 0.45,
      top: MediaQuery.of(context).size.height * 0.2, //original
      //    bottom: height * 0.1,
      textDirection: Directionality.of(context),
      child: ClipPath(
        clipper: ContainerClipper(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.6),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.95,
          color: Theme.of(context).colorScheme.white,
          child: Form(
            // key: _formkey,
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      monoVarifyText(),
                      otpText(),
                      mobText(),
                      OTPText(),
                      otpLayout(),
                      verifyBtn(),
                      resendText(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Positioned(
      // textDirection: Directionality.of(context),
      left: (MediaQuery.of(context).size.width / 2) - 50,
      // right: ((MediaQuery.of(context).size.width /2)-55),

      top: (MediaQuery.of(context).size.height * 0.2) - 50,
      //  bottom: height * 0.1,
      child: SizedBox(
        width: 100,
        height: 110,
        child: Image.asset(
          'assets/images/loginlogo.png',
        ),
      ),
    );
  }

  Future<void> resendinLogin() async {
    var headers = {
      'Cookie': 'ci_session=2b2689736ef1a69d40f8e9ac7a769ff71c28e529'
    };
    var request =
        http.MultipartRequest('POST', Uri.parse('${baseUrl}login_with_otp'));
    request.fields.addAll({'mobile': "${widget.mobileNumber.toString()}"});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    print(request.url);
    print(request.fields);
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      print(result);
      var finalresult = jsonDecode(result);
      String msg = finalresult['message'];
      if (finalresult['error'] == false) {
        setSnackbar(msg);

        otppp = finalresult['otp'].toString();

        setState(() {});
      } else {}
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> verifyotpforLogin() async {
    await buttonController!.forward();
    var headers = {
      'Cookie': 'ci_session=c32369b36aac3982f15636a4d733087d06d9a11d'
    };
    var request =
        http.MultipartRequest('POST', Uri.parse('${baseUrl}otp_verify'));
    request.fields.addAll({
      'mobile': widget.mobileNumber.toString(),
      'otp': otp.toString(),
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(request.url);
    print(request.fields);
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      print(result);
      var finalresult = jsonDecode(result);
      String msg = finalresult['message'];
      if (finalresult['error'] == false) {
        id = finalresult['user'][0][ID];
        username = finalresult['user'][0][USERNAME];
        email = finalresult['user'][0][EMAIL];
        mobile = finalresult['user'][0][MOBILE];
        city = finalresult['user'][0][CITY];
        area = finalresult['user'][0][AREA];
        address = finalresult['user'][0][ADDRESS];
        pincode = finalresult['user'][0][PINCODE];
        latitude = finalresult['user'][0][LATITUDE];
        longitude = finalresult['user'][0][LONGITUDE];
        image = finalresult['user'][0][IMAGE];

        CUR_USERID = id;
        // CUR_USERNAME = username;

        UserProvider userProvider =
            Provider.of<UserProvider>(this.context, listen: false);
        userProvider.setName(username ?? "");
        userProvider.setEmail(email ?? "");
        userProvider.setProfilePic(image ?? "");

        SettingProvider settingProvider =
            Provider.of<SettingProvider>(context, listen: false);

        settingProvider.saveUserDetail(id!, username, email, mobile, city, area,
            address, pincode, latitude, longitude, image, context);
        await buttonController!.reverse();
        setSnackbar(msg);
        Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
      } else {
        await buttonController!.reverse();

        setSnackbar(msg);
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  String? mobile,
      username,
      email,
      id,
      mobileno,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      image;

  var otppp;
}
