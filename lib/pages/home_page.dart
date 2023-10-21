import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_habits/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firestoreService = FirestoreService();

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  final TextEditingController textcontroller = TextEditingController();

  void openQodoBox({String? docId, String? qodoText}) {
    if (qodoText != null) {
      textcontroller.text = qodoText;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.grey[200],
        content: Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: textcontroller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Enter your Qodo!',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.black, width: 2.0),
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
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
            child: Text(docId == null ? 'Add Qodo' : 'Edit Qodo'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QODOS"),
        backgroundColor: Colors.grey[850],
        elevation: 5.0,
        centerTitle: true,
      ),
      body: Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.grey[300]!, Colors.grey[900]!],
    ),
  ),
    child: StreamBuilder<QuerySnapshot>(
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
),
    );
  }

  Widget customCard(String title, String docId) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 10,
      shadowColor: Colors.black45,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        title: Text(
          capitalizeFirstLetter(title),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
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
