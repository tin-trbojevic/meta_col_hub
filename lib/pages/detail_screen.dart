import 'dart:io';
import 'package:flutter/material.dart';
import 'edit_collocation.dart';

class DetailScreen extends StatefulWidget {
  final String baseTerm;
  final List<List<dynamic>> collocations;
  final List<List<dynamic>> allData;
  final bool isLoggedIn;
  final String filePath;
  final Map<String, List<List<dynamic>>> uploadedFiles;
  final List<List<dynamic>> csvData;
  final List<String> searchResults;
  final Function(String) searchAcrossFiles;

  const DetailScreen({
    Key? key,
    required this.baseTerm,
    required this.collocations,
    required this.allData,
    required this.isLoggedIn,
    required this.filePath,
    required this.uploadedFiles,
    required this.csvData,
    required this.searchResults,
    required this.searchAcrossFiles,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<List<dynamic>> filteredCollocations = [];
  Map<int, int> filteredToFileIndex = {};
  List<List<dynamic>> localAllData = [];
  bool isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    filteredCollocations = widget.collocations;
    localAllData = List.from(widget.allData);
    _loadCollocations();
  }

  Future<void> _loadCollocations() async {
    final collocations = await _getCollocationsForBase(widget.baseTerm);

    setState(() {
      filteredCollocations = collocations;

      filteredToFileIndex = {
        for (int i = 0; i < collocations.length; i++)
          i: localAllData.indexWhere((row) =>
              row.isNotEmpty &&
              row[0].toString().trim() ==
                  collocations[i][0].toString().trim() &&
              row[1].toString().trim() ==
                  collocations[i][1].toString().trim() &&
              (row.length > 2 &&
                  row[2].toString().trim() ==
                      collocations[i][2].toString().trim()))
      };

      print('Base Term: ${widget.baseTerm}');
      print('Collocations for Base: $collocations');
      print('FilteredToFileIndex after setting: $filteredToFileIndex');
    });
  }

  Future<List<List<dynamic>>> _getCollocationsForBase(String base) async {
    final List<List<dynamic>> collocations = [];
    try {
      widget.uploadedFiles.forEach((filePath, fileData) {
        fileData.forEach((row) {
          if (row.isNotEmpty && row[0].toString().trim() == base.trim()) {
            collocations.add(row);
          }
        });
      });
    } catch (e) {
      print('Error processing collocations: $e');
    }

    print('Filtered collocations for base "$base": $collocations');
    return collocations;
  }

  Future<void> _editCollocation(int index, String newBase,
      String newCollocation, String newExample) async {
    try {
      if (index < 0 || index >= filteredCollocations.length) {
        print('Invalid index for editing.');
        return;
      }

      final oldRow = filteredCollocations[index];

      final resolvedFilePath = widget.uploadedFiles.keys.firstWhere(
        (filePath) => widget.uploadedFiles[filePath]!.any((row) =>
            row.isNotEmpty &&
            row[0].toString().trim() == oldRow[0].toString().trim() &&
            row[1].toString().trim() == oldRow[1].toString().trim() &&
            (row.length > 2 &&
                row[2].toString().trim() == oldRow[2].toString().trim())),
        orElse: () {
          print('Could not find file for row: $oldRow');
          throw Exception('File not found for row.');
        },
      );

      print('Editing row in file: $resolvedFilePath');

      final file = File(resolvedFilePath);
      final List<String> lines = await file.readAsLines();

      for (int i = 0; i < lines.length; i++) {
        final parts = lines[i].split(';');
        if (parts.isNotEmpty &&
            parts[0].trim() == oldRow[0].toString().trim() &&
            parts[1].trim() == oldRow[1].toString().trim() &&
            (parts.length > 2 &&
                parts[2].trim() == oldRow[2].toString().trim())) {
          lines[i] = '$newBase;$newCollocation;$newExample';
          break;
        }
      }

      await file.writeAsString(lines.join('\n') + '\n');

      print('Row edited successfully in file: $resolvedFilePath');

      widget.uploadedFiles[resolvedFilePath] =
          lines.map((line) => line.split(';')).toList();

      setState(() {
        filteredCollocations[index] = [newBase, newCollocation, newExample];

        widget.allData.removeWhere((row) =>
            row.isNotEmpty &&
            row[0].toString().trim() == oldRow[0].toString().trim() &&
            row[1].toString().trim() == oldRow[1].toString().trim() &&
            (row.length > 2 &&
                row[2].toString().trim() == oldRow[2].toString().trim()));

        widget.allData.add([newBase, newCollocation, newExample]);
      });

      print('Collocation updated successfully.');
    } catch (e) {
      print('Error editing collocation: $e');
    }
  }

  Future<void> _deleteCollocation(int index) async {
    try {
      if (index < 0 || index >= filteredCollocations.length) {
        print('Invalid index for deletion.');
        return;
      }

      final collocationRow = filteredCollocations[index];

      final resolvedFilePath = widget.uploadedFiles.keys.firstWhere(
        (key) => widget.uploadedFiles[key]!.any((row) =>
            row.isNotEmpty &&
            row[0].toString().trim() == collocationRow[0].toString().trim() &&
            row[1].toString().trim() == collocationRow[1].toString().trim() &&
            (row.length > 2 &&
                row[2].toString().trim() ==
                    collocationRow[2].toString().trim())),
        orElse: () {
          print('Could not resolve file path for row: $collocationRow');
          throw Exception('File not found for row.');
        },
      );

      print('Deleting from file: $resolvedFilePath');

      final file = File(resolvedFilePath);
      final List<String> lines = await file.readAsLines();

      final updatedLines = lines.where((line) {
        final parts = line.split(';');
        return !(parts.isNotEmpty &&
            parts[0].trim() == collocationRow[0].toString().trim() &&
            parts[1].trim() == collocationRow[1].toString().trim() &&
            (parts.length > 2 &&
                parts[2].trim() == collocationRow[2].toString().trim()));
      }).toList();

      await file.writeAsString(updatedLines.join('\n') + '\n');

      print('Row deleted successfully from file: $resolvedFilePath');

      setState(() {
        filteredCollocations.removeAt(index);
        widget.allData.removeWhere(
          (row) =>
              row.isNotEmpty &&
              row[0].toString().trim() == collocationRow[0].toString().trim() &&
              row[1].toString().trim() == collocationRow[1].toString().trim() &&
              (row.length > 2 &&
                  row[2].toString().trim() ==
                      collocationRow[2].toString().trim()),
        );

        widget.uploadedFiles[resolvedFilePath] =
            updatedLines.map((line) => line.split(';')).toList();
      });

      print('Collocation deleted successfully.');
    } catch (e) {
      print('Error deleting collocation: $e');
    }
  }

  void _filterCollocations(String letter) {
    setState(() {
      filteredCollocations = widget.allData.where((row) {
        if (row.length > 1) {
          final collocation = row[1].toString().trim();
          return collocation.toLowerCase().startsWith(letter.toLowerCase()) &&
              row[0].toString().trim() == widget.baseTerm;
        }
        return false;
      }).toList();
      isFilterApplied = true;
    });
  }

  void _removeFilter() {
    setState(() {
      filteredCollocations = widget.collocations;
      isFilterApplied = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.baseTerm),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    'A,B,C,Č,Ć,D,DŽ,Đ,E,F,G,H,I,J,K,L,LJ,M,N,NJ,O,P,R,S,Š,T,U,V,Z,Ž'
                        .split(',')
                        .map((letter) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: ElevatedButton(
                      onPressed: () => _filterCollocations(letter),
                      child: Text(letter),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (isFilterApplied)
              ElevatedButton(
                onPressed: _removeFilter,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: const BorderSide(
                      color: Colors.lightBlue,
                      width: 2,
                    ),
                  ),
                ),
                child: const Text('Remove Filter'),
              ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCollocations.length,
                itemBuilder: (context, index) {
                  final collocationRow = filteredCollocations[index];
                  String collocation = '';
                  String example = 'No example available';

                  if (collocationRow.length > 1) {
                    collocation = collocationRow[1].toString().trim();
                  }
                  if (collocationRow.length > 2) {
                    example = collocationRow[2].toString().trim();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7.0),
                    child: ListTile(
                      title: Text(
                        '${widget.baseTerm} - $collocation',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          '"$example"',
                          style: const TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      trailing: widget.isLoggedIn
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditCollocationScreen(
                                          base: widget.baseTerm,
                                          collocation: collocation,
                                          example: example,
                                        ),
                                      ),
                                    );

                                    if (result != null) {
                                      _editCollocation(
                                          index,
                                          result['base'],
                                          result['collocation'],
                                          result['example']);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.lightBlue[50],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          title: const Text(
                                            "Confirm Delete",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          content: const Text(
                                            "Are you sure you want to delete this collocation?",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.black,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 12),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      side: const BorderSide(
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "Cancel",
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                                const SizedBox(width: 15),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: Colors.red
                                                        .withOpacity(0.8),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 12),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "Remove",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirm == true) {
                                      _deleteCollocation(index);
                                    }
                                  },
                                ),
                              ],
                            )
                          : null,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
