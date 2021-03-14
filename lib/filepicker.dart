import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'const/gradiant_const.dart';
import 'contact_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _pickedImage;
  double width, height;
  final picker = ImagePicker();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isImageLoaded = false;
  Future pickImageCam() async {
    // var tempStore = await ImagePicker;
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _pickedImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future pickImageGal() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = File(pickedFile.path);
      isImageLoaded = true;
    });
  }

  Future readText() async {
    final FirebaseVisionImage ourImage =
        FirebaseVisionImage.fromFile(_pickedImage);
    final TextRecognizer recognizeText =
        FirebaseVision.instance.textRecognizer();
    final VisionText readText = await recognizeText.processImage(ourImage);
    String phnoPattern = r"^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$";
    String emailPattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
    RegExp regExp = RegExp(phnoPattern);
    RegExp regExpemail = RegExp(emailPattern);
    String phno;
    String email;
    String match;
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          match = line.text;
          (regExp.hasMatch(match))
              ? phno = line.text
              : (regExpemail.hasMatch(match))
                  ? email = line.text
                  : print('next');
        }
      }
    }
    if (phno != null || email != null) {
      (phno == null) ? phno = 'Unable to scan' : phno = phno;
      (email == null) ? email = 'Not identified' : email = email;
      Route route =
          MaterialPageRoute(builder: (context) => ContactPage(phno, email));
      Navigator.push(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;

    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "SMART ZAPY",
          style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              decorationThickness: 10,
              fontSize: 30),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(gradient: SIGNUP_BACKGROUND),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
              Widget>[
            Text(
              'Snap a Business Card and Save',
              style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900),
            ),
            SizedBox(
              height: height * 0.08,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              InkWell(
                onTap: pickImageCam,
                child: Column(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: Colors.teal,
                      size: 50.0,
                    ),
                    Text(
                      "camera",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: width * 0.2,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.teal,
                  onSurface: Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text('Gallery'),
                onPressed: pickImageGal,
              )
            ]),
            SizedBox(
              height: height * 0.08,
            ),
            MaterialButton(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.09, vertical: height * .01),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              color: Colors.pink[300],
              disabledColor: Colors.blueGrey[200],
              child: Text(
                'Save contact',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),
              ),
              onPressed: (_pickedImage != null) ? readText : null,
            ),
            // TextButton(onPressed: cardpress, child: Text('saved cards'))
          ])),
    );
  }
}
