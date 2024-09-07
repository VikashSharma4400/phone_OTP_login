import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Utils/Utils.dart';

class AddVideosPage extends StatefulWidget {
  const AddVideosPage({super.key});

  @override
  State<AddVideosPage> createState() => _AddVideosPageState();
}

class _AddVideosPageState extends State<AddVideosPage> {

  File? videoFile;
  VideoPlayerController? _videoPlayerController;
  CustomVideoPlayerController? _customVideoPlayerController;
  Position? _currentPosition;
  String? cityName;
  String selectedCategory = 'Education';
  bool _isLoading = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      setState(() {
        cityName = placeMarks.first.locality;
      });
    } catch (e) {
      print("Error getting location: $e");
      Utils.showSnackBar(context, 'Location access denied. Please enable location services.');
    }
  }

  Future<void> _pickVideo() async {
    var locationStatus = await Permission.location.request();
    if(locationStatus == PermissionStatus.granted) {
      final XFile? pickedFile = await ImagePicker().pickVideo(source: ImageSource.camera);
      setState(() {
        if (pickedFile != null) {
          videoFile = File(pickedFile.path);
        }
      });
      _playVideo();
    }
    else {
      Utils.showSnackBar(context, 'Location permission is required to record a video.');
    }
  }

  _playVideo() {
    if (videoFile != null) {
      _videoPlayerController = VideoPlayerController.file(videoFile!)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController?.play();
        });

      _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: _videoPlayerController!,
        customVideoPlayerSettings: const CustomVideoPlayerSettings(),
      );
    }
  }

  Future saveVideosData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? phone = user?.phoneNumber;

    String? originalFileName = videoFile?.path.split('/').last;
    Reference storageReference = FirebaseStorage.instance.ref().child('Posted_Videos/$phone/$originalFileName');
    await storageReference.putFile(videoFile!);
    Reference publicStorageReference = FirebaseStorage.instance.ref().child('Public Post/$originalFileName');
    await publicStorageReference.putFile(videoFile!);
    String videoUrl = await publicStorageReference.getDownloadURL();

    try {
      await FirebaseFirestore.instance.collection('Public Post').doc(DateTime.now().toIso8601String()).set({
        'Video Url': videoUrl,
        'Title': titleController.text,
        'Description': descriptionController.text,
        'Location': cityName,
        'Category': selectedCategory,
      });
      Utils.showSnackBar(context, 'Post successfully...');
    }
    on FirebaseAuthException catch (e) {
        Utils.showSnackBar(context, 'Video upload failed!');
        print("Error while uploading videos on firebase: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Video'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (videoFile != null)
                _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.3,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _videoPlayerController!.value.isPlaying
                                ? _videoPlayerController!.pause()
                                : _videoPlayerController!.play();
                          });
                        },
                        child: AspectRatio(
                          aspectRatio:
                              _videoPlayerController!.value.aspectRatio,
                          child: CustomVideoPlayer( customVideoPlayerController: _customVideoPlayerController!,),
                        ),
                      ),
                    )
                    : Container()
              else
                Container(),
              ElevatedButton(
                onPressed: () {
                  _pickVideo();
                },
                child: const Text("Record Video"),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: titleController,
                        maxLines: 2,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Required!'),
                          MaxLengthValidator(20, errorText: 'Too Long!'),
                        ]),
                        decoration: const InputDecoration(
                          labelText: 'Title'
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Required!'),
                          MaxLengthValidator(50, errorText: 'Too Long!'),
                        ]),
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: cityName),
                        maxLines: 1,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Wait to get location!'),
                        ]),
                        decoration: const InputDecoration(
                          labelText: 'Location',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 65,
                        child: DropdownButtonFormField(
                          value: selectedCategory,
                          items: const [
                            DropdownMenuItem(
                              value: 'Education',
                              child: Text('Education'),
                            ),
                            DropdownMenuItem(
                              value: 'News',
                              child: Text('News'),
                            ),
                            DropdownMenuItem(
                              value: 'Sports',
                              child: Text('Sports'),
                            ),
                            DropdownMenuItem(
                              value: 'Science and technology',
                              child: Text('Science and technology'),
                            ),
                            DropdownMenuItem(
                              value: 'Music',
                              child: Text('Music'),
                            ),
                            DropdownMenuItem(
                              value: 'Comedy',
                              child: Text('Comedy'),
                            ),
                            DropdownMenuItem(
                              value: 'Entertainment',
                              child: Text('Entertainment'),
                            ),
                            DropdownMenuItem(
                              value: 'Travel',
                              child: Text('Travel'),
                            ),
                            DropdownMenuItem(
                              value: 'Animation videos',
                              child: Text('Animation videos'),
                            ),
                            DropdownMenuItem(
                              value: 'Gaming',
                              child: Text('Gaming'),
                            ),
                            DropdownMenuItem(
                              value: 'Pets and animals',
                              child: Text('Pets and animals'),
                            ),
                            DropdownMenuItem(
                              value: 'Podcast',
                              child: Text('Podcast'),
                            ),
                            DropdownMenuItem(
                              value: 'Blogs',
                              child: Text('Blogs'),
                            ),
                            DropdownMenuItem(
                              value: 'Company',
                              child: Text('Company'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value!;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Category',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.54,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(54),
                              elevation: 8,
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                // Form is valid, proceed with sign up
                                try {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await saveVideosData();
                                } catch (error) {
                                  // Handle errors during sign-up
                                  print("Error during sign-up: $error");
                                  Utils.showSnackBar(context, 'Something went wrong!');
                                  // You might want to show an error message to the user here
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                            child: _isLoading
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
                                      "Post",
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
                    ]
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {

    _videoPlayerController?.dispose();
    _customVideoPlayerController?.dispose();

    super.dispose();
  }
}
