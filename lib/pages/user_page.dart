import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness/pages/history_page.dart';
import 'package:fitness/pages/home_page.dart';
import 'package:fitness/pages/login_page.dart';
import 'package:fitness/pages/workout_settings.dart';
import 'package:fitness/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class UserPage extends StatefulWidget {
  final String startDate;
  const UserPage({super.key, required this.startDate});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  
  final CollectionReference bioCollection = FirebaseFirestore.instance.collection('bio');
  final CollectionReference feedbackCollection = FirebaseFirestore.instance.collection('feedback');
  final textControlller = TextEditingController();
  final feedback = TextEditingController();
  bool isTextEnabled = false;
  FocusNode userFocusNode = FocusNode();
  FocusNode feedbackNode = FocusNode();

  final FirebaseAuth auth = FirebaseAuth.instance;


  User? user;
  String? username;
  bool canSubmit = false;

  List<String> history = [];
  List<DateTime> dates = [];
  Map<DateTime, List<String>> workoutDays = {};

  bool viewingPast = false, canChange = false, canWeight = false, canHeight = false;

  final weightController = TextEditingController();
  final cmController = TextEditingController();
  final ftController = TextEditingController();
  final inchController = TextEditingController();


  String wtUnit = 'kg', htUnit = 'cm';
  String? cm,ft,inch,kg,pd; // pardon, pd == lb, "pounds"
  double bmi = 0.0;
  Color? color;

  bool bmiDescrip = false;

  String? hours, minutes, calories;
  List<String>? totalTime;

  late String starDate;
  
  @override
  void initState() {
    super.initState();
    starDate = widget.startDate;
    getHeight();
    getWeight();
    getCurrentUsername();
    getProfilePic();
    userFocusNode.addListener((){
      setState(() {
        canChange = userFocusNode.hasFocus;
      });
    });
    feedbackNode.addListener((){
      setState(() {
        canSubmit = feedbackNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    textControlller.dispose();
    feedback.dispose();
    userFocusNode.dispose();
    feedbackNode.dispose();
    weightController.dispose();
    cmController.dispose();
    inchController.dispose();
    ftController.dispose();
    super.dispose();
  }

  void calculateBmi(){
    if(kg!=null && cm!=null)
    {
      setState(() {
          bmi = (int.parse(kg!)/((int.parse(cm!)/100)*(int.parse(cm!)/100)));    
      });
      if(bmi<18.5){
        setState(() {
          color = Colors.blue[200];
        });
      }
      else if(bmi<25){
        setState(() {
          color = Colors.green;
        });
      }
      else if(bmi < 30){
        setState(() {
          color = Colors.yellow[300];
        });
      }
      else{
        setState(() {
          color = Colors.red[300];
        });
      }
    }
    else
    { 
      return;
    }
  }

  void getHeight() async{
    user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot doc = await bioCollection.doc(user!.email).get();
    setState(() {
      cm = doc['cm'].toString().substring(0,3);
      ft = doc['ft'].toString();
      inch = doc['inch'].toString();
    });
    calculateBmi();
  }

  void getWeight() async{
    user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot doc = await bioCollection.doc(user!.email).get();
    setState(() {
      kg = doc['kg'].toString();
      pd = doc['pd'].toString().substring(0,3);
    });
    calculateBmi();
  }

  void getCurrentUsername() async {
      user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot doc = await bioCollection.doc(user!.email).get();
      totalTime = doc['totalTime'].split(':');
      setState(() {
        username = doc['Username'];
        calories = doc['calories'].toString();
        hours = totalTime![0];
        minutes = totalTime![1];
      });
      setState((){
        history = List<String>.from(doc['past']);
      });
      DateFormat dateFormat = DateFormat('MMM d yyyy');
      for(var i=0;i<history.length;i++){
        DateTime parsedDate = dateFormat.parse(history[i].split('-')[1]);
        DateTime normalizedDate = _normalizeDate(parsedDate);
        setState(() {
          workoutDays[normalizedDate] = ['workout'];
        });
      }
  }

  DateTime _normalizeDate(DateTime date){
    return DateTime.utc(date.year, date.month, date.day);
  }

  void updateUsername() async {
      await bioCollection.doc(user!.email).update({'Username':textControlller.text.toUpperCase()});
      DocumentSnapshot doc = await bioCollection.doc(user!.email).get();
      setState(() {
        username = doc['Username'];
        isTextEnabled = false;
      });
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SUCCESS',
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                      ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Username Changed!',
                    style: TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.grey[800],fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Future<void> submitFeedback()async{
    await feedbackCollection.doc(user!.email).set({
      'feedback' : FieldValue.arrayUnion([feedback.text])
    },SetOptions(merge: true));
    feedback.clear();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SUCESS',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                    ),
                ),
                SizedBox(height: 20),
                Text(
                  'FEEDBACK SUBMITTED',
                  style: TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.grey[800],fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveWeight()async{
    if(wtUnit == 'kg'){
      int kg = int.parse(weightController.text);
      if(kg < 200 && kg > 40){
        await bioCollection.doc(user!.email).update({
            'kg' : kg,
            'pd' : kg * 2.2
          });
        getWeight();   
      }
      else
      {
        weightController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'WEIGHT INVALID!',
              style: TextStyle(fontWeight: FontWeight.bold),
              ),
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    }
    else{
      int lb = int.parse(weightController.text);
      if(lb < 440)
      {
        await bioCollection.doc(user!.email).update({
            'kg' : lb * 0.45,
            'pd' : lb
          });
        getWeight(); 
      }
      else
      {
        weightController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'WEIGHT INVALID!',
              style: TextStyle(fontWeight: FontWeight.bold),
              ),
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    }
    setState(() {
      canWeight = false;
    });
    weightController.clear();
  }

    Future<void> saveHeight()async{
    if(htUnit == 'cm'){
      int cm = int.parse(cmController.text);
      if(cm<240 && cm > 120)
      {
        await bioCollection.doc(user!.email).update({
            'cm' : cm,
            'ft' : (cm / 30.48).toInt(),
            'inch' : ((cm / 2.54)%12).toInt(),
          });
        getHeight();
      }
      else
      {
        cmController.clear();
        ftController.clear();
        inchController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'HEIGHT INVALID!',
              style: TextStyle(fontWeight: FontWeight.bold),
              ),
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    }
    else{
      int ft = int.parse(ftController.text);
      int inch = int.parse(inchController.text);
      if(ft < 8 && inch < 12 && ft > 3)
      {
        await bioCollection.doc(user!.email).update({
            'ft' : int.parse(ftController.text),
            'inch' : int.parse(inchController.text),
            'cm' : (int.parse(ftController.text)*12 + int.parse(inchController.text))*2.54,
          });
        getHeight();
      }
      else
      {
        ftController.clear();
        inchController.clear();
        cmController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'HEIGHT INVALID!',
              style: TextStyle(fontWeight: FontWeight.bold),
              ),
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    }
    setState(() {
      canHeight = false;
    });
    cmController.clear();
    ftController.clear();
    inchController.clear();
  }

  File? image;
  String? picUrl;

  void getProfilePic()async{
    try{
      picUrl = await FirebaseStorage.instance.ref('profile').child(user!.email!).getDownloadURL();
      setState(() {
        picUrl = picUrl;
      });
    } on FirebaseException catch(e){
      print(e.toString());
    }
    catch(e){
      print('error fetching image $e');
    }
  }

  Future<void>pickImage()async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if(pickedFile != null)
      {
        setState(() {
          image = File(pickedFile.path);
        });
        try{
          await FirebaseStorage.instance.ref('profile').child(user!.email!).putFile(image!);
        }catch(e){ print('error uploading file $e');}
      }
      else{
        print('NO IMAGE SELECTED');
      }
  }

  List<String> times = [
    "00:00", "00:30", "01:00", "01:30", "02:00", "02:30", 
    "03:00", "03:30", "04:00", "04:30", "05:00", "05:30", 
    "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", 
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", 
    "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", 
    "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", 
    "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", 
    "21:00", "21:30", "22:00", "22:30", "23:00", "23:30"
  ];

  String selectedTime = '';
  String selectedWorkout = '';

  List<String> workouts = ['ABS','CHEST','ARMS','LEGS','SHOULDERS & BACK', 'YOGA'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(isTextEnabled)
        {
          setState(() {
            isTextEnabled = false;
          });
          textControlller.clear();
          // userFocusNode.unfocus();
        }
        else if(feedbackNode.hasFocus)
        {
          setState(() {
            feedbackNode.unfocus();
          });
        }
        else if(canWeight)
        {
          setState(() {
            canWeight = false;
          });
          weightController.clear();
        }
        else if(canHeight)
        {
          setState(() {
            canHeight = false;
          });
          cmController.clear();
          ftController.clear();
          inchController.clear();
        }
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          // backgroundColor: Colors.grey[350],
          backgroundColor: Color(0xff101480),
          // backgroundColor: Color(0xff003865), //tardis blue
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Text('USER PROFILE' ,style:GoogleFonts.roboto(fontSize: 20, color: Colors.white)),
          ),
        ),
        
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle
                        ),
                        // padding: const EdgeInsets.all(16.0),
                        child:
                        Stack(
                          children: [
                              if(image == null && picUrl == null) 
                              Icon(
                                Icons.person_2_rounded,
                                size: 140,
                                color: Colors.white,
                              ) 
                              else if(image != null) ClipOval(
                                child: Container(
                                  height: 140,
                                  width: 140,
                                  child: Image.file(
                                    image!, 
                                    fit: BoxFit.cover,
                                    )
                                  ),
                              )
                              else ClipOval(
                                  child: Container(
                                    height: 140,
                                    width: 140,
                                    child: Image.network(
                                      picUrl!, 
                                      fit: BoxFit.cover,
                                      )
                                    ),
                                ),
                              if(isTextEnabled || picUrl==null)
                                Positioned(
                                  bottom: -12,
                                  right: 0,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.camera_alt,
                                      size: 30),
                                    onPressed: (){
                                      pickImage();
                                    },
                                  )
                                )
                            ]
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 50,),
                        Container(
                          width: 200,
                          child: TextField(
                            controller: textControlller,
                            enabled: isTextEnabled,
                            obscureText: false,
                            focusNode: userFocusNode,
                            decoration: InputDecoration(
                              hintText: username,
                              hintStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          onPressed: (){
                            canWeight = canHeight = false;
                            setState(() {
                              isTextEnabled = !isTextEnabled;
                            });
                          }, 
                          icon: const Icon(Icons.edit)
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    canChange ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ElevatedButton(
                        onPressed: (){
                          if(textControlller.text.length > 10)
                          {
                            showDialog(
                              context: context,
                              builder: (ctx) => Dialog(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue, Colors.purple],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'WARNING',
                                          style: TextStyle(
                                            color: Colors.white, 
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                            ),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          'Maximum of 10 Characters',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
                                        ),
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Close',
                                            style: TextStyle(color: Colors.grey[800],fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          else if(textControlller.text.toUpperCase() == username)
                          {
                            showDialog(
                              context: context,
                              builder: (ctx) => Dialog(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue, Colors.purple],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'WARNING',
                                          style: TextStyle(
                                            color: Colors.white, 
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                            ),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          'New username matches with the old username',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
                                        ),
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Close',
                                            style: TextStyle(color: Colors.grey[800],fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          else if(textControlller.text.length < 3)
                          {
                            showDialog(
                              context: context,
                              builder: (ctx) => Dialog(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue, Colors.purple],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'WARNING',
                                          style: TextStyle(
                                            color: Colors.white, 
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                            ),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          'Too Short!',
                                          style: TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Close',
                                            style: TextStyle(color: Colors.grey[800],fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          else
                          {
                            updateUsername();
                          }
                        },
                        style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                    const Color.fromRGBO(73, 171, 76, 1),
                                  ),
                                ),
                        child: const Text('SAVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        ),
                      )) 
                      : const SizedBox(height: 20,),
                    
                    const SizedBox(height: 10),

                   Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32), 
                        child: Container(
                          color: Colors.grey[200], 
                          height: 140,
                          child: (kg != null && kg != '') ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: 120,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 6,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(8), 
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    (hours != '00' && hours != '0') ?
                                    Text(
                                      '${hours}H ${minutes}M',
                                      style: GoogleFonts.abyssinicaSil(
                                        color: Colors.purple[800],
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ) :
                                    Text(
                                      '${minutes}M',
                                      style: GoogleFonts.abyssinicaSil(
                                        color: Colors.purple[800],
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ) 
                                    ,
                                    SizedBox(height: 4,),
                                    Icon(Icons.timelapse, color: Colors.purple.shade900, size:25)
                                  ],
                                ),
                              ),
                              Container(
                                width: 120,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 6,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(8), 
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$calories cal',
                                      style: GoogleFonts.abyssinicaSil(
                                        color: Colors.orange[800],
                                        fontSize: 21,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4,),
                                    SizedBox(
                                      height: 20,
                                      child: Image.asset('assets/images/fire.png')
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ) 
                          : 
                          Center(
                            child: 
                            Text(
                              'UPDATE YOUR HEIGHT, WEIGHT AND THEN WORKOUT', 
                              textAlign: TextAlign.center,
                              style:  TextStyle(fontWeight: FontWeight.bold)
                              )
                            ),
                        ),
                      ),
                    ),

                    
                    const SizedBox(height: 20),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                      child: TableCalendar(
                        // firstDay: DateTime.utc(2024,7,1),
                        firstDay: DateTime.utc(int.parse(starDate.split('-')[0]),int.parse(starDate.split('-')[1]),int.parse(starDate.split('-')[2])),
                        lastDay: DateTime.now().add(Duration(days: 10)),
                        focusedDay: DateTime.now(),
                        calendarFormat: CalendarFormat.twoWeeks,
                        availableCalendarFormats: const {CalendarFormat.twoWeeks : ''},
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context,day,focusedDay){
                            if(workoutDays[day] != null){
                              return Container(
                                margin: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    day.day.toString(),
                                    style: TextStyle(color: Colors.white),
                                    ),
                                ),
                              );
                            }
                            else
                            {
                              return null;
                            }
                          },
                        ),
                        onDaySelected: (selectedDay,focusedDay){
                          if(selectedDay.isAfter(DateTime.now()))
                          {
                            showModalBottomSheet(
                              context: context, 
                              builder: (context){
                                return StatefulBuilder(
                                  builder: (BuildContext context,StateSetter setModalState){
                                  return SizedBox(
                                    height: 330,
                                    child: Column(
                                      children: [
                                        AppBar(
                                          automaticallyImplyLeading: false,
                                          title: Center(
                                            child: Text(
                                              'SET REMINDER',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ),
                                          actions: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: ElevatedButton(
                                                onPressed: (){
                                                  if(selectedTime.length != 0 && selectedWorkout.length != 0){
                                                    AwesomeNotifications().createNotification(
                                                      content: NotificationContent(
                                                        id: 1, 
                                                        channelKey: 'basic_channel',
                                                        title: 'WORKOUT REMINDER',
                                                        body: selectedWorkout,
                                                        notificationLayout: NotificationLayout.Default,
                                                        ),
                                                        schedule: NotificationCalendar(
                                                          year: 2024,
                                                          month: selectedDay.month,
                                                          day: selectedDay.day,
                                                          hour: int.parse(selectedTime.split(':')[0]),
                                                          minute: int.parse(selectedTime.split(':')[1]),
                                                          second: 0,
                                                          millisecond: 0,
                                                          preciseAlarm: true,
                                                          repeats: true
                                                        )
                                                      );
                                                      Navigator.pop(context);
                                                    }
                                                    // Navigator.pop(context);
                                                  }, 
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green
                                                  ),
                                                child: Text(
                                                  'SET',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16
                                                  ),
                                                  )
                                                ),
                                            )
                                          ],
                                          ),
                                        SizedBox(height: 15,),
                                        Text(
                                          DateFormat('MMM d').format(selectedDay),
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        SizedBox(height: 20,),
                                        Container(
                                          height: 50,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: times.length,
                                            itemBuilder: (context,index){
                                              return GestureDetector(
                                                onTap: (){
                                                  setModalState(() {
                                                    selectedTime = times[index];
                                                  });
                                                },
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(14),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                                    color: selectedTime == times[index] ? Colors.blue : Colors.transparent,
                                                    child: Center(
                                                      child: Text(
                                                        times[index],
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: selectedTime == times[index] ? Colors.white : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          ),
                                        ),
                                        SizedBox(height: 20,),
                                        Container(
                                          height: 50,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: workouts.length,
                                            itemBuilder: (context,index){
                                              return GestureDetector(
                                                onTap: (){
                                                  setModalState(() {
                                                    selectedWorkout = workouts[index];
                                                  });
                                                },
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(14),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                                    color: selectedWorkout == workouts[index] ? Colors.blue : Colors.transparent,
                                                    child: Center(
                                                      child: Text(
                                                        workouts[index],
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: selectedWorkout == workouts[index] ? Colors.white : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(context),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(30.0),
                                              child: Container(
                                                height: 60,
                                                color: const Color.fromARGB(255, 137, 36, 29),
                                                child: const Center(
                                                  child: Text(
                                                    'CLOSE', style: const TextStyle(
                                                      color: Colors.white, fontWeight: FontWeight.bold,fontSize: 22
                                                      ),
                                                    )
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              );
                              }
                            );
                          }
                        },
                      ),
                    ),
                    
                    SizedBox(height: 20,),


                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.black, width:3),
                            borderRadius: BorderRadius.circular(24)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Expanded(child: Text('WEIGHT', textAlign: TextAlign.center,)),
                              IconButton(
                                onPressed: (){
                                  if(wtUnit == 'kg')
                                  {
                                    setState(() {
                                      wtUnit = 'lb';
                                    });
                                  }
                                  else
                                  {
                                    setState(() {
                                      wtUnit = 'kg';
                                    });
                                  }
                                }, 
                                icon: const Icon(Icons.change_circle_outlined)
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: Text(wtUnit),
                              ),
                              SizedBox(
                                width: 45,
                                height: 40,
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  controller: weightController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  enabled: canWeight,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    hintText: wtUnit == 'kg' ? kg : pd,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: (){
                                  isTextEnabled = canHeight = false;
                                  setState(() {
                                    canWeight = !canWeight;                                  
                                  });
                                }, 
                                icon: const Icon(Icons.edit, size: 15,)
                              ),
                              Visibility(
                                visible: canWeight,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: ElevatedButton(
                                  onPressed: (){
                                    saveWeight();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(73, 171, 76, 1), 
                                    minimumSize: const Size(50, 25),
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                child: const Text(
                                  'SAVE',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white
                                    ),
                                ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.black, width:3),
                            borderRadius: BorderRadius.circular(24)
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Expanded(child: const Text('HEIGHT', textAlign: TextAlign.center,)),
                              IconButton(
                                onPressed: (){
                                  if(htUnit == 'cm')
                                  {
                                    setState(() {
                                      htUnit = 'ft';
                                    });
                                  }
                                  else
                                  {
                                    setState(() {
                                      htUnit = 'cm';
                                    });
                                  }
                                }, 
                                icon: const Icon(Icons.change_circle_outlined)
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: Text(htUnit),
                              ),
                              if(htUnit == 'cm')
                              Container(
                                width: 45,
                                height: 40,
                                child: TextField(
                                  controller: cmController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  enabled: canHeight,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    hintText: cm,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                  ),
                                ),
                              ),
                              if(htUnit == 'ft')
                                Row(
                                  children: [
                                    Container(
                                      width: 35,
                                      height: 40,
                                      child: TextField(
                                        controller: ftController,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        enabled: canHeight,
                                        decoration: InputDecoration(
                                          labelText: 'ft',
                                          border: const OutlineInputBorder(),
                                          hintText: ft,
                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                          contentPadding:
                                              const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 35,
                                      height: 40,
                                      child: TextField(
                                        controller: inchController,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        enabled: canHeight,
                                        decoration: InputDecoration(
                                          labelText: 'in',
                                          hintText: inch,
                                          border: const OutlineInputBorder(),
                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                          contentPadding:
                                              const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              IconButton(
                                onPressed: (){
                                  isTextEnabled = canWeight = false;
                                  setState(() {
                                    canHeight = !canHeight;                                  
                                  });
                                }, 
                                icon: const Icon(Icons.edit, size:15)
                              ),
                              Visibility(
                                visible: canHeight,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: ElevatedButton(
                                  onPressed: (){
                                    saveHeight();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(73, 171, 76, 1), 
                                    minimumSize: const Size(50,25),
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                child: const Text(
                                  'SAVE',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white
                                    ),
                                ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if(bmi!=0.0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8,8,8,2),
                      child: Container(
                        color: Colors.grey[300],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('BMI : '),        
                                Text(bmi.toString().substring(0,5)),
                                const SizedBox(width: 5,),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 40,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: color,
                                      border: Border.all(color: Colors.black)
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: (){
                                    setState(() {
                                     bmiDescrip = !bmiDescrip;                                   
                                    });
                                    }, 
                                  icon: bmiDescrip ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down),
                                  ),
                              ],
                            ),
                            if(bmiDescrip)
                            Column(
                              children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Underweight < 18.5\t'),
                                Padding(
                                  padding: const EdgeInsets.only(left:22.0),
                                  child: Container(
                                    width: 40,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.blue[200],
                                        border: Border.all(color: Colors.black)
                                      ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Normal 18.5 - 24.9\t\t'),
                                Padding(
                                  padding: const EdgeInsets.only(left:22.0),
                                  child: Container(
                                    width: 40,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        border: Border.all(color: Colors.black)
                                      ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Overweight 25 - 29.9\t\t\t'),
                                Container(
                                  width: 40,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: Colors.yellow[300],
                                      border: Border.all(color: Colors.black)
                                    ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Obese > 30'),
                                Padding(
                                  padding: const EdgeInsets.only(left: 80.0),
                                  child: Container(
                                    width: 40,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.red[300],
                                        border: Border.all(color: Colors.black)
                                      ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10,),
                              ]
                            ),
                          ],
                        ),
                      ),
                    ),


                    const SizedBox(height: 8,),
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(8,2,8,8),
                    //   child: Container(
                    //     color: Colors.grey[200],
                    //     child: Column(
                    //       children: [
                    //         Row(
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             const Text('PAST EXERCISES'),
                    //             IconButton(
                    //               onPressed: (){
                    //                 setState(() {
                    //                   viewingPast = !viewingPast;
                    //                 });
                    //               }, icon: viewingPast ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down)
                    //               ),
                    //           ],
                    //         ),
                    //         if(viewingPast)
                    //           SizedBox(
                    //             height: MediaQuery.of(context).size.height*0.15,
                    //             child: ListView.builder(
                    //               // shrinkWrap: true,
                    //               itemCount: history.length,
                    //               itemBuilder: (context,index){
                    //                 return Container(
                    //                   padding: const EdgeInsets.all(4),
                    //                   // color: Colors.grey[200],
                    //                   decoration: BoxDecoration(
                    //                     border: BorderDirectional(
                    //                       start: const BorderSide(color: Colors.black87,width: 2),
                    //                       end: const BorderSide(color: Colors.black87, width: 2),
                    //                       bottom: BorderSide(
                    //                         color: Colors.black87, 
                    //                         width: index != history.length -1 ? 1 : 2,
                    //                         ),
                    //                       top: BorderSide(
                    //                         color: Colors.black, 
                    //                         width: index == 0 ? 2 : 1,
                    //                         ),
                    //                       ),
                    //                   ),
                    //                   child: Center(child: Text(history[history.length -1 - index]+' mins'))
                    //                 );
                    //               }
                    //             ),
                    //           ) 
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          color: Colors.amber,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.settings),
                              Text('WORKOUT SETTINGS'),
                              IconButton(
                                onPressed: (){
                                  Navigator.push(context,MaterialPageRoute(builder: (context) => WorkoutSettings()));
                                }, 
                                icon: Icon(Icons.arrow_right_rounded, size:35)
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: TextField(
                          controller: feedback,
                          maxLines: 3,
                          focusNode: feedbackNode,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: 'Please provide us with your invaluable feedback or any feature you would like us to add ... min(20 characters)',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                      
                   if(canSubmit) TextButton(
                      onPressed: () async {
                        if(feedback.text.length < 20)
                        {
                          return;
                        }
                        await submitFeedback();
                      }, 
                      child: const Text(
                        'SUBMIT', 
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16
                          ),
                        )
                      ),
                      
              
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: ElevatedButton(
                        onPressed: ()async{
                          await auth.signOut();
                          await StorageService.clearEmail();
                          await StorageService.clearPassword();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, 
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      child: const Text(
                        'LOGOUT',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                          ),
                      ),
                      ),
                    ),
                  ],
                ),
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
                    onPressed: () {
                      Navigator.pushReplacement(
                        context, 
                        PageRouteBuilder(
                          pageBuilder: (context,animation,secondaryAnimation) => const HomePage(),
                          transitionsBuilder: (context,animation,secondaryAnimation,child){
                              const begin = Offset(-1.0,0.0);
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
                          Icons.timer_rounded,
                          color: Colors.grey,
                          size: 35,
                        ),
                        Text(
                          'Training',
                          style: TextStyle(fontSize: 13,color: Colors.grey),
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
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.max, 
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.blue,
                          size: 35,
                        ),
                        Text(
                          'Profile',
                          style: TextStyle(fontSize: 13, color:Colors.blue),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}