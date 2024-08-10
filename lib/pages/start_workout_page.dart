import 'dart:async';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness/pages/starting.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';

class StartWorkoutPage extends StatefulWidget {
  final String workout;
  final String pic;
  const StartWorkoutPage({super.key, required this.workout, required this.pic});

  @override
  State<StartWorkoutPage> createState() => _StartWorkoutPageState();
}

class _StartWorkoutPageState extends State<StartWorkoutPage> {

  int meditate = 15;

  final CollectionReference preferenceCollection = FirebaseFirestore.instance.collection('preferences');

  final List<String> exercisesSHOULDERBACK = [
                                'JUMPING JACKS','ARM RAISES', 'RHOMBOID PULLS',
                                'SIDE ARM RAISE','KNEE PUSH-UPS','SIDE-LYING FLOOR STRETCH LEFT',
                                'SIDE-LYING FLOOR STRETCH RIGHT','ARM SCISSORS','RHOMBOID PULLS',
                                'SIDE ARM RAISE', 'KNEE PUSH-UPS', 'CAT COW POSE', 'PRONE TRICEPS PUSH UPS',
                                'RECLINED RHOMBOID SQUEEZES','PRONE TRICEPS PUSH UPS','RECLINED RHOMBOID SQUEEZES',
                                'CHILD\'S POSE'
                                ];

  List<String> exercises = [];

  final List<String> exercisesLEG = [
                                'SIDE HOP', 'SQUATS', 'SQUATS', 'SIDE-LYING LEG LIFT LEFT', 'SIDE-LYING LEG LIFT RIGHT',
                                'SIDE-LYING LEG LIFT LEFT', 'SIDE-LYING LEG LIFT RIGHT', 'BACKWARD LUNGE', 'BACKWARD LUNGE',
                                'DONKEY KICKS LEFT', 'DONKEY KICKS RIGHT', 'DONKEY KICKS LEFT', 'DONKEY KICKS RIGHT',
                                'LEFT QUAD STRETCH WITH WALL', 'RIGHT QUAD STRETCH WITH WALL', 'KNEE TO CHEST STRETCH LEFT',
                                'KNEE TO CHEST STRETCH RIGHT', 'WALL CALF RAISES', 'WALL CALF RAISES', 'SUMO SQUAT CALF RAISES WITH WALL',
                                'SUMO SQUAT CALF RAISES WITH WALL', 'CALF STRETCH LEFT', 'CALF STRETCH RIGHT',
                                ];
  
  final List<String> exercisesARM = [
                                'SIDE ARM RAISE', 'ARM RAISES', 'TRICEPS DIPS', 'ARM CIRCLES CLOCKWISE',
                                'ARM CIRCLES COUNTERCLOCKWISE', 'DIAMOND PUSH-UPS', 'JUMPING JACKS', 'CHEST PRESS PULSE',
                                'LEG BARBELL CURL LEFT', 'LEG BARBELL CURL RIGHT', 'DIAGONAL PLANK', 'PUNCHES', 'PUSH-UPS',
                                'INCHWORMS', 'WALL PUSH-UPS', 'TRICEPS STRETCH LEFT', 'TRICEPS STRETCH RIGHT',
                                'STANDING BICEPS STRETCH LEFT', 'STANDING BICEPS STRETCH RIGHT',
                                ];
  
  final List<String> exercisesCHEST = [
                                'JUMPING JACKS', 'INCLINE PUSH-UPS', 'PUSH-UPS', 'WIDE ARM PUSH-UPS',
                                'TRICEPS DIPS',  'WIDE ARM PUSH-UPS', 'INCLINE PUSH-UPS', 'TRICEPS DIPS',
                                'KNEE PUSH-UPS', 'COBRA STRETCH', 'CHEST STRETCH' 
                                ];
  

  final List<String> exercisesABS = [
      'JUMPING JACKS', 'ABDOMINAL CRUNCHES', 'RUSSIAN TWIST', 'MOUNTAIN CLIMBER',
      'HEEL TOUCH', 'LEG RAISES', 'PLANK', 'ABDOMINAL CRUNCHES', 'RUSSIAN TWIST',
      'MOUNTAIN CLIMBER', 'HEEL TOUCH', 'LEG RAISES','PLANK', 'COBRA STRETCH',
      'SPINE LUMBAR TWIST STRETCH LEFT', 'SPINE LUMBAR TWIST STRETCH RIGHT'
  ];

  Map<String, String> durations = {
    'JUMPING JACKS' : '00:40',
    'ARM RAISES' : '00:20',
    'RHOMBOID PULLS' : 'x14',
    'KNEE PUSH-UPS' : 'x14',
    'SIDE ARM RAISE' : '00:20',
    'ARM SCISSORS' : '00:30',
    'SIDE-LYING FLOOR STRETCH LEFT': '00:30',
    'SIDE-LYING FLOOR STRETCH RIGHT' : '00:30',
    'CAT COW POSE': '00:30',
    'PRONE TRICEPS PUSH UPS': 'x14',
    'RECLINED RHOMBOID SQUEEZES': 'x12',
    'CHILD\'S POSE': '00:30',
    'ABDOMINAL CRUNCHES' : 'x16',
    'RUSSIAN TWIST' : 'x20',
    'MOUNTAIN CLIMBER' : 'x16',
    'HEEL TOUCH' : 'x20', 
    'LEG RAISES' : 'x16', 
    'PLANK' : '00:30',
    'COBRA STRETCH' : '00:30',
    'SPINE LUMBAR TWIST STRETCH LEFT' : '00:30', 
    'SPINE LUMBAR TWIST STRETCH RIGHT' : '00:30',
    'INCLINE PUSH-UPS' : 'x6', 
    'PUSH-UPS' : 'x10', 
    'WIDE ARM PUSH-UPS' : 'x6',
    'TRICEPS DIPS' : 'x10',
    'CHEST STRETCH' : '00:40',
    'ARM CIRCLES CLOCKWISE' : '00:30',
    'ARM CIRCLES COUNTERCLOCKWISE' : '00:30', 
    'DIAMOND PUSH-UPS' : 'x6',
    'CHEST PRESS PULSE' : '00:20',
    'LEG BARBELL CURL LEFT' : 'x8', 
    'LEG BARBELL CURL RIGHT' : 'x8', 
    'DIAGONAL PLANK' : 'x10', 
    'PUNCHES' : '00:30', 
    'INCHWORMS' : 'x8', 
    'WALL PUSH-UPS' : 'x12', 
    'TRICEPS STRETCH LEFT' : '00:30', 
    'TRICEPS STRETCH RIGHT' : '00:30',
    'STANDING BICEPS STRETCH LEFT' : '00:30', 
    'STANDING BICEPS STRETCH RIGHT' : '00:30',
    'SIDE HOP' : '00:30', 
    'SQUATS' : 'x12',
    'SIDE-LYING LEG LIFT LEFT' : 'x12', 
    'SIDE-LYING LEG LIFT RIGHT' : 'x12',
    'BACKWARD LUNGE' : 'x14',
    'DONKEY KICKS LEFT' : 'x16', 
    'DONKEY KICKS RIGHT' : 'x16',
    'LEFT QUAD STRETCH WITH WALL' : '00:30', 
    'RIGHT QUAD STRETCH WITH WALL' : '00:30', 
    'KNEE TO CHEST STRETCH LEFT' : '00:30',
    'KNEE TO CHEST STRETCH RIGHT' : '00:30', 
    'WALL CALF RAISES' : 'x12',
    'SUMO SQUAT CALF RAISES WITH WALL' : 'x12',
    'CALF STRETCH LEFT' : '00:30', 
    'CALF STRETCH RIGHT' : '00:30',
    'MEDITATION': 'x3'
  };
  
  CustomVideoPlayerController? _customVideoPlayerController;
  VideoPlayerController? _videoPlayerController;
  late String videoUrl;

  final CollectionReference exerciseCollection = FirebaseFirestore.instance.collection('exercises');

  late String instructions;
  Map<String,String> mistakes = {};
  List<String> breathing = [];
  List<String> focus = [];
  bool isVideoLoading = true, isInstructionLoading = true;
  late int i = 0;
  bool visible = false;
  late int number, duration;

  Map<String,String> changed = {};
  User? user = FirebaseAuth.instance.currentUser;


  @override
  void initState() {
    super.initState();
    getList();
    loadPrefs();
  }

  void loadPrefs()async{
    DocumentSnapshot doc = await preferenceCollection.doc(user!.email).get();
    changed = Map<String,String>.from(doc['prefs']);
    setState(() {
      changed.forEach((key,value){
        durations[key] = value;
      });
    });
  }

  void getList(){
    if(widget.workout == 'ABS')
    {
      exercises = exercisesABS;
    }
    else if(widget.workout == 'CHEST')
    {
      exercises = exercisesCHEST;
    }
    else if(widget.workout == 'ARMS')
    {
      exercises = exercisesARM;
    }
    else if(widget.workout == 'LEGS')
    {
      exercises = exercisesLEG;
    }
    else if(widget.workout == 'SHOULDERS & BACK')
    {
      exercises = exercisesSHOULDERBACK;
    }
    else
    {
      exercises = ['MEDITATION'];
    }
    number = exercises.length;
    duration = 24*(number-1);
    for(int i=0;i<number;i++)
    {
      if(!durations[exercises[i]]!.startsWith('x'))
      {
        duration += int.parse(durations[exercises[i]]!.split(':')[0])*60 + int.parse(durations[exercises[i]]!.split(':')[1]);
      }
      else
      {
        duration += 7*(int.parse(durations[exercises[i]]!.split('x')[1]));
      }
    }
    duration = (duration ~/ 60) + 3;
  }

  Future<void> fetchVideo(String name, StateSetter setModalState) async {
    try {
      videoUrl = await FirebaseStorage.instance.ref('$name.mp4').getDownloadURL();

      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))..initialize()
        .then((_) {
          setModalState((){
            _customVideoPlayerController = CustomVideoPlayerController(
              context: context, 
              videoPlayerController: _videoPlayerController!
              );
            isVideoLoading = false;

          });
        });
      // _customVideoPlayerController = CustomVideoPlayerController(
      // context: context, 
      // videoPlayerController: _videoPlayerController
      // );
    } catch (e) {
      print('Error fetching video: $e');
    }
  }

  Future<void> fetchInstruction(String exerciseName, StateSetter setModalState) async{
    DocumentSnapshot doc = await exerciseCollection.doc(exerciseName).get();
    setModalState((){
          instructions = doc['instruction'];
          instructions = instructions.replaceAll('\\n', '\n\n');
          mistakes = Map<String,String>.from(doc['mistakes']);
          breathing = List<String>.from(doc['breathing']);
          focus = List<String>.from(doc['focus']);
          isInstructionLoading = false;
    });
  }


  void videoClose(){
    _videoPlayerController!.pause();
  }

  @override
  void dispose() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }
    if (_customVideoPlayerController != null) {
      _customVideoPlayerController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.workout}' ,style:GoogleFonts.montserrat(fontWeight: FontWeight.bold,fontSize: 28),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/${widget.pic}.jpeg'),
              fit: BoxFit.fitWidth
              )
            ),
          ),
          widget.workout != 'YOGA' ?
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.0,10.0,0,5),
              child: Text(
                '${duration} MINS • ${number} EXERCISES',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.blue
                  ),
                ),
            )
          ) : Container(
            height: 100,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'DURATION:',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500
                  ),
                  ),
                Visibility(
                  visible: visible,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Container(
                    width: 50,
                    child: NumberPicker(
                      value: meditate,
                      minValue: 5,
                      maxValue: 59,
                      onChanged: (value) => setState(()=> meditate = value),
                    ),
                  ),
                ),
                Container(
                  height: 60,
                  width: 45,
                  child: TextFormField(
                    controller: TextEditingController(text: meditate.toString()),
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  onPressed: (){
                    setState(() {
                      visible = !visible;
                    }); 
                  }, 
                  icon: Icon(Icons.change_circle_outlined, size: 40,)
                  ),
                
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context,index){
              return Padding(
                padding: const EdgeInsets.fromLTRB(3,3,3,1),
                child: Container(
                  color: Colors.amber[100],
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height:10),
                            Text(exercises[index], style: GoogleFonts.roboto(fontSize: 17, fontWeight: FontWeight.w500),),
                            Text(durations[exercises[index]]!, style: GoogleFonts.roboto(fontSize: 17, fontWeight: FontWeight.w300),),
                            const SizedBox(height:10),                      
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,0,10,0),
                        child: IconButton(
                          onPressed: () async {
                            
                            isVideoLoading = true;
                            isInstructionLoading = true;
                            i = 0;
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true, 
                              builder: (context){
                                return StatefulBuilder(
                                  builder: (BuildContext context,StateSetter setModalState){
                                  if (i==0)
                                  {
                                    fetchVideo(exercises[index], setModalState);
                                    fetchInstruction(exercises[index], setModalState);
                                    i=1;
                                  }
                                  return ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: Container(
                                      height: MediaQuery.of(context).size.height*0.9,
                                      child: Scaffold(
                                        appBar: AppBar(
                                                title: Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    exercises[index],
                                                    style: GoogleFonts.nunitoSans(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w900
                                                      ),
                                                    ),
                                                ),
                                                automaticallyImplyLeading: false,
                                              ),
                                        body: Column(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    isVideoLoading ? const Center(child: CircularProgressIndicator()) :
                                                      CustomVideoPlayer(customVideoPlayerController: _customVideoPlayerController!),
                                                    const SizedBox(height:25),
                                                    const Padding(
                                                      padding: EdgeInsets.only(left: 18),
                                                      child: Text(
                                                        'INSTRUCTIONS',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color.fromARGB(255, 39, 92, 185),
                                                          ),
                                                       ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(16,8,0,4),
                                                      child: isInstructionLoading ? const Center(child: CircularProgressIndicator()) 
                                                        : Text(
                                                          instructions,
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
                                                            // color: Color.fromARGB(255, 39, 92, 185),
                                                            ),
                                                        ),
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.fromLTRB(18,10,0,4),
                                                      child: Text(
                                                        'FOCUS AREAS',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color.fromARGB(255, 39, 92, 185),
                                                          ),
                                                       ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: GridView.builder(
                                                        shrinkWrap: true,
                                                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                                          maxCrossAxisExtent: 150.0,
                                                          mainAxisSpacing: 10.0,
                                                          crossAxisSpacing: 10.0,
                                                          childAspectRatio:  5,
                                                          ),
                                                        itemCount: focus.length, 
                                                        itemBuilder: (context,index){
                                                          return Container(
                                                            decoration: BoxDecoration(
                                                              color: const Color.fromARGB(255, 136, 102, 228),
                                                              borderRadius: BorderRadius.circular(20),
                                                            ),
                                                            child: 
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(bottom: 3.0),
                                                                    child: Text(
                                                                      focus[index],
                                                                      textAlign: TextAlign.center,
                                                                      style: const TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 18.0
                                                                      ),
                                                                    ),
                                                                  ),
                                                          );
                                                        }
                                                        ),
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.fromLTRB(18,10,0,4),
                                                      child: Text(
                                                        'COMMON MISTAKES',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color.fromARGB(255, 39, 92, 185),
                                                          ),
                                                       ),
                                                    ),
                                                    ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: mistakes.keys.length,
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      itemBuilder: (context,index){
                                                        var heading = mistakes.keys.elementAt(index);
                                                          return Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Container(
                                                                  width: 20,
                                                                  height: 20,
                                                                  decoration: const BoxDecoration(
                                                                    color: Color.fromARGB(255, 184, 178, 242),
                                                                    shape: BoxShape.circle
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      (index+1).toString(),
                                                                      style: const TextStyle(
                                                                        color: Colors.white,
                                                                        fontWeight: FontWeight.bold
                                                                      ),
                                                                      ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const SizedBox(height: 4,),
                                                                  Text(
                                                                    heading,
                                                                    style: const TextStyle(
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.w600,
                                                                      fontSize: 16,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 4,),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context).size.width*0.9,
                                                                    child: Text(
                                                                      mistakes[heading]!,
                                                                      style: const TextStyle(
                                                                            fontSize: 16,
                                                                            fontWeight: FontWeight.w500,
                                                                      )
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          );
                                                        }
                                                      ),
                                                      const Padding(
                                                      padding: EdgeInsets.fromLTRB(18,10,0,4),
                                                      child: Text(
                                                        'BREATHING TIPS',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color.fromARGB(255, 39, 92, 185),
                                                          ),
                                                       ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(10,0,8,4),
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        physics: const NeverScrollableScrollPhysics(),
                                                        itemCount: breathing.length,
                                                        itemBuilder: (context,index){
                                                          return Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              const Text('•',style: TextStyle(fontSize: 24),),
                                                              const SizedBox(width:5),
                                                              Column(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  const SizedBox(height: 4,),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context).size.width*0.9,
                                                                    child: Text(
                                                                      breathing[index],
                                                                      style: const TextStyle(
                                                                            fontSize: 16,
                                                                            fontWeight: FontWeight.w500,
                                                                      ),
                                                                      )
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                        ),
                                                    ),
                                                  ],
                                                ),
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
                                                  color: Colors.blue,
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
                                      ),
                                    ),
                                  );
                                  }
                                );
                              }
                            ).whenComplete(videoClose);
                          }, 
                          icon: const Icon(Icons.help,color: Colors.grey,size:30)
                        ),
                      ),
                    ],
                  ),
                ),
                );
            }
            )
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context, MaterialPageRoute(
                  builder: (context) => Starting(
                    exercises: exercises,
                    workout: widget.workout,
                    meditate: meditate,
                    durations: durations,
                  )
                )
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Container(
                height: 60,
                color: Colors.blue,
                child: const Center(
                  child: Text(
                    'START', style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold,fontSize: 22
                      ),
                    )
                ),
              ),
            ),
          ),
        ),
        ],
      )
    );
  }
}