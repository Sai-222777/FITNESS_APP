import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});



  Future<List<String>> fetchUserHistory()async{
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference bioCollection = FirebaseFirestore.instance.collection('bio');
    DocumentSnapshot doc = await bioCollection.doc(user!.email).get();
    return List<String>.from(doc['past']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HISTORY', style: TextStyle(color: Colors.white70),),
        backgroundColor: Color(0xff003865),
        iconTheme: IconThemeData(
          color: Colors.white70
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: fetchUserHistory(), 
              builder: (BuildContext context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting)
                {
                  return const Center(child: CircularProgressIndicator(color: Color.fromRGBO(21, 101, 192, 1)),);
                }
                else if(!snapshot.hasData || snapshot.data!.isEmpty || snapshot.hasError) 
                {
                  return Column(
                    children: [
                      SizedBox(height: 100,),
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'No History Found!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                else
                {
                  final history = snapshot.data!;
                  final length = history.length;
                  return ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (BuildContext context, index){
                      final data = history[length-index-1].split('-');
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8,5,8,5),
                        child: Container(
                          height: 70,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 82,
                                child: Text(
                                  data[0],
                                  style: GoogleFonts.mukta(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: 8,),
                              Icon(
                                Icons.calendar_month,
                                color: Colors.red[300],
                                ),
                              SizedBox(width: 4,),
                              SizedBox(
                                width: 82,
                                child: Text(
                                  data[1],
                                  style: GoogleFonts.mukta(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              SizedBox(width: 5,),
                              Icon(
                                Icons.timelapse,
                                color: Colors.blue[700],
                                ),
                              SizedBox(width: 4,),
                              SizedBox(
                                width: 56,
                                child: Text(
                                  data[2]+' mins',
                                  style: GoogleFonts.mukta(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              SizedBox(width: 3,),
                              Icon(
                                Icons.flash_on,
                                color: Colors.yellow[800],
                                ),
                              SizedBox(width: 2,),
                              Text(
                                data[3]+' cal',
                                style: GoogleFonts.mukta(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                  );
                } 
              }
            ),
          ),
        ],
      ),
    );
  }
}