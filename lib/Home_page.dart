import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "User";

  final tasksRef = FirebaseFirestore.instance.collection("tasks");

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "User";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(
        title: const Text("Dashboard"),
        elevation: 0,
      ),

      body: StreamBuilder(
        stream: tasksRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          int total = docs.length;
          int done = docs.where((e) => e["done"] == true).length;
          int pending = total - done;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 👋 HEADER
                Text(
                  "Hello, $name 👋",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Here’s your task overview",
                  style: TextStyle(color: Colors.white54),
                ),

                const SizedBox(height: 20),

                /// 📊 STATS
                Row(
                  children: [
                    buildCard("Total", total, Icons.list, Colors.blue),
                    const SizedBox(width: 10),
                    buildCard("Done", done, Icons.check, Colors.green),
                  ],
                ),

                const SizedBox(height: 10),

                buildCard("Pending", pending, Icons.pending, Colors.orange),

                const SizedBox(height: 20),

                const Text(
                  "Recent Tasks",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                /// 📜 TASK PREVIEW
                Expanded(
                  child: ListView.builder(
                    itemCount: docs.length > 5 ? 5 : docs.length,
                    itemBuilder: (_, i) {
                      final data = docs[i];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              data["done"]
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: data["done"]
                                  ? Colors.green
                                  : Colors.orange,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                data["title"],
                                style: TextStyle(
                                  color: Colors.white,
                                  decoration: data["done"]
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🔥 CARD WIDGET
  Widget buildCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              "$value",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   int total = 0;
//   int completed = 0;
//   String name = "User";
//
//   @override
//   void initState() {
//     super.initState();
//     load();
//   }
//
//   void load() async {
//     final prefs = await SharedPreferences.getInstance();
//     final tasks = prefs.getStringList('tasks') ?? [];
//
//     setState(() {
//       total = tasks.length;
//       completed = tasks.where((t) => t.endsWith("|1")).length;
//       name = prefs.getString("name") ?? "User";
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     int pending = total - completed;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A0A),
//
//       appBar: AppBar(
//         title: const Text("Home"),
//         elevation: 0,
//       ),
//
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//
//             /// 👋 HEADER
//             Text(
//               "Hello, $name 👋",
//               style: const TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//
//             const SizedBox(height: 5),
//
//             const Text(
//               "Manage your tasks efficiently",
//               style: TextStyle(color: Colors.white54),
//             ),
//
//             const SizedBox(height: 25),
//
//             /// 📊 STATS CARDS
//             Row(
//               children: [
//                 buildCard("Total", total, Icons.list, Colors.blue),
//                 const SizedBox(width: 10),
//                 buildCard("Done", completed, Icons.check, Colors.green),
//               ],
//             ),
//
//             const SizedBox(height: 10),
//
//             buildCard("Pending", pending, Icons.pending, Colors.orange),
//
//             const SizedBox(height: 30),
//
//             /// ⚡ QUICK ACTION TEXT
//             const Text(
//               "Quick Actions",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             const Text(
//               "Use bottom navigation to explore 👇",
//               style: TextStyle(color: Colors.white54),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// 🔥 REUSABLE CARD
//   Widget buildCard(String title, int value, IconData icon, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFF1A1A1A),
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 30),
//             const SizedBox(height: 10),
//             Text(
//               "$value",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               title,
//               style: const TextStyle(color: Colors.white54),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }