import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class CameraPicker extends StatefulWidget {
  CameraPicker({Key? key}) : super(key: key);

  @override
  _CameraPickerState createState() => _CameraPickerState();
}

class _CameraPickerState extends State<CameraPicker> {
  ImagePicker imagePicker = ImagePicker();
  File? imagemSelecionada;

  String text = "Teste";
  int index = 10;
  double confidence = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          imagemSelecionada == null
              ? Container()
              : Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.file(imagemSelecionada!),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(text),
                          Text(index.toString()),
                          Text(confidence.toString()),
                        ],
                      )
                    ],
                  )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    pegarImagem();
                  },
                  icon: Icon(
                    Icons.photo_camera_outlined,
                  ))
            ],
          )
        ],
      ),
    ));
  }

  pegarImagem() async {
    final PickedFile? imagemTemp =
        await imagePicker.getImage(source: ImageSource.gallery);

    if (imagemTemp != null) {
      setState(() {
        imagemSelecionada = File(imagemTemp.path);
        KitML(InputImage.fromFilePath(imagemTemp.path));
      });
    }
  }

  KitML(InputImage inputImage) async {
    final faceDetector = GoogleMlKit.vision.faceDetector();
    final imageLabeler = GoogleMlKit.vision.imageLabeler();
    final List<Face> faces = await faceDetector.processImage(inputImage);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    for (Face face in faces) {
      final Rect boundingBox = face.boundingBox;

      final double? rotY =
          face.headEulerAngleY; // Head is rotated to the right rotY degrees
      final double? rotZ =
          face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

      // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
      // eyes, cheeks, and nose available):
      final FaceLandmark? leftEar = face.getLandmark(FaceLandmarkType.leftEar);
      if (leftEar != null) {
        final dynamic leftEarPos = leftEar.position;
      }

      // If classification was enabled with FaceDetectorOptions:
      if (face.smilingProbability != null) {
        final double? smileProb = face.smilingProbability;
      }

      // If face tracking was enabled with FaceDetectorOptions:
      if (face.trackingId != null) {
        final int? id = face.trackingId;
      }
    }

    for (ImageLabel label in labels) {
      text = label.label;
      index = label.index;
      confidence = label.confidence;
    }
  }
}
