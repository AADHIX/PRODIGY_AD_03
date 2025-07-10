import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      home: HomeApp(),
    );
  }
}

class HomeApp extends StatefulWidget {
  const HomeApp({super.key});

  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {

    //now lets build the logic


    int seconds = 0, minutes = 0, hours = 0;

      String digitSeconds = "00", digitMinutes = "00",digitHours = "00";

      Timer? timer;
      bool started = false;
      List laps = [];

                // Creating the Stop Timer Loop function

    

    void stop(){
      timer!.cancel();
      setState(() {
        started = false;
      }
      );
    }
      
      // Creating the reset function

      void reset()
      {
          timer?.cancel();
          setState(() {
            seconds = 0;
            minutes = 0;
            hours = 0;

            digitSeconds = "00";
            digitMinutes = "00";
            digitHours   = "00";

            started = false;
            laps.clear();
          });
      }

      //creating Start timer function 
      void start(){
        started = true;
        timer = Timer.periodic(Duration(seconds: 1), (timer) {
          int localSeconds = seconds + 1;
          int localMinutes = minutes;
          int localHours = hours;

          if (localSeconds > 59) {
            localSeconds = 0;
            localMinutes++;
            if (localMinutes > 59) {
              localMinutes = 0;
              localHours++;
            }
          }

          setState(() {
            seconds = localSeconds;
            minutes = localMinutes;
            hours = localHours;

            digitSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
            digitMinutes = (minutes >= 10) ? "$minutes" : "0$minutes";
            digitHours = (hours >= 10) ? "$hours" : "0$hours";
          });
        });
      }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2757),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: Text("Stop Watch App", style: TextStyle(
                color: Colors.white,
                 fontSize: 28.0,
                 fontWeight: FontWeight.bold,
                  ),
              ),
              ),
              SizedBox(
                height: 20.0,
                ),
                Center(child: Text("00:00:00",
                style:TextStyle(
                  color: Colors.white,
                  fontSize: 82.0,
                  fontWeight: FontWeight.w600,                //Font Weight 
                   ),

                  ),
                  ),
                Container(
                  height: 400.0,
                  decoration: BoxDecoration(
                    color: Color(0xFF323F68),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,        //Row
                  children: [
                    Expanded(
                    child: RawMaterialButton(
                    onPressed: () {}, 
                     shape: const  StadiumBorder(
                      side: BorderSide(color: Colors.blue),

                     ),   
                     child: Text(
                      "Start",
                      style: TextStyle(color: Colors.white),
                    
                     ),                                       //onPressed
                    ),
                    ),
                     SizedBox(width: 8.0,
                     ),
                      IconButton(
                        color: Colors.white,
                        onPressed: () {}, 
                      icon: Icon(Icons.flag),
                       ),
                       SizedBox(width: 8.0,
                     ),
                     Expanded(
                    child: RawMaterialButton(
                    onPressed: () {},
                    fillColor: Colors.blue, 
                     shape: const  StadiumBorder(
                      side: BorderSide(color: Colors.blue),

                     ),   
                     child: Text(
                      "Reset",
                      style: TextStyle(color: Colors.white),
                    
                     ),                                       //onPressed
                    ),
                    ),


                    ],
                 ),
            ],
          )
        ),
      )
    );
  }
}


