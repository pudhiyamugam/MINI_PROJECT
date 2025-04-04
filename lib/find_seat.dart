import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam Hall Finder with Navigation Guide',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SearchExcelScreen(),
    );
  }
}

class SearchExcelScreen extends StatefulWidget {
  @override
  _SearchExcelScreenState createState() => _SearchExcelScreenState();
}

class _SearchExcelScreenState extends State<SearchExcelScreen> {
  String _searchQuery = "";
  List<Map<String, dynamic>> _searchResults = [];
  bool _showImages = false;
  
  final List<Map<String, String>> imageData = [
    {
      'path': 'assets/entrance.jpg',
      'caption': 'Through entrance walk to CSE department'
    },
    {
      'path': 'assets/corridor_1.jpg',
      'caption': 'Go straight and take first right'
    },
    {
      'path': 'assets/corridor_2.jpg',
      'caption': 'Continue until you reach your destination'
    },
    {
      'path': 'assets/corridor_3.jpg',
      'caption': 'continue walking forward untill reach destination'
    },
    {
      'path': 'assets/room_121.jpg',
      'caption': 'reached the destination'
    },
  ];
  int _currentImageIndex = 0;

  Future<void> _searchInExcel() async {
    try {
      ByteData data = await rootBundle.load("assets/data.xlsx");
      var bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);

      setState(() {
        _searchResults.clear();
        _showImages = true;
      });

      var sheet = excel.tables[excel.tables.keys.first]!;
      List<String> headers = sheet.rows[0].map((cell) => cell?.value.toString() ?? "").toList();

      for (int i = 1; i < sheet.rows.length; i++) {
        var row = sheet.rows[i];
        for (int j = 0; j < row.length; j++) {
          String cellValue = row[j]?.value.toString().toLowerCase() ?? "";
          if (cellValue.contains(_searchQuery.toLowerCase())) {
            Map<String, dynamic> matchedRow = {
              headers[0]: row[0]?.value,
              headers[j]: row[j]?.value
            };
            setState(() {
              _searchResults.add(matchedRow);
            });
            break;
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _nextImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % imageData.length;
    });
  }

  void _previousImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex - 1) < 0 
          ? imageData.length - 1 
          : _currentImageIndex - 1;
    });
  }

  Future<void> _launchMap() async {
    final url = Uri.https(
      'app.mappedin.com', 
      '/map/65fbc2aa7c0c4fe5b4cc4683/directions',
      {
        'floor': 'm_c235d70c9e691132',
        'location': 's_fca685ba2c784ab7',
        'departure': 's_c0ed60b6daeada7c'
      }
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch the map")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Exam Hall Finder"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Enter Registration Number",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: (value) => _searchQuery = value,
                        onSubmitted: (_) => _searchInExcel(),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _searchInExcel,
                          child: Text("Find My Exam Hall"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              // Search Results
              if (_searchResults.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Exam Hall Details:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: _searchResults.first.entries.map((entry) =>
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${entry.key}: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${entry.value}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              
              // Image Navigation Guide and Map Button
              if (_showImages) ...[
                Divider(thickness: 2),
                SizedBox(height: 16),
                Text(
                  "Navigation Guide:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  height: screenHeight * 0.5,
                  width: screenWidth * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                  )],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                imageData[_currentImageIndex]['path']!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline, 
                                            color: Colors.red, size: 40),
                                        SizedBox(height: 10),
                                        Text(
                                          'Image not found',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                        child: Column(
                          children: [
                            Text(
                              imageData[_currentImageIndex]['caption']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue[900],
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back_ios, size: 28),
                                  onPressed: _previousImage,
                                  color: Colors.blue[800],
                                ),
                                SizedBox(width: 20),
                                Text(
                                  'Step ${_currentImageIndex + 1} of ${imageData.length}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 20),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward_ios, size: 28),
                                  onPressed: _nextImage,
                                  color: Colors.blue[800],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _launchMap,
                  child: Text("GEC PATH"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}