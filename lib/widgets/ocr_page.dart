
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:string_similarity/string_similarity.dart';

import 'package:google_ml_kit/google_ml_kit.dart';

late List<CameraDescription> _cameras;

class OCRPage extends StatefulWidget {
  int counter = 1;
  late BuildContext ctx;

  OCRPage({super.key, required BuildContext ctx}) {
    this.ctx = ctx;
  }

  @override
  State<OCRPage> createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> {
  dynamic _scanResults;
  late CameraController? cameraController = null;

  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;
  final textDetector = GoogleMlKit.vision.textDetector();
  List<String> recognisedMRZ = [];
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
            <DeviceOrientation>[DeviceOrientation.portraitUp])
        .then((value) => _initializeCamera());
  }

  @override
  void dispose() {
    cameraController!.dispose();
    super.dispose();
  }

  void _initializeCamera() async {
    _cameras = await availableCameras();
    cameraController = CameraController(
      _cameras[0],
      ResolutionPreset.ultraHigh,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    cameraController!.initialize().then(((value) {
      setState(() {});
    })).then((value) async {
      cameraController!.startImageStream((CameraImage cameraImage) async {
        // for not taking memory over usage error decrase frame rate.
        widget.counter++;
        if (widget.counter % 10 == 0) {
          InputImage inputImage = getInputImage(cameraImage);
          final RecognisedText recognisedText =
              await textDetector.processImage(inputImage);
          // Using the recognised text.
          for (TextBlock block in recognisedText.blocks) {
            // optimize miss recognised characters
            String blockText = block.text;
            blockText = blockText.trim();
            blockText = blockText.replaceAll(" ", "");
            blockText = blockText.replaceAll("«", "<");
            blockText = blockText.replaceAll("\n", "");

            // check MRZ line is a valid format
            if (blockText.contains("<") &&
                blockText.length == 30 &&
                recognisedMRZ.length < 3 &&
                !blockText.contains(new RegExp(r'[a-z]'))) {
              bool flag = true;
              print("Text: " + blockText);
              for (String mrzParse in recognisedMRZ) {
                if (mrzParse.similarityTo(blockText) > 0.8) {
                  flag = false;
                  break;
                }
              }
              if (flag) recognisedMRZ.add(blockText);
            } else if (blockText.contains("<") &&
                blockText.length == 90 &&
                !blockText.contains(new RegExp(r'[a-z]'))) {
              recognisedMRZ = [];
              recognisedMRZ.add(blockText.substring(0, 30));
              recognisedMRZ.add(blockText.substring(30, 60));
              recognisedMRZ.add(blockText.substring(60, 90));
            }
          }

          if (MRZtransactions.checkMRZComplated(recognisedMRZ)) {
            //Check MRZ if format is not correct clear first 2 line and wait scan until scan correctly

            List<String> sortedMRZ = [" ", " ", " "];

            for (String st in recognisedMRZ) {
              // sort lines for correct format of mrz
              if (st[0] == "I" && st[1] == "<")
                sortedMRZ[0] = st;
              else if (double.tryParse(st[0]) != null)
                sortedMRZ[1] = st;
              else
                sortedMRZ[2] = st;
            }

            recognisedMRZ = [];

            if (MRZtransactions.checkMRZFormat(sortedMRZ)) {
              // check parsed infos are valid format

              Map infoMRZ = new Map();
              infoMRZ["DocumentNo"] =
                  MRZtransactions.parseDocumentNo(sortedMRZ)!;
              infoMRZ["DateofBirth"] =
                  MRZtransactions.parseDateofBirth(sortedMRZ)!;
              infoMRZ["DateofValid"] =
                  MRZtransactions.parseDateofValid(sortedMRZ)!;
              cameraController!.dispose();
              cameraController = null;
              Navigator.of(context).pop(infoMRZ); // Pop mrz result  as a MAP
            } else {
              recognisedMRZ.removeAt(0);
              recognisedMRZ.removeAt(0);
            }
          }

          print(recognisedMRZ);
        }
      });
    });
  }

  InputImage getInputImage(CameraImage cameraImage) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

    final InputImageRotation imageRotation =
        InputImageRotationMethods.fromRawValue(
                cameraController!.description.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final InputImageFormat inputImageFormat =
        InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
            InputImageFormat.NV21;

    final planeData = cameraImage.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null) {
      return Container();
    }
    return MaterialApp(
      home: CameraPreview(cameraController!),
    );
  }
}

class MRZtransactions {
  static bool checkMRZComplated(List<String> mrz) {
    // check MRZ is complated

    if (mrz.length == 3) {
      return true;
    } else
      return false;
  }

  static bool checkMRZFormat(List<String> sortedMRZ) {
    if (parseDateofBirth(sortedMRZ) != null &&
        parseDateofBirth(sortedMRZ) != null &&
        parseDocumentNo(sortedMRZ) != null)
      return true;
    else
      return false;
  }

  static String? parseDocumentNo(List<String> mrz) {
    String documentNo = "";
    int checkValid = 0;
    for (int i = 5; i < 14; i++) {
      documentNo = documentNo + mrz[0][i];
      if (double.tryParse(mrz[0][i]) != null) checkValid++;
    }

    if (checkValid == 7)
      return documentNo;
    else
      return null;
  }

  static String? parseDateofBirth(List<String> mrz) {
    String dateOfBirth = "";

    for (int i = 0; i < 6; i++) {
      dateOfBirth = dateOfBirth + mrz[1][i];
    }

    if (double.tryParse(dateOfBirth) != null)
      return dateOfBirth;
    else
      return null;
  }

  static String? parseDateofValid(List<String> mrz) {
    String dateOfValid = "";

    for (int i = 8; i < 14; i++) {
      dateOfValid = dateOfValid + mrz[1][i];
    }

    if (double.tryParse(dateOfValid) != null)
      return dateOfValid;
    else
      return null;
  }
}
