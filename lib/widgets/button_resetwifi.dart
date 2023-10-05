import 'package:flutter/material.dart';
import 'package:scoreboard/widgets/bar.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ButtonWiFi extends StatefulWidget {
  const ButtonWiFi({super.key});

  @override
  State<ButtonWiFi> createState() => _ButtonWiFiState();
}

class _ButtonWiFiState extends State<ButtonWiFi> {
  late DatabaseReference dbRef;
  
  String getFirebasePath = '';
  String usePath = 'Default';
  final firebasePath = const FlutterSecureStorage();

  bool onClick = false;

  @override
  void initState() {
    super.initState();
    firebasePath.read(key: 'Path').then(
      (value) {
        setState(() {
          if (value != '') {
            getFirebasePath = value.toString();
            usePath = getFirebasePath;
            print('Show read ' + usePath);
            dbRef = FirebaseDatabase.instance.ref().child(usePath);
          } else {
            getFirebasePath = 'No data found';
            usePath = 'Default';
            dbRef = FirebaseDatabase.instance.ref().child(usePath);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            minimumSize: Size(25.w, 5.h),
            backgroundColor: onClick
                ? const Color.fromARGB(255, 56, 56, 56)
                : const Color.fromARGB(255, 23, 36, 113)),
        onPressed: () {
          showResetBoardSucces(context);
          if (!onClick) {
            setState(() {
              onClick = true;
            });
            Map<String, String> alldatas1 = {
              'ResetStatus': 'yes',
            };
            dbRef.update(alldatas1);
            Future.delayed(const Duration(milliseconds: 800), () {
              setState(() {
                onClick = false;
              });
            });
          }
        },
        child: Text('Reset board configs',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)));
  }
}