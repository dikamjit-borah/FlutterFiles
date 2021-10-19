import 'package:http/http.dart' as http;
import 'package:doc_mod/utils/constants.dart';

Future<String> httpUploadFile(String imgPath) async{
  var request = http.MultipartRequest("POST",Uri.parse(""+API_ADD_DOCUMENT));
  request.fields['tripId'] = "8807";
  request.fields['submoduleId'] = "13";
  request.fields['addedBy'] = "3";
  Map<String, String> headers = {
    "Accept": "application/json",
    "Authorization": TOKEN
  };
  request.headers.addAll(headers);
  var picture = await http.MultipartFile.fromPath("file[]", imgPath);
  request.files.add(picture);

  var response = await request.send();
  var responseData = await response.stream.toBytes();
  var result = String.fromCharCodes(responseData);
  print(result);
  return result;
}