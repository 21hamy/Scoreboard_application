import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ButtonStatus extends StatefulWidget {
  const ButtonStatus({super.key});

  @override
  State<ButtonStatus> createState() => _ButtonStatusState();
}

class _ButtonStatusState extends State<ButtonStatus> {
  late DatabaseReference dbRef;
  late DatabaseReference dbRef2;

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
            dbRef2 = FirebaseDatabase.instance.ref().child('$usePath/BoardRespond');
          } else {
            getFirebasePath = 'No data found';
            usePath = 'Default';
            dbRef = FirebaseDatabase.instance.ref().child(usePath);
            dbRef2 = FirebaseDatabase.instance.ref().child('$usePath/BoardRespond');
          }
        });
      },
    ); 
  }

  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: Size(25.w, 5.h),
          backgroundColor: onClick
              ? const Color.fromARGB(255, 56, 56, 56)
              : const Color.fromARGB(255, 23, 36, 113)),
      onPressed: () {
        if (!onClick) {
          setState(() {
            onClick = true;
          });

          Map<String, String> alldatas = {
            'CheckBoardStatus': 'check',
          };
          dbRef.update(alldatas);
          print("Send check");

          Future.delayed(
            const Duration(seconds: 2),
            () {
              String boardStatus;
              String st_board, nd_board, rd_board;
              //print("Done wait....");
              dbRef2.get().then(
                (DataSnapshot) {
                  boardStatus = DataSnapshot.value.toString();
                  print(boardStatus);
                  st_board = boardStatus.substring(16, 17);
                  nd_board = boardStatus.substring(34, 35);
                  rd_board = boardStatus.substring(52, 53);
                  print(st_board + ' | ' + nd_board + ' | ' + rd_board);

                  if (st_board == '1' && nd_board == '1' && rd_board == '1') {
                    showToastSucces(context);
                    Map<String, String> alldatas = {
                      'CheckBoardStatus': 'hold',
                    };
                    dbRef.update(alldatas);
                    Map<String, int> alldatas2 = {
                      'Board1Respond': 0,
                      'Board2Respond': 0,
                      'Board3Respond': 0,
                    };
                    FirebaseDatabase.instance
                        .ref()
                        .child('FlutterData/BoardRespond')
                        .update(alldatas2);
                    setState(() {
                      onClick = false;
                    });
                  } else {
                    showToastError(context);
                    Map<String, String> alldatas = {
                      'CheckBoardStatus': 'hold',
                    };
                    dbRef.update(alldatas);
                    Map<String, int> alldatas2 = {
                      'Board1Respond': 0,
                      'Board2Respond': 0,
                      'Board3Respond': 0,
                    };
                    FirebaseDatabase.instance
                        .ref()
                        .child('FlutterData/BoardRespond')
                        .update(alldatas2);
                    setState(() {
                      onClick = false;
                    });
                  }
                },
              );
            },
          );
        }
      },
      child: Text(
        'Status',
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}
