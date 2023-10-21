

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //get todos
  final CollectionReference qodos = FirebaseFirestore.instance.collection("qodos");

  // add todos
  Future <void> addQodo(String qodo)
  {
    return qodos.add({
      'qodo': qodo,
      'timestamp': Timestamp.now()
    });
  }
//display qodos
 Stream<QuerySnapshot> getQodoStream() {
  final qodoStream = qodos.orderBy('timestamp', descending: true).snapshots();
  return qodoStream;

 }
  //update

Future<void> updateQodo(String docId, String newQodo){
  return qodos.doc(docId).update({
    'qodo' : newQodo,
    'timeStamp': Timestamp.now(),
  });
}

//delete qodo
Future<void> deleteQodo(String docID) {
return qodos.doc(docID).delete();
}

}

