import 'dart:async';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness/pages/quit_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WorkoutPage extends StatefulWidget {
  final List<String> exercises;
  final String workout;
  final Map<String,String> durations;
  final int meditate;
  const WorkoutPage({super.key, required this.exercises, required this.workout, required this.meditate, required this.durations});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage>{

  int _index = 0;

  CustomVideoPlayerController? _customVideoPlayerController;
  VideoPlayerController? _videoPlayerController;
  late String videoUrl;

  final CollectionReference exerciseCollection = FirebaseFirestore.instance.collection('exercises');
  final CollectionReference bioCollection = FirebaseFirestore.instance.collection('bio');

  late String instructions;
  Map<String,String> mistakes = {};
  List<String> breathing = [];
  List<String> focus = [];
  bool isVideoLoading = true, isInstructionLoading = true, takeRest = false;
  late int i = 0;
  String? reps;

  User? user;
  String? email;

  late Map<String,String> durations;

  // final Map<String, String> durations = {
  //   'JUMPING JACKS' : '00:40',
  //   'ARM RAISES' : '00:20',
  //   'RHOMBOID PULLS' : 'x14',
  //   'KNEE PUSH-UPS' : 'x14',
  //   'SIDE ARM RAISE' : '00:20',
  //   'ARM SCISSORS' : '00:30',
  //   'SIDE-LYING FLOOR STRETCH LEFT': '00:30',
  //   'SIDE-LYING FLOOR STRETCH RIGHT' : '00:30',
  //   'CAT COW POSE': '00:30',
  //   'PRONE TRICEPS PUSH UPS': 'x14',
  //   'RECLINED RHOMBOID SQUEEZES': 'x12',
  //   'CHILD\'S POSE': '00:30',
  //   'ABDOMINAL CRUNCHES' : 'x16',
  //   'RUSSIAN TWIST' : 'x20',
  //   'MOUNTAIN CLIMBER' : 'x16',
  //   'HEEL TOUCH' : 'x20', 
  //   'LEG RAISES' : 'x16', 
  //   'PLANK' : '00:30',
  //   'COBRA STRETCH' : '00:30',
  //   'SPINE LUMBER TWIST STRETCH LEFT' : '00:30', 
  //   'SPINE LUMBAR TWIST STRETCH RIGHT' : '00:30',
  //   'INCLINE PUSH-UPS' : 'x6', 
  //   'PUSH-UPS' : 'x10', 
  //   'WIDE ARM PUSH-UPS' : 'x6',
  //   'TRICEPS DIPS' : 'x10',
  //   'CHEST STRETCH' : '00:40',
  //   'ARM CIRCLES CLOCKWISE' : '00:30',
  //   'ARM CIRCLES COUNTERCLOCKWISE' : '00:30', 
  //   'DIAMOND PUSH-UPS' : 'x6',
  //   'CHEST PRESS PULSE' : '00:20',
  //   'LEG BARBELL CURL LEFT' : 'x8', 
  //   'LEG BARBELL CURL RIGHT' : 'x8', 
  //   'DIAGONAL PLANK' : 'x10', 
  //   'PUNCHES' : '00:30', 
  //   'INCHWORMS' : 'x8', 
  //   'WALL PUSH-UPS' : 'x12', 
  //   'TRICEPS STRETCH LEFT' : '00:30', 
  //   'TRICEPS STRETCH RIGHT' : '00:30',
  //   'STANDING BICEPS STRETCH LEFT' : '00:30', 
  //   'STANDING BICEPS STRETCH RIGHT' : '00:30',
  //   'SIDE HOP' : '00:30', 
  //   'SQUATS' : 'x12',
  //   'SIDE-LYING LEG LIFT LEFT' : 'x12', 
  //   'SIDE-LYING LEG LIFT RIGHT' : 'x12',
  //   'BACKWARD LUNGE' : 'x14',
  //   'DONKEY KICKS LEFT' : 'x16', 
  //   'DONKEY KICKS RIGHT' : 'x16',
  //   'LEFT QUAD STRETCH WITH WALL' : '00:30', 
  //   'RIGHT QUAD STRETCH WITH WALL' : '00:30', 
  //   'KNEE TO CHEST STRETCH LEFT' : '00:30',
  //   'KNEE TO CHEST STRETCH RIGHT' : '00:30', 
  //   'WALL CALF RAISES' : 'x12',
  //   'SUMO SQUAT CALF RAISES WITH WALL' : 'x12',
  //   'SUMO SQUAT RAISES WITH WALL' : 'x12', 
  //   'CALF STRETCH LEFT' : '00:30', 
  //   'CALF STRETCH RIGHT' : '00:30',
  //   'MEDITATION': 'x3'
  // };

  Timer? timer;
  Stopwatch stopwatch = Stopwatch();
  Stopwatch total = Stopwatch();
  String displayTime = '00:00';
  Duration remainingTime = const Duration();
  late int minutes,seconds;
  late String duration;
  late List<String> timings;
  bool isPaused = false;
  bool finished = false;
  bool muted = false;

  final player = AudioPlayer();
  final yogaPlayer = AudioPlayer();
  final music = AudioPlayer();

  String? date;
  String? time;

  String? caloriesBurned;
  List<String>? currentTotal;

  int? hrs, mins, currHrs, currMins;

  Map<String,int> exps = {
    'ABS' : 50,
    'CHEST' : 25,
    'ARMS': 25,
    'LEGS': 50,
    'SHOULDERS & BACK' : 50,
    'YOGA' : 0,
  };
  
  Map<String, double> mets = {
    'ABS' : 3.8,
    'CHEST' : 4.6,
    'ARMS': 4.1,
    'LEGS': 3.6,
    'SHOULDERS & BACK' : 3.5,
    'YOGA' : 0,
  };

  int calories = 0;

  void playLocalAsset(int i){
    if(i==0)
    {
    player.play(AssetSource('audios/resume.mp3'));
    }
    else 
    {
    player.play(AssetSource('audios/timeout.mp3'));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    durations = widget.durations;
    if(widget.workout == 'YOGA')
    {
      durations['MEDITATION'] = '${widget.meditate}:00';
      playYoga();
      playMusic();
    }
    startExercise();
    getCurrentUsername();
    totalTime();
    startAwake();
    // WakelockPlus.toggle(enable: true);  
  }

  void startAwake() async{
    await WakelockPlus.enable();
  }

  int k = 1;
  bool musicMuted = false;

  void playYoga(){
    Timer.periodic(Duration(seconds: 10), (Timer t){
      if(finished)
      {
        t.cancel();
      }
      if(!isPaused)
      {
        k == 1 ? yogaPlayer.play(AssetSource('audios/INHALE_.mp3')) : yogaPlayer.play(AssetSource('audios/EXHALE.mp3'));
        k = 1 - k;
      }
    });
  }

  void playMusic(){
    music.setSource(AssetSource('audios/silence.mp3'));
    music.setVolume(0.7);
    music.setReleaseMode(ReleaseMode.loop);
    music.play(AssetSource('audios/silence.mp3'));
  }

  void totalTime(){
    total.start();
    Timer.periodic(const Duration(seconds: 1), (Timer t){
      if(finished)
      {
        t.cancel();
      }
      if(isPaused){
        total.stop();
      }
      else
      {
        total.start();
      }
    });
  }

  void getCurrentUsername(){
      user = FirebaseAuth.instance.currentUser;
      email = user!.email;
  }

  Future<void> finish()async{
    date = DateFormat('MMM d yyyy').format(DateTime.now());
    time = total.elapsed.inMinutes.toString();
    DocumentSnapshot doc =  await bioCollection.doc(user!.email).get();
    currentTotal = doc['totalTime'].split(':');
    hrs = int.parse(currentTotal![0]) + total.elapsed.inHours;
    mins = int.parse(currentTotal![1]) + (total.elapsed.inMinutes % 60) ;
    int exp = doc['exp'] + exps[widget.workout];
    int level = doc['level'];
    int currCalories = doc['calories'];
    var wt = doc['kg'];
    if(wt != "")
    {
      calories = ((mets[widget.workout]! * 3.5 * wt * total.elapsed.inMinutes) / 200 ).toInt();
    }
    if(mins! > 60)
    {
      hrs = hrs! + 1;
      mins = mins! % 60;
      
    }
    if(exp >= 300)
    {
      level = level + 1;
      exp = exp % 300;
    }
    await bioCollection.doc(user!.email).set({
      widget.workout : date,  // last time exercise
      'past' : FieldValue.arrayUnion(['${widget.workout}-$date-$time-$calories']),
      'totalTime': '${hrs}:${mins}',
      'level':level,
      'exp':exp,
      'calories': currCalories + calories
    }, SetOptions(merge: true));
    Navigator.pop(context);
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

  void startRest(){
    playLocalAsset(1);
    stopwatch.stop();
    timer?.cancel();
    remainingTime = const Duration(seconds: 20);
    timer = Timer.periodic(const Duration(seconds: 1), (Timer _timer){
      if(!isPaused){
          setState(() {
            if(remainingTime.inSeconds > 0){
            remainingTime = remainingTime - const Duration(seconds: 1);
            displayTime = remainingTime.toString().substring(2,7);
            }
            else
            {
              _timer.cancel();
              _index = _index + 1;
              startExercise();
              takeRest = false;
            }
          });
        }
      });

  }

  void startExercise(){
    if(_index>= widget.exercises.length)
    {
      Navigator.pop(context);
    }
    else{
      playLocalAsset(0);
      duration = durations[widget.exercises[_index]]!;
      if(duration.startsWith('x'))
      {
      reps = duration;
      stopwatch.reset();
      stopwatch.start();
      timer?.cancel();
      setState(() {
        displayTime = stopwatch.elapsed.toString().substring(2,7);
      }); 
      Timer.periodic(const Duration(seconds: 1), (timer){
          if(!isPaused && !stopwatch.isRunning)
          {
            timer.cancel();
          }
          else{
            if(!isPaused){
            setState(() {
              displayTime = stopwatch.elapsed.toString().substring(2,7);
            });
            }
            else
            {
              stopwatch.stop();
            }
          }
      });
      }
      else
      {
        reps = null;
        stopwatch.stop();
        timings = duration.split(':');
        minutes = int.parse(timings[0]);
        seconds = int.parse(timings[1]);
        remainingTime = Duration(minutes: minutes,seconds: seconds);
        timer?.cancel();
        timer = Timer.periodic(const Duration(seconds: 1), (Timer _timer){
          if(!isPaused){
            setState(() {
              if(remainingTime.inSeconds > 0){
              remainingTime = remainingTime - const Duration(seconds: 1);
              displayTime = remainingTime.toString().substring(2,7);
              }
              else{
                _timer.cancel();
                if(_index + 1 < widget.exercises.length)
                {
                  // _index = _index + 1;
                  // startExercise();
                  takeRest = true;
                  startRest();
                }
                else
                {
                  total.stop();
                  finished = true;
                  finish();
                }
              }
            });
          }
        });
      }
    }
  }
  
  void pop(){
    Navigator.pop(context);
    return ;
  }

  void videoClose(){
    stopwatch.start();
    isPaused = false;
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
    timer?.cancel();
    stopwatch.stop();
    total.stop();
    player.dispose();
    yogaPlayer.dispose();
    music.dispose();
    stopAwake();
    super.dispose();
  }

  void stopAwake()async{
    await WakelockPlus.disable();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('WORKOUT' ,style:GoogleFonts.montserrat(fontWeight: FontWeight.bold,fontSize: 28)),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (){
              setState(() {
                isPaused = true;
              });
              Navigator.push(context, MaterialPageRoute(builder: (context) => QuitPage(email: email,)));
            },
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: (){
                    muted ? player.setVolume(1) : player.setVolume(0);
                    setState(() {
                      muted = !muted;
                    });
                  }, 
                  icon: muted ? Icon(Icons.volume_off, size: 35,) : Icon(Icons.volume_mute, size: 35,)
                ),
                if(widget.workout == 'YOGA')
                  IconButton(
                    onPressed: (){
                      musicMuted ? music.setVolume(0.5) : music.setVolume(0);
                      setState(() {
                        musicMuted = !musicMuted;
                      });
                    }, 
                    icon: musicMuted ? Icon(Icons.music_off, size: 35,) : Icon(Icons.music_note, size: 35,)
                  ),
              ],
            ),
            if(widget.workout == 'YOGA')
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 300,
                  child: Image.asset('assets/images/lotus-pose.gif')
                ),
              ),
            !takeRest ? Column(
              children: [
                Text(
                  widget.exercises[_index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 10,),
              reps != null ? Text(
                reps!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 32,
              ),
            ) : const SizedBox(height:5),
                IconButton(
              onPressed: (){
              isPaused = true;
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
                      fetchVideo(widget.exercises[_index], setModalState);
                      fetchInstruction(widget.exercises[_index], setModalState);
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
                                      widget.exercises[_index],
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
                                                        ),
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
              icon: const Icon(Icons.help_outline, size: 40, color: Colors.black87,)
            ),
              ],
            ) 
            : Column(
              children: [
                const Text(
                  'REST',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 15,),
                Text(
                  'COMING UP : ${widget.exercises[_index+1]}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w400),
                ), 
                const SizedBox(height: 20,),
              ],
            ),
            Text(
              displayTime,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  child: ElevatedButton(
                    onPressed: (){
                      setState(() {
                        isPaused = !isPaused;
                      });
                      // isPaused = !isPaused;
                      if(!stopwatch.isRunning)
                      {
                        stopwatch.start();
                      }
                    },
                    
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromRGBO(44, 152, 176, 1),
                        ),
                      fixedSize: MaterialStateProperty.all<Size>(const Size(135, 50)),
       
                    ),
                    child: Row(
                      children: [
                      if(!isPaused) const Icon(Icons.pause, color: Colors.white,),
                      isPaused? const Text('\t\tRESUME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)) 
                        : const Text('PAUSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ]
                      ),
                  ),
                ),
                _index + 1 < widget.exercises.length ? IconButton(
                  onPressed: (){
                    setState(() {
                      if(!takeRest)
                      {
                        reps = null;
                        takeRest = true;
                        startRest();
                      }
                      else
                      {
                        _index = _index + 1;
                        startExercise();
                        takeRest = false;
                      }
                      isPaused = false;
                    });
                  },
                  icon: const Icon(Icons.skip_next,size: 50,)) : 
                    TextButton(
                      onPressed:(){
                          if(finished)
                          {
                            return;
                          }
                          total.stop();
                          finished = true;
                          finish();
                      }, 
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.blueAccent,
                          child: const Text('FINISH', style: TextStyle(fontSize: 20, color: Colors.black)
                          )
                        ),
                      )
                    ),
              ],
            ),
            takeRest ? Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: TextButton(
                  onPressed: (){
                    remainingTime = remainingTime + const Duration(seconds: 20);
                    setState(() {
                      displayTime = remainingTime.toString().substring(2,7);
                    });
                  }, 
                  child: const Text(
                    '+20 s', 
                    style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold
                      ),
                    )
                  ),
              ),
            ) : IconButton(
              onPressed: (){
                startExercise();
                isPaused = false;
              }, 
              icon: Icon(Icons.restart_alt, size: 40,)
              ),
          ],
        )
      ),
    );
  }
}