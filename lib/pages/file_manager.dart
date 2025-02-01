import 'package:flutter/material.dart';

class FileManager extends StatefulWidget {
  final Map<String, List<List<dynamic>>> uploadedFiles;
  final Function(String) onFileRemoved;

  const FileManager({
    Key? key,
    required this.uploadedFiles,
    required this.onFileRemoved,
  }) : super(key: key);

  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  late Map<String, List<List<dynamic>>> _currentFiles;

  @override
  void initState() {
    super.initState();
    _currentFiles = Map.from(widget.uploadedFiles);
  }

  void _removeFile(String filePath) {
    setState(() {
      _currentFiles.remove(filePath);
    });
    widget.onFileRemoved(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Manager'),
      ),
      body: ListView.builder(
        itemCount: _currentFiles.length,
        itemBuilder: (context, index) {
          final filePath = _currentFiles.keys.elementAt(index);
          final fileName = filePath.split('/').last;

          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ListTile(
                title: Text(fileName),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor:
                              Colors.lightBlue[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          title: const Text(
                            "Remove File",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          content: const Text(
                            "Are you sure you want to remove this file from the application?",
                            style: TextStyle(fontSize: 16),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      side:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  child: const Text("Cancel",
                                      style: TextStyle(fontSize: 16)),
                                ),
                                const SizedBox(width: 15),
                                TextButton(
                                  onPressed: () {
                                    _removeFile(filePath);
                                    setState(() {});
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Colors.red.withOpacity(0.8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text("Remove",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
            ),
          );
        },
      ),
    );
  }
}
