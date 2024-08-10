import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorkoutSettings extends StatefulWidget {
  const WorkoutSettings({super.key});

  @override
  State<WorkoutSettings> createState() => _WorkoutSettingsState();
}

class _WorkoutSettingsState extends State<WorkoutSettings> {

Map<String, String> durations = {
  'ABDOMINAL CRUNCHES': 'x16',
  'ARM CIRCLES CLOCKWISE': '00:30',
  'ARM CIRCLES COUNTERCLOCKWISE': '00:30',
  'ARM RAISES': '00:20',
  'ARM SCISSORS': '00:30',
  'BACKWARD LUNGE': 'x14',
  'CAT COW POSE': '00:30',
  'CHEST PRESS PULSE': '00:20',
  'CHEST STRETCH': '00:40',
  'CHILD\'S POSE': '00:30',
  'COBRA STRETCH': '00:30',
  'DIAGONAL PLANK': 'x10',
  'DIAMOND PUSH-UPS': 'x6',
  'DONKEY KICKS LEFT': 'x16',
  'DONKEY KICKS RIGHT': 'x16',
  'HEEL TOUCH': 'x20',
  'INCLINE PUSH-UPS': 'x6',
  'INCHWORMS': 'x8',
  'JUMPING JACKS': '00:40',
  'KNEE PUSH-UPS': 'x14',
  'KNEE TO CHEST STRETCH LEFT': '00:30',
  'KNEE TO CHEST STRETCH RIGHT': '00:30',
  'LEG BARBELL CURL LEFT': 'x8',
  'LEG BARBELL CURL RIGHT': 'x8',
  'LEG RAISES': 'x16',
  'MOUNTAIN CLIMBER': 'x16',
  'PLANK': '00:30',
  'PRONE TRICEPS PUSH UPS': 'x14',
  'PUNCHES': '00:30',
  'PUSH-UPS': 'x10',
  'RECLINED RHOMBOID SQUEEZES': 'x12',
  'RHOMBOID PULLS': 'x14',
  'RUSSIAN TWIST': 'x20',
  'SIDE ARM RAISE': '00:20',
  'SIDE HOP': '00:30',
  'SIDE-LYING FLOOR STRETCH LEFT': '00:30',
  'SIDE-LYING FLOOR STRETCH RIGHT': '00:30',
  'SIDE-LYING LEG LIFT LEFT': 'x12',
  'SIDE-LYING LEG LIFT RIGHT': 'x12',
  'SPINE LUMBAR TWIST STRETCH RIGHT': '00:30',
  'SPINE LUMBAR TWIST STRETCH LEFT': '00:30',
  'SQUATS': 'x12',
  'STANDING BICEPS STRETCH LEFT': '00:30',
  'STANDING BICEPS STRETCH RIGHT': '00:30',
  'SUMO SQUAT CALF RAISES WITH WALL': 'x12',
  'TRICEPS DIPS': 'x10',
  'TRICEPS STRETCH LEFT': '00:30',
  'TRICEPS STRETCH RIGHT': '00:30',
  'WALL CALF RAISES': 'x12',
  'WALL PUSH-UPS': 'x12',
  'WIDE ARM PUSH-UPS': 'x6',
};

  Map<String,String> prefChanges = {};

  Map<String,String> changed = {};

  Map<String, TextEditingController> repetitions = {};
  Map<String, TextEditingController> minutes = {};
  Map<String, TextEditingController> seconds = {};

  final CollectionReference preferenceCollection = FirebaseFirestore.instance.collection('preferences');
  User? user = FirebaseAuth.instance.currentUser;

  bool isloading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPrefs();
    durations.forEach((key, value) {
      if(value.startsWith('x'))
      {
        repetitions[key] = TextEditingController();
      }
      else
      {
        minutes[key] = TextEditingController();
        seconds[key] = TextEditingController();
      }
    },);
  }

  Map<String,String> finalChanges = {};

  void loadPrefs()async{
    DocumentSnapshot doc = await preferenceCollection.doc(user!.email).get();
    if(!doc.exists)
    {
      setState(() {
        isloading = false;
      });
      return;
    }
    changed = Map<String,String>.from(doc['prefs']);
    setState(() {
      changed.forEach((key,value){
        if(durations[key] != value)
        {
          finalChanges[key] = value;
          durations[key] = value;
        }
      });
    });
    setState(() {
      isloading = false;
    });
    await preferenceCollection.doc(user!.email).set({'prefs':finalChanges});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    repetitions.forEach((key,controller){
      controller.dispose();
    });
    minutes.forEach((key,controller){
      controller.dispose();
    });
    seconds.forEach((key,controller){
      controller.dispose();
    });
    super.dispose();
  }

  void saveChanges()async{
    repetitions.forEach((key,controller){
      if(durations[key]!.substring(1,) != controller.text && controller.text.isNotEmpty)
      {
        prefChanges[key] = 'x${controller.text}';
      }
    });
    minutes.forEach((key,controller){
      if(durations[key]!.split(':')[0] != controller.text && controller.text.isNotEmpty)
      {
        if(seconds[key]!.text.isEmpty){
          prefChanges[key] = '${controller.text}:00';
        }
        else{
          prefChanges[key] = '${controller.text}:${seconds[key]!.text}';
        }
      }
    });
    seconds.forEach((key,controller){
      if(durations[key]!.split(':')[1] != controller.text && controller.text.isNotEmpty)
      {
        if(minutes[key]!.text.isEmpty){
          prefChanges[key] = '00:${controller.text}';
        }
        else{
          prefChanges[key] = '${minutes[key]!.text}:${controller.text}';
        }
      }
    });
    if(prefChanges.isEmpty)
    {
      Navigator.pop(context);
      return;
    }
    await preferenceCollection.doc(user!.email).set({'prefs':prefChanges}, SetOptions(merge: true));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WORKOUT SETTINGS'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: ElevatedButton(
              onPressed: (){
                saveChanges();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400]
              ), 
              child: const Text(
                'SAVE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                )
              ),
          )
        ],
      ),
      body: isloading ? Center(child: CircularProgressIndicator()) :ListView.builder(
        itemCount: durations.length,
        itemBuilder: (context, index){
          String exercise = durations.keys.elementAt(index);
          return Container(
            padding: const EdgeInsets.fromLTRB(6,4,4,8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(exercise),
                if(durations[exercise]!.startsWith('x'))
                  SizedBox(
                    width: 50,
                    height: 60,
                    child: TextField(
                      controller: repetitions[exercise],
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'REP',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: durations[exercise]!.substring(1,),
                        border: OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Row(
                    children: [
                      SizedBox(
                        height: 60,
                        width: 50,
                        child: TextField(
                          controller: minutes[exercise],
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: 'MIN',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: durations[exercise]!.split(':')[0],
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5,),
                      SizedBox(
                        width: 50,
                        height: 60,
                        child: TextField(
                          controller: seconds[exercise],
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: 'SEC',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: durations[exercise]!.split(':')[1],
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          );
        }
        ),
    );
  }
}