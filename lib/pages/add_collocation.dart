import 'package:flutter/material.dart';

class AddCollocationScreen extends StatefulWidget {
  final Future<void> Function(String base, String collocation, String example)?
      onSave;

  const AddCollocationScreen({Key? key, required this.onSave})
      : super(key: key);

  @override
  State<AddCollocationScreen> createState() => _AddCollocationScreenState();
}

class _AddCollocationScreenState extends State<AddCollocationScreen> {
  final TextEditingController baseController = TextEditingController();
  final TextEditingController collocationController = TextEditingController();
  final TextEditingController exampleController = TextEditingController();
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add your own Collocation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            TextField(
              controller: baseController,
              decoration: const InputDecoration(
                labelText: 'Base',
              ),
              cursorColor: Colors.lightBlue,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: collocationController,
              decoration: const InputDecoration(
                labelText: 'Collocation',
              ),
              cursorColor: Colors.lightBlue,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: exampleController,
              decoration: const InputDecoration(
                labelText: 'Example',
              ),
              cursorColor: Colors.lightBlue,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: const BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (baseController.text.trim().isEmpty ||
                              collocationController.text.trim().isEmpty ||
                              exampleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('All fields must be filled!')),
                            );
                            return;
                          }

                          print('Base: ${baseController.text.trim()}');
                          print('Collocation: ${collocationController.text}');
                          print('Example: ${exampleController.text}');

                          setState(() {
                            isSaving = true;
                          });

                          try {
                            if (widget.onSave != null) {
                              await widget.onSave!(
                                baseController.text.trim(),
                                collocationController.text.trim(),
                                exampleController.text.trim(),
                              );
                            } else {
                              throw Exception('onSave callback is null');
                            }

                            Navigator.of(context).pop();
                          } catch (e) {
                            print('Error during onSave: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Error saving collocation: $e')),
                            );
                          } finally {
                            setState(() {
                              isSaving = false;
                            });
                          }
                        },
                  child: isSaving
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Save'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}