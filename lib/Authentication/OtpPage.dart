import 'package:blackcoffer_test_assignment/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pinput/pinput.dart';

import '../bottomTabbarPage.dart';

class OtpPage extends StatefulWidget {

  final String verificationId;

  const OtpPage({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {

  bool isLoading = false;

  TextEditingController otpController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.orange,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(70),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Image.asset('assets/Blackcoffer_logo.png'),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.orange.shade300,
                      Colors.orange.shade200,
                      Colors.yellow,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(70),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Pinput(
                          controller: otpController,
                          length: 6,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.54,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(54),
                                elevation: 16,
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () async {
                                if(formKey.currentState?.validate() ?? false){
                                  setState(() {
                                    isLoading = true;
                                  });
                                  final verificationId = widget.verificationId;
                                  print("Verification ID: $verificationId");
                                  print("Entered OTP: ${otpController.text}");
                                  if (verificationId.isNotEmpty) {
                                    final credential = PhoneAuthProvider.credential(
                                      verificationId: widget.verificationId,
                                      smsCode: otpController.text.toString().trim(),
                                    );
                                    try {
                                      await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TabBarPage()));
                                      });
                                    }
                                    catch (ex) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      print("Error during sign-up: $ex");
                                      Utils.showSnackBar(context, ex.toString());
                                    }
                                  }
                                }
                              },
                              child: isLoading
                                  ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SpinKitCircle(
                                        color: Colors.orange,
                                        size: 40.0,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Please Wait..",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  )
                                  : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Verify",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Icon(Icons.verified_sharp),
                                    ],
                                  )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
