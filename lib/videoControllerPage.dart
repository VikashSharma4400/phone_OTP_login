import 'package:flutter/material.dart';
import 'package:appinio_video_player/appinio_video_player.dart';

class VideoControllerPage extends StatefulWidget {
  final Map<String, dynamic>? documentData;

  const VideoControllerPage({Key? key, required this.documentData}) : super(key: key);

  @override
  State<VideoControllerPage> createState() => _VideoControllerPageState();
}

class _VideoControllerPageState extends State<VideoControllerPage> {


  late VideoPlayerController _controller;
  late CustomVideoPlayerController _customVideoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.documentData?['Video Url']));

    _controller.addListener(() {
      setState(() {});
    });

    _controller.setLooping(true);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) => setState(() {}));

    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: _controller,
      customVideoPlayerSettings: CustomVideoPlayerSettings(),
    );
    _controller.play();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey ,
        body: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CustomVideoPlayer( customVideoPlayerController: _customVideoPlayerController,),
                  ),
                );
              }
              else {
                return Center(child: CircularProgressIndicator());
              }
            }
        )
    );
  }
}
