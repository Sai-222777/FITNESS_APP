import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:fitness/pages/workout_page.dart';
import 'package:flutter/material.dart';

class Starting extends StatefulWidget {
  final List<String> exercises;
  final String workout;
  final Map<String,String> durations;
  final int meditate;
  const Starting({super.key, required this.exercises, required this.workout, required this.meditate, required this.durations});

  @override
  State<Starting> createState() => _StartingState();
}

class _StartingState extends State<Starting> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playClock();
    startLoad();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  int displayTime = 5;
  final clock = AudioPlayer();

  void playClock(){
    clock.play(AssetSource('audios/clock.mp3'));
    clock.setVolume(0.2);
  }

  void startLoad(){
      Timer.periodic(Duration(seconds: 1), (Timer tt){
        if(displayTime <= 0)
        {
          tt.cancel();
        }
        else{
          clock.setVolume((6-displayTime)/5);
          setState(() {
            displayTime = displayTime - 1;
          });
        }
      });
      Timer.periodic(Duration(seconds: 5), (Timer t){
        clock.dispose();
        t.cancel();
        Navigator.pushReplacement(
                context, MaterialPageRoute(
                  builder: (context) => WorkoutPage(
                    exercises: widget.exercises,
                    workout: widget.workout,
                    meditate: widget.meditate,
                    durations: widget.durations,
                  )
                )
              );
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[600],
      body: Center(
        child: Text(
          displayTime.toString(),
          style: TextStyle(
            fontSize: 72,
            color: Colors.white,
            fontWeight: FontWeight.w900
          ),
        ),
      ),
    );
  }
}