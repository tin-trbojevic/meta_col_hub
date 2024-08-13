import 'package:flutter/material.dart';

class AddCollocationScreen extends StatelessWidget {
  final Function(String base, String collocation, String example) onSave;

  AddCollocationScreen({required this.onSave});

  final TextEditingController baseController = TextEditingController();
  final TextEditingController collocationController = TextEditingController();
  final TextEditingController exampleController = TextEditingController();

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
            SizedBox(height: 50),
            TextField(
              controller: baseController,
              decoration: InputDecoration(
                labelText: 'Base',
              ),
              cursorColor: Colors.lightBlue,
            ),
            SizedBox(height: 10),
            TextField(
              controller: collocationController,
              decoration: InputDecoration(
                labelText: 'Collocation',
              ),
              cursorColor: Colors.lightBlue,
            ),
            SizedBox(height: 10),
            TextField(
              controller: exampleController,
              decoration: InputDecoration(
                labelText: '"Example"',
              ),
              cursorColor: Colors.lightBlue,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); 
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
                    onSave(
                      baseController.text,
                      collocationController.text,
                      exampleController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
