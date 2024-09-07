import 'package:blackcoffer_test_assignment/videoControllerPage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'firestore_api.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class Explorepage extends StatefulWidget {
  const Explorepage({super.key});

  @override
  State<Explorepage> createState() => ExplorepageState();

}

class ExplorepageState extends State<Explorepage> {

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController videoUrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    fetchDataFromFirestore();
  }


  static Future<Map<String, Map<String, dynamic>>> fetchDataFromFirestore() async {

      final List<String> documentIds = await FirestoreApi.listAllDocuments('Public Post');
      Map<String, Map<String, dynamic>> result = {};

      for (String documentId in documentIds) {
        final Map<String, dynamic> documentData = await FirestoreApi.getDocumentData('Public Post', documentId);
        result[documentId] = documentData;
      }
      return result;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MySearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: fetchDataFromFirestore(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return const Center(child: Text('Some error occurred!'));
              } else {
                final Map<String, Map<String, dynamic>> myDocument = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: myDocument.length,
                        itemBuilder: (context, index) {
                          final documentId = myDocument.keys.elementAt(index);
                          final documentData = myDocument[documentId];

                          return buildFile(context, documentData);
                        },
                      ),
                    ),
                  ],
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildFile(BuildContext context, Map<String, dynamic>? documentData) => Padding(
  padding: const EdgeInsets.all(8.0),
  child: Container(
    height: MediaQuery.of(context).size.height * 0.45,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.orange.shade50,
          Colors.orange.shade100,
          Colors.orange.shade200,
          Colors.orange.shade300,
          Colors.orange.shade400,
        ],
      ),
    ),
    child: Center(
      child: FutureBuilder<String?>(
        future: generateThumbnail(documentData?['Video Url']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[350]!,
              highlightColor: Colors.grey[300]!,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height * 0.30,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.15,
                  color: Colors.blueGrey,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            String? thumbnailPath = snapshot.data;
            return SizedBox(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VideoControllerPage(documentData: documentData!),)),
                child: Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(8.0),
                      child: thumbnailPath != null
                        ? Image.file(File(thumbnailPath))
                        : const Placeholder(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(documentData?['Title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(documentData?['Category'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(documentData?['Location'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(documentData?['Description'],
                    ),
                  ]
                ),
              )
            );
          }
        },
      ),
    ),
  ),
);

Future<String> generateThumbnail(String videoUrl) async {
  String? thumbnail = await VideoThumbnail.thumbnailFile(
    video: videoUrl,
    thumbnailPath: (await getTemporaryDirectory()).path,
    imageFormat: ImageFormat.PNG,
    maxHeight: 150,
    quality: 10,
  );
  return thumbnail!;
}

class MySearchDelegate extends SearchDelegate<String> {

  final List<String> recentSearches = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement your search results here based on the titles
    return FutureBuilder<Map<String, Map<String, dynamic>>>(
      future: ExplorepageState.fetchDataFromFirestore(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return const Center(child: Text('Some error occurred!'));
            } else {
              final Map<String, Map<String, dynamic>> myDocument = snapshot.data!;

              final List<Map<String, dynamic>> searchResults = List<Map<String, dynamic>>.from(myDocument.values)
                  .where((documentData) =>
                  documentData['Title']
                      .toLowerCase()
                      .contains(query.toLowerCase()))
                  .toList();

              return ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final documentData = searchResults[index];
                  return buildFile(context, documentData);
                },
              );
            }
        }
      },
    );
  }


  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement your search suggestions here based on the titles
    return FutureBuilder<Map<String, Map<String, dynamic>>>(
      future: ExplorepageState.fetchDataFromFirestore(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return const Center(child: Text('Some error occurred!'));
            } else {
              final Map<String, Map<String, dynamic>> myDocument = snapshot.data!;

              final List suggestionList = List<Map<String, dynamic>>.from(myDocument.values)
                  .where((documentData) =>
                  documentData['Title']
                      .toLowerCase()
                      .contains(query.toLowerCase()))
                  .toList();

              return ListView.builder(
                itemCount: suggestionList.length,
                itemBuilder: (context, index) {
                  final documentData = suggestionList[index];
                  return buildFile(context, documentData);
                },
              );
            }
        }
      },
    );
  }

}
