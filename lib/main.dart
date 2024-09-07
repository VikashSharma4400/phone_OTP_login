import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'Authentication/PhoneAuthPage.dart';
import 'bottomTabbarPage.dart';

Future main() async {

  WidgetsFlutterBinding.ensureInitialized();

Platform.isAndroid
    ? await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyB-kxHpJaQKx49Y6HzorszMwLPA24f9Yek",
          appId: "1:882381681039:android:de952f9849e0234fde1bfa",
          messagingSenderId: "882381681039",
          storageBucket: "gs://blackcoffer-test-assignm-6fa97.appspot.com",
          projectId: "blackcoffer-test-assignm-6fa97",
        ),
    )
    : await Firebase.initializeApp();
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blackcoffer Test Assignment',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?> (
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: SpinKitCircle(color: Colors.white));
            }
            else if(snapshot.hasError) {
              return const Center(child: Text("Something Went Wrong!"));
            }
            else if(snapshot.hasData) {
              return const TabBarPage();
            }
            else {
              return const PhoneAuthPage();
            }
          },
        )
    );
  }
}
