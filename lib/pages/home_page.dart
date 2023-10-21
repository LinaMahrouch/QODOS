import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_habits/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firestore
  final firestoreService = FirestoreService();

  String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }
  return text[0].toUpperCase() + text.substring(1);
}

  // Controller for the user's input
  final TextEditingController textcontroller = TextEditingController();

  // New box
  void openQodoBox({String? docId, String? qodoText}) {
    if (qodoText != null) {
    textcontroller.text = qodoText; // Set the textcontroller's text to the passed noteText.
  }
   else {
    textcontroller.clear(); // Clear the textcontroller if no qodoText is passed.
  }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(   // This will give rounded corners to the AlertDialog
        borderRadius: BorderRadius.circular(20),
      ),
       backgroundColor: Colors.grey[200],
        content: Padding( 
          padding: const EdgeInsets.all(12.0),
          child : TextField(
          controller: textcontroller,
          decoration: InputDecoration(  // Styling for TextField
            hintText: 'Enter your Qodo!',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(  // This is the border when the TextField is focused
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.black, width: 2.0),
    ),
          ),
        ),
        ),
        actions: [
          // Save button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.black, // Text color
          ),
            onPressed: () {
              if (docId == null) {
                firestoreService.addQodo(textcontroller.text);
              } else {
                firestoreService.updateQodo(docId, textcontroller.text);
              }
              textcontroller.clear();
              Navigator.pop(context);
            },
            child: Text(docId == null ? 'Add Qodo' : 'Edit Qodo'),  // Change text based on action
          )
        ],
      ),
    ).then((_) => textcontroller.clear()); // Clear the textcontroller when the dialog is closed.;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QODOS"),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        centerTitle: true, // This will center the AppBar title.

      ),
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: openQodoBox,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getQodoStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List qodosList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: qodosList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = qodosList[index];
                String docId = document.id;
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String qodoText = data['qodo'];

                return customCard(qodoText, docId);
                
              },
            );
          } else {
            return const Center(child: Text("No qodos !!"));
          }
        },
      ),
    );
  }

  Widget customCard(String title, String docId) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shadowColor: Colors.black.withOpacity(0.8),

      child: ListTile(
        title: Text(
          capitalizeFirstLetter(title),
         style: const TextStyle(fontWeight: FontWeight.bold),
         ), // this line makes the text bold),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => openQodoBox(docId: docId, qodoText: title),
              icon: const Icon(
                Icons.edit,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: () => firestoreService.deleteQodo(docId),
              icon: const Icon(
                Icons.delete,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
