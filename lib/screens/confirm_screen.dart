// ConfirmScreen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_media_app/controller/upload_video_controller.dart';
import 'package:social_media_app/widgets/text_input_field.dart';
import 'package:video_player/video_player.dart';

class ConfirmScreen extends StatefulWidget {
  final File videoFile;
  final String videoPath;
  final Function onUploadComplete; // Add this line

  const ConfirmScreen({
    Key? key,
    required this.videoFile,
    required this.videoPath,
    required this.onUploadComplete, // Add this line
  }) : super(key: key);

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  late VideoPlayerController controller;
  TextEditingController songController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  UploadVideoController uploadVideoController =
      Get.put(UploadVideoController());

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
        controller.play();
        controller.setVolume(1);
        controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void uploadVideo(BuildContext context) async {
    try {
      await uploadVideoController.uploadVideo(
        songController.text,
        captionController.text,
        widget.videoPath,
      );
      widget.onUploadComplete(); // Call the callback function
      Navigator.pop(context); // Go back to the previous screen
      Get.snackbar("Video uploaded", "Video uploaded successfully");
    } catch (err) {
      Get.snackbar("Error", err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            if (controller.value.isInitialized)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.5,
                child: VideoPlayer(controller),
              ),
            const SizedBox(height: 30),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  width: MediaQuery.of(context).size.width - 20,
                  child: TextInputField(
                    controller: songController,
                    labelText: 'Song name',
                    icon: Icons.music_note,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  width: MediaQuery.of(context).size.width - 20,
                  child: TextInputField(
                    controller: captionController,
                    labelText: 'Caption',
                    icon: Icons.closed_caption,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () =>
                      uploadVideo(context), // Call uploadVideo function
                  child: Text(
                    'Share',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
