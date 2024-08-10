import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/pages/history_page.dart';
import 'package:fitness/pages/start_workout_page.dart';
import 'package:fitness/pages/user_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_marquee/text_marquee.dart';

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double width = size.width;
    final double height = size.height;

    path.moveTo(width * 0.25, 0);
    path.lineTo(width * 0.75, 0);
    path.lineTo(width, height * 0.5);
    path.lineTo(width * 0.75, height);
    path.lineTo(width * 0.25, height);
    path.lineTo(0, height * 0.5);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;

}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final CollectionReference bioCollection = FirebaseFirestore.instance.collection('bio');
  User? user;
  String? username;
  final List<String> Workouts = ['ABS','CHEST','ARMS','LEGS','SHOULDERS & BACK', 'YOGA'];

  final List<String> quotes = [
    'Drink a glass of water atleast 20 minutes before you begin the workout.',
    'Stretch to lower your risk of injury and broaden your range of motion.',
    'The only bad workout is the one you didn\'t do',
    ];

  Map<String,String> prev = {
    'ABS' : '',
    'CHEST' : '',
    'ARMS': '',
    'LEGS': '',
    'SHOULDERS & BACK' :'',
    'YOGA' : '',
  };

  String startDate = '';
  int level = 1, exp = 0;

  String gender = '';


  @override
  void initState() {
    super.initState();
    getCurrentUsername();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void getCurrentUsername() async {
      user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot doc = await bioCollection.doc(user!.email).get();
      setState(() {
        gender = doc['Gender'];
        startDate = doc['startDate'];
        username = doc['Username'];
        level = doc['level'];
        exp = doc['exp'];
        prev['LEGS'] = doc['LEGS'];
        prev['ARMS'] = doc['ARMS'];
        prev['CHEST'] = doc['CHEST'];
        prev['ABS'] = doc['ABS'];
        prev['SHOULDERS & BACK'] = doc['SHOULDERS & BACK'];
        prev['YOGA'] = doc['YOGA'];
      });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[350],
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Text('ZENFIT' ,style:GoogleFonts.roboto(fontSize: 20)),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: double.infinity,
            color: Colors.black87,
            child: TextMarquee(
              quotes[0],
              startPaddingSize: 120,
              delay: Duration(seconds: 1),
              style: TextStyle(
                color: Colors.deepOrange[600],
                fontSize: 17,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      height: 100,
                      width: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.blue[600],
                      ),
                      child: username!=null? Center(
                        child: Text(
                          'HELLO,\n $username!',
                          style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ) : Center(
                        child: Text(
                          'HELLO!',
                          style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Center(
                    child: Text(
                      'FOREVER\nBELIEVE!',
                      style: GoogleFonts.headlandOne(
                        fontSize: 30, 
                        fontWeight: FontWeight.bold
                        ),
                    ),
                  ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14,4,4,8),
            child: Row(
              children: [
                Text(
                  'LEVEL',
                  style: TextStyle(
                    color: Colors.orange[500],
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(width: 10,),
                ClipPath(
                  clipper: HexagonClipper(),
                  child: Container(
                    width: 30,
                    height: 25,
                    color: Colors.orange[400],
                    child: Center(
                      child: Text(
                        level.toString(), 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600
                        ),
                        ),
                    ),
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$exp/300',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800
                        ),
                      ),
                      LinearProgressIndicator(
                        value: exp/300,
                        minHeight: 7,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade300),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10,),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: Workouts.length,
              itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10,5,10,5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context, MaterialPageRoute(
                            builder: (context) => StartWorkoutPage(
                              workout: Workouts[index],
                              pic: gender+index.toString(),
                            )
                          )
                        );
                      },
                      child: Container(
                        height: 125.0,
                        width: double.infinity,
                        decoration: (gender != '') ? BoxDecoration(
                          image: DecorationImage(image: AssetImage('assets/images/${gender+index.toString()}.jpeg'),
                          fit: BoxFit.fitWidth,
                          )
                        ) : BoxDecoration(color: Colors.grey[800]),
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0,5,10,5),
                                child: 
                                prev[Workouts[index]]!.length > 3 ?
                                  Text(
                                    'Last: ${prev[Workouts[index]]!.split(' ')[0]} ${prev[Workouts[index]]!.split(' ')[1]}',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 220, 71, 71),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 22.0
                                      ),
                                    ) : Text(''),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10,10,0,0),
                                child: Text(
                                  Workouts[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26.0
                                    ),
                                  ),
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              ),
          ),
          Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Column(
                    mainAxisSize: MainAxisSize.max, 
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        color: Colors.blue,
                        size: 35,
                      ),
                      Text(
                        'Training',
                        style: TextStyle(fontSize: 13,color: Colors.blue),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage()));
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.max, 
                    children: [
                      Icon(
                        Icons.list_alt,
                        color: Colors.grey,
                        size: 35,
                      ),
                      Text(
                        'History',
                        style: TextStyle(fontSize: 13,color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if(startDate == '')
                    {
                      return ;
                    }
                    Navigator.pushReplacement(
                      context, 
                      PageRouteBuilder(
                        pageBuilder: (context,animation,secondaryAnimation) => UserPage(startDate: startDate,),
                        transitionsBuilder: (context,animation,secondaryAnimation,child){
                            const begin = Offset(1.0,0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            
                            var tween = Tween(begin: begin,end: end).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                        }
                      ),
                    );
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.max, 
                    children: [
                      Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.grey
                      ),
                      Text(
                        'Profile',
                        style: TextStyle(fontSize: 13, color:Colors.grey),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}