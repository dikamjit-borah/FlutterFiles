import 'dart:convert';
import 'dart:io';

import 'package:doc_mod/api/api_calls.dart';
import 'package:doc_mod/pages/view_document.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedFile;
  var selectedFilePath;

  final String _fileUrl = "http://www.africau.edu/images/default/sample.pdf";
  final String _fileName = "DSCF0277.pdf";
  final Dio _dio = Dio();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


  @override
  void initState() {
    super.initState();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android:android, iOS:iOS);

    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: _onSelectNotification);

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity, // hard coding child width
            child: ElevatedButton(
              onPressed: ()=> {openCamera()  },
              child: const Text("Capture image"),),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity, // hard coding child width
            child: ElevatedButton(
              onPressed: ()=> {openFilePicker()  },
              child: const Text("Select File"),),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity, // hard coding child width
            child: ElevatedButton(
              onPressed: () {  },
              child: const Text("Upload file"),),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity, // hard coding child width
            child: ElevatedButton(
              onPressed: ()=> { downloadFile() },
              child: const Text("Download file"),),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity, // hard coding child width
            child: ElevatedButton(
              onPressed: () { openDocument(); },
              child: const Text("View file"),),
          ),
        ),
      ],
    );
  }

  Future openFilePicker() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      {
        selectedFile = File(result!.files.single.path!) ;
        selectedFilePath = result!.files.single.path!;
        print(selectedFilePath);
        uploadFile();
      }
    } else {
      print("File not selected");
    }
  }

  Future openCamera() async{
    final img = await ImagePicker().pickImage(source: ImageSource.camera);
    if(img != null) {
      selectedFilePath = img.path;
      print(selectedFilePath);
      uploadFile();
    }
    else {
      print("Image not captured");
    }
  }

  void uploadFile() async{
    print("Uploading "+ selectedFilePath);
    //print(httpUploadFile(selectedFilePath));
  }

  Future<void> downloadFile() async {
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();

    final savePath = path.join(dir!.path, _fileName);


    if (isPermissionStatusGranted) {

      await _startDownload(savePath);
    } else {
      // handle the scenario when user declines the permissions
    }
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }

    // in this example we are using only Android and iOS so I can assume
    // that you are not trying it for other platforms and the if statement
    // for iOS is unnecessary

    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }

  Future<bool> _requestPermissions() async {
    var permission = await Permission.storage.request();

    if (permission != PermissionStatus.granted) {
      await Permission.storage.request();
    }

    return permission == PermissionStatus.granted;
  }

  Future<void> _startDownload(String savePath) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };

    try {
      final response = await _dio.download(
        _fileUrl,
        savePath,
        //onReceiveProgress: _onReceiveProgress
      );
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (ex) {
      result['error'] = ex.toString();
    } finally {
      await _showNotification(result);
    }
  }

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
    const android = AndroidNotificationDetails(
        'channel id',
        'channel name',
        priority: Priority.high,
        importance: Importance.max
    );
    const iOS =  IOSNotificationDetails();
    const platform = NotificationDetails(android:android, iOS:iOS);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];

    await flutterLocalNotificationsPlugin.show(
        0, // notification id
        isSuccess ? 'Success' : 'Failure',
        isSuccess ? 'File has been downloaded successfully!' : 'There was an error while downloading the file.',
        platform,
        payload: json
    );
  }

  void _onSelectNotification(String? json) {
    final obj = jsonDecode(json!);

    if (obj['isSuccess']) {
      OpenFile.open(obj['filePath']);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('${obj['error']}'),
        ),
      );
    }
  }

  void openDocument() {
    Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewDocument(documentPath: selectedFilePath!,)));
  }
}
