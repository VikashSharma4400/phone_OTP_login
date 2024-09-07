import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreApi {
  static Future<List<String>> listAllDocuments(String collectionPath) async {
    final collectionReference = FirebaseFirestore.instance.collection(collectionPath);
    final querySnapshot = await collectionReference.get();

    return querySnapshot.docs.map((doc) => doc.id).toList();
  }

  static Future<Map<String, dynamic>> getDocumentData(String collectionPath, String documentId) async {
    final documentReference = FirebaseFirestore.instance.collection(collectionPath).doc(documentId);
    final documentSnapshot = await documentReference.get();

    return documentSnapshot.data() ?? {};
  }
}
