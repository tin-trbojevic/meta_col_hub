import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'edit_collocation.dart';

class DetailScreen extends StatefulWidget {
  final String baseTerm;
  final List<List<dynamic>> collocations;
  final List<List<dynamic>> allData;
  final bool isLoggedIn;
  final String filePath;

  const DetailScreen({
    Key? key,
    required this.baseTerm,
    required this.collocations,
    required this.allData,
    required this.isLoggedIn,
    required this.filePath,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<List<dynamic>> filteredCollocations = [];
  bool isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    filteredCollocations = widget.collocations;
  }

  void _filterCollocations(String letter) {
    setState(() {
      filteredCollocations = widget.allData.where((row) {
        if (row.length > 1) {
          final collocation = row[1].toString().trim();
          return collocation.toLowerCase().startsWith(letter.toLowerCase()) &&
              row[0].toString().trim().split(';').first == widget.baseTerm;
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

  Future<void> _saveCSV() async {
    String csv =
        const ListToCsvConverter(fieldDelimiter: ';').convert(widget.allData);
    await File(widget.filePath).writeAsString(csv);
  }

  void _deleteCollocation(int index) {
    setState(() {
      final collocationRow = filteredCollocations[index];
      widget.allData.remove(collocationRow);
      filteredCollocations.removeAt(index);
      _saveCSV(); 
    });
  }

  Future<void> _editCollocation(int index) async {
    final collocationRow = filteredCollocations[index];
    String base = widget.baseTerm;
    String collocation =
        collocationRow.length > 1 ? collocationRow[1].toString().trim() : '';
    String example =
        collocationRow.length > 2 ? collocationRow[2].toString().trim() : '';

    final updatedCollocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCollocationScreen(
          base: base,
          collocation: collocation,
          example: example,
        ),
      ),
    );

    if (updatedCollocation != null) {
      setState(() {
        filteredCollocations[index] = [
          updatedCollocation['base'],
          updatedCollocation['collocation'],
          updatedCollocation['example']
        ];

        int mainDataIndex = widget.allData.indexOf(collocationRow);
        widget.allData[mainDataIndex] = filteredCollocations[index];
        _saveCSV(); 
      });
    }
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
                child: const Text('Remove Filter'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                      color: Colors.lightBlue,
                      width: 2,
                    ),
                  ),
                ),
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
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editCollocation(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Confirm Delete'),
                                          content: Text(
                                              'Are you sure you want to delete this collocation?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.lightBlue),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(
                                                      true),
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.lightBlue),
                                              ),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
