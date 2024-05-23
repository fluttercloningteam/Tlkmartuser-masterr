import 'dart:convert';
// import 'package:tlkmartuser/Helper/widgets.dart';
// import 'package:tlkmartuser/Model/SingleSellerModal.dart';
// import 'package:tlkmartuser/Model/UpdateUserModels.dart';
// import 'package:tlkmartuser/Model/UserDetails.dart';
import 'package:http/http.dart' as http;
import '../../Model/SingleSellerModal.dart';
import '../../Model/UpdateUserModels.dart';
import '../../Model/UserDetails.dart';
import '../Session.dart';
import '../String.dart';

Future<UserDetails?> userDetails() async {
  var header = headers;
  var request = http.MultipartRequest('POST',getUserDetailsApi);
  request.fields.addAll({'user_id': '$CUR_USERID'});

  request.headers.addAll(header);
  print(request);
  print(request.fields);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    final str = await response.stream.bytesToString();
    print(str);
    return UserDetails.fromJson(json.decode(str));
  } else {
    return null;
  }
}

Future<UpdateUserModels?> uploadImage(param, image) async {
  var header = headers;
  var request = http.MultipartRequest('POST',updateUserApi);
  request.fields.addAll({'user_id': '$CUR_USERID'});
  request.files.add(await http.MultipartFile.fromPath('$param', '$image'));
  request.headers.addAll(header);

  http.StreamedResponse response = await request.send();
 print(request.fields);
 print(request.files[0].field);
 print(response.statusCode);
  if (response.statusCode == 200) {
    final str = await response.stream.bytesToString();
    return UpdateUserModels.fromJson(json.decode(str));
  } else {
    return null;
  }
}

Future<UpdateUserModels?> updateUserDetails(userName , email, dob) async {
  var header = headers;
  var request = http.MultipartRequest('POST', updateUserApi);
  request.fields.addAll({
    'user_id': '$CUR_USERID',
    'username': '$userName',
    'email': '$email',
    'dob': '$dob',
  });
  request.headers.addAll(header);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    final str = await response.stream.bytesToString();
    return UpdateUserModels.fromJson(json.decode(str));
  } else {
    return null;
  }
}

Future<SingleSellerModal?> singleSeller(sellerId) async{
  var header = headers;
  var request = http.MultipartRequest('POST', getSellerApi);
  request.fields.addAll({
    'seller_id': sellerId
  });

  request.headers.addAll(header);
  print("API Seller Id: $sellerId");
  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    final data = await response.stream.bytesToString();
    return SingleSellerModal.fromJson(json.decode(data));
  }
  else {
    return null;
  }
}

checkOnOff(sellerId) async{
  SingleSellerModal? modal = await singleSeller(sellerId);
  if(modal!.error == false){
    if(modal.data![0].openCloseStatus == '1'){
      print("CHEK ON OFF STATUS ========================> ${modal.data![0].openCloseStatus}");
      return true;
    }else {
      return false;
    }
  } else {
    print("Error");
  }
}
Future<String> deleteAccount(userId) async {
  var header = headers;
  var request = http.MultipartRequest('POST', getDeleteAccountApi);
  request.fields.addAll({'user_id': userId});

  request.headers.addAll(header);
  print('delete-----${request}');
  print(request.fields);
  print(request.headers);
  http.StreamedResponse response = await request.send();
  print('response  $response');
  if (response.statusCode == 200) {
    print('mmmmmmmmmmmmm');
    final data = await response.stream.bytesToString();
    return json.decode(data)['message'];
  } else {
    return 'Unable to delete account';
  }
}