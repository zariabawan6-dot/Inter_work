import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;
  final String title;
  final String description;
  final bool done;
  final List<String> images;

  const TaskDetailPage({
    super.key,
    required this.taskId,
    required this.title,
    required this.description,
    required this.done,
    required this.images,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final notesController = TextEditingController();
  final codeController = TextEditingController();

  List<File> submissionImages = [];
  List<File> attachedFiles = [];

  /// 📷 IMAGES
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    setState(() {
      submissionImages.addAll(picked.map((e) => File(e.path)));
    });
  }

  /// 📁 FILES (PDF / DOC / ZIP)
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'zip'],
    );

    if (result != null) {
      setState(() {
        attachedFiles.addAll(
          result.paths.map((e) => File(e!)).toList(),
        );
      });
    }
  }

  /// 🚀 SUBMIT TASK
  Future<void> submitTask() async {
    if (attachedFiles.isEmpty && submissionImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please attach at least one file"),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("tasks")
        .doc(widget.taskId)
        .update({
      "done": true,
      "status": "submitted",
      "submission": {
        "notes": notesController.text,
        "code": codeController.text,
        "images": submissionImages.map((e) => e.path).toList(),
        "files": attachedFiles.map((e) => e.path).toList(),
        "submittedAt": DateTime.now().toIso8601String(),
      }
    });

    /// ✅ SUCCESS MESSAGE
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Task Uploaded Successfully"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    /// ⏳ WAIT THEN GO BACK HOME
    await Future.delayed(const Duration(milliseconds: 800));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(title: Text(widget.title)),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// DESCRIPTION BOX
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  widget.description,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Submit Work",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),

              const SizedBox(height: 10),

              /// NOTES
              TextField(
                controller: notesController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Write notes...",
                  hintStyle: TextStyle(color: Colors.white38),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// CODE
              TextField(
                controller: codeController,
                maxLines: 6,
                style: const TextStyle(color: Colors.greenAccent),
                decoration: const InputDecoration(
                  hintText: "Paste code here...",
                  hintStyle: TextStyle(color: Colors.white38),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// IMAGE PICK
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: pickImages,
                      child: const Icon(Icons.add_a_photo, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${submissionImages.length} images",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// FILE PICK
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: pickFiles,
                      child: const Icon(Icons.attach_file, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${attachedFiles.length} files",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: submitTask,
                  child: const Text("Submit Task"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color(0xFF0A0A0A),
  //
  //     appBar: AppBar(title: Text(widget.title)),
  //
  //     body: SingleChildScrollView(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //
  //           Text(widget.description,
  //               style: const TextStyle(color: Colors.white70)),
  //
  //           const SizedBox(height: 20),
  //
  //           const Text("Submit Work",
  //               style: TextStyle(color: Colors.white, fontSize: 18)),
  //
  //           const SizedBox(height: 10),
  //
  //           TextField(
  //             controller: notesController,
  //             maxLines: 3,
  //             style: const TextStyle(color: Colors.white),
  //             decoration: const InputDecoration(
  //               hintText: "Notes",
  //               hintStyle: TextStyle(color: Colors.white38),
  //             ),
  //           ),
  //
  //           TextField(
  //             controller: codeController,
  //             maxLines: 6,
  //             style: const TextStyle(color: Colors.greenAccent),
  //             decoration: const InputDecoration(
  //               hintText: "Code",
  //               hintStyle: TextStyle(color: Colors.white38),
  //             ),
  //           ),
  //
  //           const SizedBox(height: 15),
  //
  //           /// IMAGE PICK
  //           Row(
  //             children: [
  //               GestureDetector(
  //                 onTap: pickImages,
  //                 child: const Icon(Icons.add_a_photo,
  //                     color: Colors.white),
  //               ),
  //               const SizedBox(width: 10),
  //               Text("${submissionImages.length} images",
  //                   style: const TextStyle(color: Colors.white)),
  //             ],
  //           ),
  //
  //           const SizedBox(height: 10),
  //
  //           /// FILE PICK
  //           Row(
  //             children: [
  //               GestureDetector(
  //                 onTap: pickFiles,
  //                 child: const Icon(Icons.attach_file,
  //                     color: Colors.white),
  //               ),
  //               const SizedBox(width: 10),
  //               Text("${attachedFiles.length} files",
  //                   style: const TextStyle(color: Colors.white)),
  //             ],
  //           ),
  //
  //           const SizedBox(height: 20),
  //
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton(
  //               onPressed: submitTask,
  //               child: const Text("Submit Task "),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
//     );
//   }
// }




// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class TaskDetailPage extends StatefulWidget {
//   final String title;
//   final String description;
//   final bool done;
//   final List<String> images; // ⭐ NEW
//
//   const TaskDetailPage({
//     super.key,
//     required this.title,
//     required this.description,
//     required this.done,
//     required this.images,
//   });
//
//   @override
//   State<TaskDetailPage> createState() => _TaskDetailPageState();
// }
//
// class _TaskDetailPageState extends State<TaskDetailPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A0A),
//
//       appBar: AppBar(title: const Text("Task Details")),
//
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//
//             /// TITLE CARD
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white10,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.white24),
//               ),
//               child: Text(
//                 widget.title,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             Text(
//               widget.done ? "Completed ✅" : "Pending ⏳",
//               style: TextStyle(
//                 color: widget.done ? Colors.green : Colors.orange,
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             /// DESCRIPTION (BIGGER AREA)
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white10,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.white24),
//               ),
//               child: Text(
//                 widget.description,
//                 style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 16,
//                   height: 1.4,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             const Text(
//               "Images",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             /// IMAGES GRID (FROM FIRESTORE)
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               children: widget.images.map((imgPath) {
//                 return ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Image.file(
//                     File(imgPath),
//                     height: 100,
//                     width: 100,
//                     fit: BoxFit.cover,
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

