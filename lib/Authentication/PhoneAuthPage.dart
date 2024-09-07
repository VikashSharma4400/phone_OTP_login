import 'package:blackcoffer_test_assignment/Authentication/OtpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:blackcoffer_test_assignment/Utils/Utils.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {

  bool isLoading = false;
  late String phoneNumber;

  TextEditingController phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


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
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IntlPhoneField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          initialCountryCode: 'IN',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (phone) {
                            setState(() {
                              phoneNumber = phone.completeNumber; // Get the E.164 formatted phone number
                            });
                          },
                          validator: (phone) {
                            // Handle the PhoneNumber object correctly
                            if (phone?.completeNumber == null || phone!.completeNumber.isEmpty) {
                              return 'Required!';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Enter Phone Number',
                            prefixIcon: const Icon(Icons.phone_android_outlined),
                            prefixIconColor: Colors.white,
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
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
                                if (_formKey.currentState?.validate() ?? false) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await FirebaseAuth.instance.verifyPhoneNumber(
                                    verificationCompleted: (PhoneAuthCredential credentials) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    },
                                    verificationFailed: (FirebaseAuthException ex) {
                                      Utils.showSnackBar(context, ex.toString());
                                      setState(() {
                                        isLoading = false;
                                        print("Verification Failed due to : $ex");
                                      });
                                    },
                                    codeSent: (String verificationId, int? resendToken) {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => OtpPage(verificationId: verificationId,)));
                                      setState(() {
                                        isLoading = false;
                                      });
                                      Utils.showSnackBar(context, "OTP sent successfully");
                                    },
                                    codeAutoRetrievalTimeout: (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      print("Timed OUT: $e");
                                    },
                                    phoneNumber: phoneNumber,
                                  );
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
                                    "Next",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Icon(Icons.arrow_forward),
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
