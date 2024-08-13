import 'package:flutter/material.dart';

class EditCollocationScreen extends StatelessWidget {
  final String base;
  final String collocation;
  final String example;

  const EditCollocationScreen({
    Key? key,
    required this.base,
    required this.collocation,
    required this.example,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController baseController = TextEditingController(text: base);
    final TextEditingController collocationController = TextEditingController(text: collocation);
    final TextEditingController exampleController = TextEditingController(text: example);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Collocation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 50),
            TextField(
              controller: baseController,
              decoration: InputDecoration(labelText: 'Base'),
              cursorColor: Colors.lightBlue,
            ),
            SizedBox(height: 10),
            TextField(
              controller: collocationController,
              decoration: InputDecoration(labelText: 'Collocation'),
              cursorColor: Colors.lightBlue,
            ),
            SizedBox(height: 10),
            TextField(
              controller: exampleController,
              decoration: InputDecoration(labelText: '"Example"'),
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
                  child: Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor:
                            Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(
                              color: Colors.grey,
                              width: 2,
                            )
                          )
                        )
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'base': baseController.text,
                      'collocation': collocationController.text,
                      'example': exampleController.text,
                    });
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('Save'),
                  
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
