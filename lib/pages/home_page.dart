import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'detail_screen.dart';
import 'login.dart';
import 'add_collocation.dart';
import 'file_manager.dart';
import 'package:meta_col_hub/auth.dart';

class HomePage extends StatefulWidget {
  final bool isLoggedIn;

  const HomePage({super.key, required this.isLoggedIn});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, List<List<dynamic>>> _uploadedFiles = {};
  List<List<dynamic>> _csvData = [];
  final Set<String> _searchResults = {};
  final TextEditingController _searchController = TextEditingController();
  bool _fileUploaded = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchAcrossFiles(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return;

    for (var file in result.files) {
      final filePath = file.path!;
      try {
        final input = File(filePath).openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter(fieldDelimiter: ';', eol: '\n'))
            .toList();

        final cleanedFields = fields
            .where((row) => row.isNotEmpty)
            .map((row) => row.map((value) => value.toString().trim()).toList())
            .toList();

        setState(() {
          _uploadedFiles[filePath] = cleanedFields;
          _fileUploaded = true;

          _csvData
              .addAll(cleanedFields.where((row) => !_csvData.contains(row)));

          _searchAcrossFiles(_searchController.text);
        });
      } catch (e) {
        print('Error uploading file $filePath: $e');
      }
    }
  }

  void _removeFile(String filePath) {
    setState(() {
      if (_uploadedFiles.containsKey(filePath)) {
        final removedData = _uploadedFiles.remove(filePath);
        if (removedData != null) {
          _csvData.removeWhere((row) => removedData.contains(row));
        }

        _searchResults.removeWhere(
            (base) => !_csvData.any((row) => row.isNotEmpty && row[0] == base));

        _searchAcrossFiles(_searchController.text);

        if (_uploadedFiles.isEmpty) {
          _fileUploaded = false;
          _csvData.clear();
          _searchResults.clear();
        }
      }
    });

    Navigator.pop(context, true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File removed successfully.')),
    );
  }

  void _searchAcrossFiles(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults.clear();
        return;
      }

      final Set<String> results = {};

      for (var row in _csvData) {
        if (row.isNotEmpty) {
          String base = row[0].toString().trim().toLowerCase();
          if (base.startsWith(query.toLowerCase())) {
            results.add(base);
          }
        }
      }

      _searchResults
        ..clear()
        ..addAll(results);
    });

    print('Updated search results: $_searchResults');
  }

  void _clearSearchResults() {
    setState(() {
      _searchController.clear();
      _searchResults.clear();
    });
  }

  Future<void> _saveCollocation(
      String base, String collocation, String example) async {
    if (base.isEmpty || collocation.isEmpty || example.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields must be filled.')),
      );
      return;
    }

    final filePaths = _uploadedFiles.keys.toList();
    if (filePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No uploaded files available to save.')),
      );
      return;
    }

    String? selectedFilePath = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color.fromARGB(255, 204, 239, 255),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select a file to save to',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: filePaths.map((filePath) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, filePath);
                        },
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.grey.shade400, width: 1),
                          ),
                          child: Text(
                            filePath.split('/').last,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected.')),
      );
      return;
    }

    try {
      final file = File(selectedFilePath);
      final newRow = [base, collocation, example];

      List<String> lines = file.existsSync() ? file.readAsLinesSync() : [];
      lines.add(newRow.join(';'));
      await file.writeAsString(lines.join('\n'));

      setState(() {
        _uploadedFiles[selectedFilePath]!
            .add(newRow.map((e) => e.toString()).toList());
        _csvData.add(newRow.map((e) => e.toString()).toList());
      });

      _searchAcrossFiles(_searchController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collocation added successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save collocation: $e')),
      );
    }
  }

  Future<List<List<dynamic>>> _getCollocationsForBase(String base) async {
    final List<List<dynamic>> collocations = [];
    for (var filePath in _uploadedFiles.keys) {
      try {
        final rows = _uploadedFiles[filePath]!;
        final filteredRows = rows.where(
            (row) => row.isNotEmpty && row[0].toString().trim() == base.trim());

        collocations.addAll(filteredRows);
      } catch (e) {
        print('Error processing file $filePath: $e');
      }
    }
    print('Filtered collocations for base "$base": $collocations');
    return collocations;
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 204, 239, 255),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'MetaColHub',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      widget.isLoggedIn
                          ? Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: TextButton(
                                onPressed: () async {
                                  await signOut();
                                  setState(() {});
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.lightBlue[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Log Out',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: TextButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                  setState(() {});
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.lightBlue[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.isLoggedIn ? _pickFiles : null,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              bool isSmall = constraints.maxWidth < 130;
                              double fontSize = isSmall ? 10 : 16;
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  isSmall ? "Upload\n.csv" : "Upload .csv",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FileManager(
                                  uploadedFiles: _uploadedFiles,
                                  onFileRemoved: _removeFile,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              bool isSmall = constraints.maxWidth < 130;
                              double fontSize = isSmall ? 12 : 16;
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  isSmall
                                      ? "Uploaded\nFiles"
                                      : "Uploaded Files",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_fileUploaded && widget.isLoggedIn)
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddCollocationScreen(
                                        onSave: _saveCollocation,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              bool isSmall = constraints.maxWidth < 130;
                              double fontSize = isSmall ? 10 : 16;
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  isSmall
                                      ? "Add\nCollocation"
                                      : "Add Collocation",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _searchController,
                    onChanged: _fileUploaded
                        ? _searchAcrossFiles
                        : null,
                    enabled:
                        _fileUploaded,
                    decoration: InputDecoration(
                      labelText: 'Search Collocations of a Word',
                      labelStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _fileUploaded ? _clearSearchResults : null,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                    ),
                    cursorColor: Colors.lightBlue,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 15),
                children: _searchResults.map((result) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 15.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        title: Center(
                          child: Text(
                            result,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        onTap: () async {
                          final collocations =
                              await _getCollocationsForBase(result);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                baseTerm: result,
                                collocations: collocations,
                                allData: _csvData,
                                isLoggedIn: widget.isLoggedIn,
                                filePath: _uploadedFiles.keys.firstWhere(
                                  (filePath) => _uploadedFiles[filePath]!.any(
                                    (row) => row.isNotEmpty && row[0] == result,
                                  ),
                                  orElse: () => '',
                                ),
                                uploadedFiles: _uploadedFiles,
                                csvData: _csvData,
                                searchResults: _searchResults.toList(),
                                searchAcrossFiles: _searchAcrossFiles,
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
      );
  }
}
