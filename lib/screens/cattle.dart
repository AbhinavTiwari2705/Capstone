import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CattleScreen extends StatefulWidget {
  @override
  _CattleScreenState createState() => _CattleScreenState();
}

class _CattleScreenState extends State<CattleScreen> {
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadImage(File image) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.predictCattle(image.path);
      setState(() => _isLoading = false);

      if (response['success']) {
        final data = response['data'];
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.predictionResult,
                style: TextStyle(color: Colors.black)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Breed: ${data['breed'] ?? 'Unknown'}',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
                SizedBox(height: 8),
                Text('Health Status: ${data['health_status'] ?? 'Unknown'}',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
                if (data['confidence'] != null) ...[
                  SizedBox(height: 8),
                  Text('Confidence: ${(data['confidence'] * 100).toStringAsFixed(1)}%',
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                ],
                if (data['recommendations'] != null) ...[
                  SizedBox(height: 16),
                  Text('Recommendations:',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Text(data['recommendations'],
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.ok, style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.error, style: TextStyle(color: Colors.black)),
            content: Text(response['message'] ?? AppLocalizations.of(context)!.failedToGetPrediction,
                style: TextStyle(color: Colors.black)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.ok, style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.error, style: TextStyle(color: Colors.black)),
          content: Text(AppLocalizations.of(context)!.anErrorOccurredWhileProcessingTheImage,
              style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.ok, style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.cattleHealth,
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.brown[50]!, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.pets, size: 60, color: Colors.brown[700]),
                        SizedBox(height: 15),
                        Text(
                          AppLocalizations.of(context)!.cattleHealthCheck,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.uploadOrCaptureAnImageOfYourCattleToDetectPotentialHealthIssues,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                if (_image == null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      AppLocalizations.of(context)!.getStarted,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(_image!, height: 200),
                  ),
                SizedBox(height: 30),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.camera_alt, color: Colors.white),
                          label: Text(AppLocalizations.of(context)!.takePhoto,
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: getImageFromCamera,
                        ),
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.photo_library, color: Colors.white),
                          label: Text(AppLocalizations.of(context)!.chooseFromGallery,
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[600],
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: getImageFromGallery,
                        ),
                      ),
                      SizedBox(height: 15),
                      if (_image != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.cloud_upload, color: Colors.white),
                            label: Text(AppLocalizations.of(context)!.analyzeImage,
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[700],
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => uploadImage(_image!),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
