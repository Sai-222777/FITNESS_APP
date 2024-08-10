import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class QuitPage extends StatefulWidget {
  final String? email;
  const QuitPage({super.key, required this.email});

  @override
  State<QuitPage> createState() => _QuitPageState();
}

class _QuitPageState extends State<QuitPage> {

  final CollectionReference feedbackCollection = FirebaseFirestore.instance.collection('feedback');

  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;
  bool isChecked4 = false;

  String quits = '';

  Future<void> quit() async{
    quits = '';
    if(!isChecked1 && !isChecked2 && !isChecked3)
    {
      Navigator.popUntil(context, (route) => route.isFirst);
      return ;
    }
    if(isChecked1)
    {
      quits = '$quits long' ;
    }
    if(isChecked2)
    {
      quits = '$quits hard';
    }
    if(isChecked3)
    {
      quits = '$quits dislike';
    }

    DateTime now = DateTime.now();
    quits = '$quits ${DateFormat('MMM d').format(now)}';
    await feedbackCollection.doc(widget.email).set({
      'quits' : FieldValue.arrayUnion([quits])
    }, SetOptions(merge: true));
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: SafeArea(
        child: Column(
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.0,40,10,10),
                child: Text(
                  'QUITING SO SOON !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800
                  ),
                  ),
              ),
            ),
            Text(
              "'The only bad workout is the one you didn\'t do'",
              style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontSize: 15.0,
              ),
            ),
            const SizedBox(height: 30,),
            ListTile(
              leading: Transform.scale(
                scale: 1.5, 
                child: Checkbox(
                  value: isChecked1,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked1 = value ?? false;
                    });
                  },
                  activeColor: Colors.white,
                  checkColor: Colors.blue[900],
                  side: const BorderSide(width: 2.0, color: Colors.white),
                ),
              ),
              title: const Text(
                'Workout is too long',
                style: TextStyle(color: Colors.white,fontSize: 18),
              ),
            ),
            ListTile(
              leading: Transform.scale(
                scale: 1.5, 
                child: Checkbox(
                  value: isChecked2,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked2 = value ?? false;
                    });
                  },
                  activeColor: Colors.white,
                  checkColor: Colors.blue[900],
                  side: const BorderSide(width: 2.0, color: Colors.white),
                ),
              ),
              title: const Text(
                'Workout is too hard',
                style: TextStyle(color: Colors.white,fontSize: 18),
              ),
            ),
            ListTile(
              leading: Transform.scale(
                scale: 1.5, 
                child: Checkbox(
                  value: isChecked3,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked3 = value ?? false;
                    });
                  },
                  activeColor: Colors.white,
                  checkColor: Colors.blue[900],
                  side: const BorderSide(width: 2.0, color: Colors.white),
                ),
              ),
              title: const Text(
                'I don\'t like these exercises',
                style: TextStyle(color: Colors.white,fontSize: 18),
              ),
            ),
            ListTile(
              leading: Transform.scale(
                scale: 1.5, 
                child: Checkbox(
                  value: isChecked4,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked4 = value ?? false;
                    });
                  },
                  activeColor: Colors.white,
                  checkColor: Colors.blue[900],
                  side: const BorderSide(width: 2.0, color: Colors.white),
                ),
              ),
              title: const Text(
                'I will do it later',
                style: TextStyle(color: Colors.white,fontSize: 18),
              ),
            ),
            SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(Color.fromRGBO(49, 15, 64, 1)),
                  ), 
                  child: Text('RESUME', style: TextStyle(color: Colors.pink[400], fontWeight: FontWeight.w600),)
                ),
                TextButton(
                  onPressed: ()async{
                    await quit();
                  }, 
                  child: Text('QUIT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800
                    ),
                  )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}