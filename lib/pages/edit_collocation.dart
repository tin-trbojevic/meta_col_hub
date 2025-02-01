import 'package:flutter/material.dart';

class EditCollocationScreen extends StatelessWidget {
  final String base;
  final String collocation;
  final String example;

  const EditCollocationScreen({
    super.key,
    required this.base,
    required this.collocation,
    required this.example,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController baseController =
        TextEditingController(text: base);
    final TextEditingController collocationController =
        TextEditingController(text: collocation);
    final TextEditingController exampleController =
        TextEditingController(text: example);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Collocation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            TextField(
              controller: baseController,
              decoration: const InputDecoration(labelText: 'Base'),
              cursorColor: Colors.lightBlue,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: collocationController,
              decoration: const InputDecoration(labelText: 'Collocation'),
              cursorColor: Colors.lightBlue,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: exampleController,
              decoration: const InputDecoration(labelText: '"Example"'),
              cursorColor: Colors.lightBlue,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ))),
                    child: const Text('Cancel')),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    if (baseController.text.isEmpty ||
                        collocationController.text.isEmpty ||
                        exampleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('All fields must be filled!')),
                      );
                      return;
                    }

                    Navigator.of(context).pop({
                      'base': baseController.text,
                      'collocation': collocationController.text,
                      'example': exampleController.text,
                    });
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
