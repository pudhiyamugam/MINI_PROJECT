import 'package:flutter/material.dart';
import 'find_seat.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FOUND',
        style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 130, 6, 207),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchExcelScreen(),
                    ),
                  );
                },
                child: Text('FIND SEAT'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async{
var url = Uri.https(
  'app.mappedin.com', 
  '/map/65fbc2aa7c0c4fe5b4cc4683/directions',
  {
    'floor': 'm_c235d70c9e691132',
    'location': 's_fca685ba2c784ab7',
    'departure': 's_c0ed60b6daeada7c'
  }
);                  if(await canLaunchUrl(url)){
                    await launchUrl(url);
                  }
                },
                child: Text('GEC PATH'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
