import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:meta_col_hub/auth.dart';
import 'login.dart';
import 'detail_screen.dart';
import 'add_collocation.dart';

class HomePage extends StatefulWidget {
  final bool isLoggedIn;

  const HomePage({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List<dynamic>> _csvData = [];
  Set<String> _searchResults = {};
  TextEditingController _searchController = TextEditingController();
  String? _fileName;
  String? _filePath;
  bool _fileUploaded = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _filterSearchResults(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['csv'], 
    );
    if (result == null) return;

    _filePath = result.files.single.path!;
    final input = File(_filePath!).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(fieldDelimiter: ';'))
        .toList();

    setState(() {
      _csvData = fields;
      _fileName = result.files.single.name;
      _fileUploaded = true;
      _filterSearchResults(
          _searchController.text);
    });
  }

  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    _searchResults.clear();

    for (var row in _csvData) {
      if (row.isNotEmpty) {
        String baseTerm = row[0].toString().trim();
        String firstWordBeforeSemicolon = baseTerm.split(';').first;
        if (firstWordBeforeSemicolon
            .toLowerCase()
            .startsWith(query.trim().toLowerCase())) {
          _searchResults.add(
              firstWordBeforeSemicolon);
        }
      }
    }

    setState(() {});
  }

  Future<void> _saveCollocation(
      String base, String collocation, String example) async {
    List<String> newRow = [base, collocation, example];
    _csvData.add(newRow);

    String csv =
        const ListToCsvConverter(fieldDelimiter: ';').convert(_csvData);
    await File(_filePath!).writeAsString(csv);
    _filterSearchResults(
        _searchController.text);
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  void _showUploadAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No CSV File Uploaded'),
        content:
            Text('Please upload a CSV file to use the search functionality.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MetaColHub', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: widget.isLoggedIn
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: TextButton(
                    onPressed: () {
                      signOut();
                    },
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.black),
                    ),
                    style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor:
                              Colors.lightBlue[200],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              
                            )
                          )
                  ),
                ),
              ]
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                      setState(() {});
                    },
                    child: Text(
                      'Log In',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor:
                              Colors.lightBlue[200],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              
                            )
                          )
                  ),
                ),
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text(
                    _fileUploaded
                        ? _fileName!
                        : "Upload .csv",
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
                if (widget.isLoggedIn) ...[
                  ElevatedButton(
                    onPressed: _fileUploaded
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddCollocationScreen(
                                  onSave:
                                      _saveCollocation,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text("Add Collocation"),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                ]
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Collocations of a Word',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ), 
              ),
              cursorColor: Colors.lightBlue,
              enabled: _fileUploaded
                  ? true
                  : false,
              onTap: () {
                if (!_fileUploaded) {
                  _showUploadAlert();
                }
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: _searchResults.map((result) {
                  List<List<dynamic>> collocations = _csvData
                      .where((row) =>
                          row[0].toString().trim().split(';').first == result)
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            result,
                          ),
                        ),
                        tileColor: Colors
                            .transparent,
                        hoverColor: Colors.transparent,
                        selectedTileColor:
                            Colors.transparent,
                        splashColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                baseTerm: result,
                                collocations: collocations,
                                allData:
                                    _csvData,
                                isLoggedIn: widget
                                    .isLoggedIn,
                                filePath: _filePath!,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
