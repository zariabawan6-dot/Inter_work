import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intern_work/task/task_detail_page.dart';

class TaskFeedPage extends StatefulWidget {
  const TaskFeedPage({super.key});

  @override
  State<TaskFeedPage> createState() => _TaskFeedPageState();
}

class _TaskFeedPageState extends State<TaskFeedPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  final tasksRef = FirebaseFirestore.instance.collection("tasks");

  List<File> images = [];

  /// 📷 PICK IMAGES
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    setState(() {
      images.addAll(picked.map((e) => File(e.path)));
    });
  }

  /// ➕ CREATE TASK
  Future<void> publishTask() async {
    if (titleController.text.trim().isEmpty) return;

    await tasksRef.add({
      "title": titleController.text.trim(),
      "description": descController.text.trim(),
      "done": false,
      "status": "pending",
      "images": images.map((e) => e.path).toList(),
      "submission": {
        "notes": "",
        "code": "",
        "files": [],
        "submittedAt": null,
      },
      "time": FieldValue.serverTimestamp(),
    });

    setState(() {
      titleController.clear();
      descController.clear();
      images.clear();
    });
  }

  void deleteTask(String id) {
    tasksRef.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(title: const Text("Assign Task Panel")),

      body: Column(
        children: [

          /// CREATE TASK
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [

                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Task Title",
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),

                  TextField(
                    controller: descController,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Task Description",
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: pickImages,
                        child: const Icon(Icons.add_a_photo,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      Text("${images.length} images",
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: publishTask,
                      child: const Text("Publish Task"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(color: Colors.white24),

          /// TASK LIST
          Expanded(
            child: StreamBuilder(
              stream: tasksRef.orderBy("time", descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {

                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final id = doc.id;
                    final status = data["status"] ?? "pending";

                    return Dismissible(
                      key: Key(id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => deleteTask(id),

                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),

                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskDetailPage(
                                taskId: id,
                                title: data["title"] ?? "",
                                description: data["description"] ?? "",
                                done: data["done"] ?? false,
                                images: List<String>.from(
                                    data["images"] ?? []),
                              ),
                            ),
                          );
                        },

                        title: Text(
                          data["title"] ?? "",
                          style: const TextStyle(color: Colors.white),
                        ),

                        subtitle: Text(
                          status,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}




// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intern_work/task/task_detail_page.dart';
//
// class TaskFeedPage extends StatefulWidget {
//   const TaskFeedPage({super.key});
//
//   @override
//   State<TaskFeedPage> createState() => _TaskFeedPageState();
// }
//
// class _TaskFeedPageState extends State<TaskFeedPage> {
//   final titleController = TextEditingController();
//   final descController = TextEditingController();
//
//   final tasksRef = FirebaseFirestore.instance.collection("tasks");
//
//   List<File> selectedImages = [];
//
//   /// 📷 PICK MULTIPLE IMAGES
//   Future<void> pickImages() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickMultiImage();
//
//     if (picked.isNotEmpty) {
//       setState(() {
//         selectedImages.addAll(picked.map((e) => File(e.path)));
//       });
//     }
//   }
//
//   /// 🗑 REMOVE SINGLE IMAGE FROM PREVIEW
//   void removeImage(int index) {
//     setState(() {
//       selectedImages.removeAt(index);
//     });
//   }
//
//   void publishTask() async {
//     if (titleController.text.trim().isEmpty ||
//         descController.text.trim().isEmpty) return;
//
//     await tasksRef.add({
//       "title": titleController.text.trim(),
//       "description": descController.text.trim(),
//       "done": false,
//       "images": selectedImages.map((e) => e.path).toList(),
//       "time": FieldValue.serverTimestamp(),
//     });
//
//     /// ✅ RESET UI (this is what you want instead of hot restart)
//     setState(() {
//       titleController.clear();
//       descController.clear();
//       selectedImages.clear();
//     });
//
//     /// optional UX feedback
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Task Published Successfully")),
//     );
//   }
//
//   /// ✔ TOGGLE DONE
//   void toggleDone(String id, bool value) {
//     tasksRef.doc(id).update({"done": !value});
//   }
//
//   /// 🗑 DELETE TASK
//   void deleteTask(String id) {
//     tasksRef.doc(id).delete();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A0A),
//
//       appBar: AppBar(title: const Text("Task Feed")),
//
//       body: Column(
//         children: [
//
//           /// 🧾 INPUT CARD
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white10,
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(color: Colors.white24),
//               ),
//               child: Column(
//                 children: [
//
//                   /// TITLE
//                   TextField(
//                     controller: titleController,
//                     style: const TextStyle(color: Colors.white),
//                     decoration: InputDecoration(
//                       hintText: "Task Title",
//                       hintStyle: TextStyle(color: Colors.white38),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white24),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 10),
//
//                   /// DESCRIPTION (BIGGER)
//                   TextField(
//                     controller: descController,
//                     maxLines: 5,
//                     style: const TextStyle(color: Colors.white),
//                     decoration: InputDecoration(
//                       hintText: "Task Description (detailed)",
//                       hintStyle: TextStyle(color: Colors.white38),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white24),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 10),
//
//                   /// 📷 IMAGE PICK + PREVIEW
//                   Row(
//                     children: [
//                       GestureDetector(
//                         onTap: pickImages,
//                         child: Container(
//                           height: 60,
//                           width: 60,
//                           decoration: BoxDecoration(
//                             color: Colors.white12,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: const Icon(Icons.add_a_photo,
//                               color: Colors.white),
//                         ),
//                       ),
//
//                       const SizedBox(width: 10),
//
//                       /// PREVIEW MULTIPLE IMAGES
//                       Expanded(
//                         child: SizedBox(
//                           height: 60,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: selectedImages.length,
//                             itemBuilder: (context, index) {
//                               return Stack(
//                                 children: [
//                                   Container(
//                                     margin: const EdgeInsets.only(right: 8),
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(10),
//                                       child: Image.file(
//                                         selectedImages[index],
//                                         height: 60,
//                                         width: 60,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   ),
//
//                                   /// ❌ REMOVE BUTTON
//                                   Positioned(
//                                     right: 0,
//                                     child: GestureDetector(
//                                       onTap: () => removeImage(index),
//                                       child: const Icon(
//                                         Icons.cancel,
//                                         color: Colors.red,
//                                         size: 18,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 10),
//
//                   /// PUBLISH BUTTON
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: publishTask,
//                       child: const Text("Publish Task"),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           const Divider(color: Colors.white24),
//
//           /// 📜 TASK LIST
//           Expanded(
//             child: StreamBuilder(
//               stream: tasksRef.orderBy("time", descending: true).snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 final docs = snapshot.data!.docs;
//
//                 return ListView.builder(
//                   itemCount: docs.length,
//                   itemBuilder: (_, i) {
//                     final data = docs[i];
//
//                     return Dismissible(
//                       key: Key(data.id),
//                       direction: DismissDirection.endToStart,
//                       onDismissed: (_) => deleteTask(data.id),
//
//                       background: Container(
//                         color: Colors.red,
//                         alignment: Alignment.centerRight,
//                         padding: const EdgeInsets.only(right: 20),
//                         child: const Icon(Icons.delete, color: Colors.white),
//                       ),
//
//                       child: Card(
//                         color: Colors.white10,
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 6),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           side: const BorderSide(color: Colors.white24),
//                         ),
//
//                         child: ListTile(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => TaskDetailPage(
//                                   title: data["title"],
//                                   description: data["description"],
//                                   done: data["done"],
//                                   images: List<String>.from(
//                                       data["images"] ?? []),
//                                 ),
//                               ),
//                             );
//                           },
//
//                           title: Text(
//                             data["title"],
//                             style: TextStyle(
//                               color: Colors.white,
//                               decoration: data["done"]
//                                   ? TextDecoration.lineThrough
//                                   : null,
//                             ),
//                           ),
//
//                           subtitle: const Text(
//                             "Tap to open details",
//                             style: TextStyle(color: Colors.white54),
//                           ),
//
//                           trailing: Checkbox(
//                             value: data["done"],
//                             onChanged: (_) =>
//                                 toggleDone(data.id, data["done"]),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




