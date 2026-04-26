// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class CounterPage extends StatefulWidget {
//   const CounterPage({super.key});
//
//   @override
//   State<CounterPage> createState() => _CounterPageState();
// }
//
// class _CounterPageState extends State<CounterPage> {
//   int count = 0;
//   List<String> history = [];
//
//   final nameController = TextEditingController();
//
//   int? selectedIndex;
//   int _idCounter = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     load();
//   }
//
//   /// 📦 LOAD DATA
//   void load() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     setState(() {
//       count = prefs.getInt('count') ?? 0;
//       history = prefs.getStringList('history') ?? [];
//       _idCounter = prefs.getInt('idCounter') ?? 0;
//     });
//   }
//
//   /// 💾 SAVE LIVE COUNT
//   void saveLiveCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setInt('count', count);
//   }
//
//   /// 🚨 SAVE / UPDATE HISTORY (FIXED SYSTEM)
//   void saveHistory() async {
//     if (nameController.text.trim().isEmpty) {
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           backgroundColor: const Color(0xFF1A1A1A),
//           title: const Text(
//             "Missing Name",
//             style: TextStyle(color: Colors.white),
//           ),
//           content: const Text(
//             "Please give a name before saving.",
//             style: TextStyle(color: Colors.white70),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             )
//           ],
//         ),
//       );
//       return;
//     }
//
//     final prefs = await SharedPreferences.getInstance();
//
//     String entry =
//         "${selectedIndex ?? _idCounter}|${nameController.text.trim()}|$count";
//
//     setState(() {
//       if (selectedIndex != null) {
//         history[selectedIndex!] = entry; // UPDATE
//       } else {
//         history.add(entry); // NEW
//         _idCounter++;
//       }
//
//       selectedIndex = null;
//       nameController.clear();
//     });
//
//     await prefs.setStringList('history', history);
//     await prefs.setInt('idCounter', _idCounter);
//   }
//
//   /// 📂 LOAD FROM HISTORY
//   void loadFromHistory(int i) {
//     final parts = history[i].split("|");
//
//     setState(() {
//       nameController.text = parts.length > 1 ? parts[1] : "";
//       count = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
//       selectedIndex = i;
//     });
//
//     saveLiveCount();
//   }
//
//   /// 🗑 DELETE ITEM
//   void deleteItem(int i) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     setState(() {
//       history.removeAt(i);
//       selectedIndex = null;
//     });
//
//     prefs.setStringList('history', history);
//   }
//
//   /// ➕➖ ACTIONS
//   void increment() {
//     setState(() => count++);
//     saveLiveCount();
//   }
//
//   void decrement() {
//     setState(() => count--);
//     saveLiveCount();
//   }
//
//   void reset() {
//     setState(() {
//       count = 0;
//       selectedIndex = null;
//       nameController.clear();
//     });
//     saveLiveCount();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A0A),
//
//       appBar: AppBar(
//         title: const Text("Tasbeeh Counter"),
//         elevation: 0,
//       ),
//
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//
//             /// 🔢 COUNTER CARD
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(25),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1A1A1A),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     "Current Count",
//                     style: TextStyle(color: Colors.white54),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     "$count",
//                     style: const TextStyle(
//                       fontSize: 55,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             /// ✏️ INPUT
//             TextField(
//               controller: nameController,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: "Enter name (e.g. Tasbeeh)",
//                 hintStyle: const TextStyle(color: Colors.white54),
//                 filled: true,
//                 fillColor: const Color(0xFF1A1A1A),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             /// 💾 SAVE BUTTON
//             SizedBox(
//               width: double.infinity,
//               height: 45,
//               child: ElevatedButton(
//                 onPressed: saveHistory,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor:
//                   selectedIndex != null ? Colors.orange : Colors.blueAccent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: Text(
//                   selectedIndex != null ? "Update Record" : "Save Record",
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 15),
//
//             /// 📜 HISTORY TITLE
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "History",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             /// 📜 HISTORY LIST
//             Expanded(
//               child: ListView.builder(
//                 itemCount: history.length,
//                 itemBuilder: (_, i) {
//                   final parts = history[i].split("|");
//
//                   String title = parts.length > 1 ? parts[1] : "Unknown";
//                   String value = parts.length > 2 ? parts[2] : "0";
//
//                   return Dismissible(
//                     key: Key(history[i]),
//                     direction: DismissDirection.endToStart,
//
//                     confirmDismiss: (_) async {
//                       return await showDialog(
//                         context: context,
//                         builder: (_) => AlertDialog(
//                           backgroundColor: const Color(0xFF1A1A1A),
//                           title: const Text(
//                             "Delete Record?",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                           content: const Text(
//                             "Do you want to delete this record?",
//                             style: TextStyle(color: Colors.white70),
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () =>
//                                   Navigator.pop(context, false),
//                               child: const Text("No"),
//                             ),
//                             TextButton(
//                               onPressed: () =>
//                                   Navigator.pop(context, true),
//                               child: const Text(
//                                 "Yes",
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//
//                     onDismissed: (_) {
//                       deleteItem(i);
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Record Deleted"),
//                         ),
//                       );
//                     },
//
//                     background: Container(
//                       alignment: Alignment.centerRight,
//                       padding: const EdgeInsets.only(right: 20),
//                       color: Colors.red,
//                       child: const Icon(Icons.delete, color: Colors.white),
//                     ),
//
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 10),
//                       padding: const EdgeInsets.all(15),
//                       decoration: BoxDecoration(
//                         color: selectedIndex == i
//                             ? Colors.blueAccent.withOpacity(0.3)
//                             : const Color(0xFF1A1A1A),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//
//                       child: GestureDetector(
//                         onTap: () => loadFromHistory(i),
//
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(title,
//                                 style: const TextStyle(color: Colors.white)),
//                             Text(value,
//                                 style: const TextStyle(color: Colors.white54)),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       /// ➕ ➖ RESET BUTTONS
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 10),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             FloatingActionButton(
//               heroTag: "add",
//               backgroundColor: Colors.blueAccent,
//               onPressed: increment,
//               child: const Icon(Icons.add),
//             ),
//             const SizedBox(height: 10),
//             FloatingActionButton(
//               heroTag: "remove",
//               backgroundColor: Colors.orange,
//               onPressed: decrement,
//               child: const Icon(Icons.remove),
//             ),
//             const SizedBox(height: 10),
//             FloatingActionButton(
//               heroTag: "reset",
//               backgroundColor: Colors.red,
//               onPressed: reset,
//               child: const Icon(Icons.refresh),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int count = 0;
  List<String> history = [];

  final nameController = TextEditingController();

  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    load();
  }

  /// 📦 LOAD DATA
  void load() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      count = prefs.getInt('count') ?? 0;
      history = prefs.getStringList('history') ?? [];
    });
  }

  /// 💾 SAVE COUNT
  void saveLiveCount() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('count', count);
  }

  /// 🚨 SAVE OR UPDATE HISTORY
  void saveCount() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    String entry = "${nameController.text.trim()} : $count";

    setState(() {
      if (selectedIndex != null &&
          selectedIndex! < history.length &&
          selectedIndex! >= 0) {
        history[selectedIndex!] = entry; // UPDATE OLD
      } else {
        history.add(entry); // NEW
      }

      selectedIndex = null;
      nameController.clear();
    });

    prefs.setStringList('history', history);
  }

  /// 📂 LOAD FOR EDIT
  void loadFromHistory(int i) {
    final parts = history[i].split(" : ");

    setState(() {
      nameController.text = parts[0];
      count = int.tryParse(parts[1]) ?? 0;
      selectedIndex = i;
    });

    saveLiveCount();
  }

  /// 🗑 DELETE ITEM
  void deleteItem(int i) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      history.removeAt(i);
      selectedIndex = null;
    });

    prefs.setStringList('history', history);
  }

  /// ➕ ➖ RESET
  void increment() {
    setState(() => count++);
    saveLiveCount();
  }

  void decrement() {
    setState(() => count--);
    saveLiveCount();
  }

  void reset() {
    setState(() {
      count = 0;
      selectedIndex = null;
      nameController.clear();
    });
    saveLiveCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(
        title: const Text("Tasbeeh Counter"),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔢 COUNTER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text("Count",
                      style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 10),
                  Text(
                    "$count",
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ✏️ INPUT
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter name (e.g. Tasbeeh)",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// 💾 SAVE / UPDATE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveCount,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  selectedIndex != null ? Colors.orange : Colors.blueAccent,
                ),
                child: Text(
                  selectedIndex != null ? "Update Record" : "Save Record",
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "History",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            /// 📜 HISTORY LIST (SWIPE DELETE + TAP EDIT)
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (_, i) {
                  return Dismissible(
                    key: Key(history[i]),
                    direction: DismissDirection.endToStart,

                    confirmDismiss: (_) async {
                      return await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1A1A),
                          title: const Text(
                            "Delete?",
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            "Do you want to delete this record?",
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text("No")),
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text("Yes",
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                    },

                    onDismissed: (_) => deleteItem(i),

                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete,
                          color: Colors.white),
                    ),

                    child: GestureDetector(
                      onTap: () => loadFromHistory(i),

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: selectedIndex == i
                              ? Colors.blueAccent.withOpacity(0.3)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          history[i],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      /// ➕ ➖ RESET BUTTONS
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: increment,
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: decrement,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: reset,
            backgroundColor: Colors.red,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}






//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class CounterPage extends StatefulWidget {
//   const CounterPage({super.key});
//
//   @override
//   State<CounterPage> createState() => _CounterPageState();
// }
//
// class _CounterPageState extends State<CounterPage> {
//   int count = 0;
//
//   List<String> history = [];
//
//   final nameController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     load();
//   }
//
//   void load() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     setState(() {
//       count = prefs.getInt('count') ?? 0;
//       history = prefs.getStringList('history') ?? [];
//     });
//   }
//
//   void saveCount() async {
//     if (nameController.text.isEmpty) return;
//
//     final prefs = await SharedPreferences.getInstance();
//
//     String entry = "${nameController.text} : $count";
//
//     setState(() {
//       history.add(entry);
//       nameController.clear();
//     });
//
//     prefs.setStringList('history', history);
//   }
//
//   void saveLiveCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setInt('count', count);
//   }
//
//   void increment() {
//     setState(() => count++);
//     saveLiveCount();
//   }
//
//   void decrement() {
//     setState(() => count--);
//     saveLiveCount();
//   }
//
//   void reset() {
//     setState(() => count = 0);
//     saveLiveCount();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A0A),
//
//       appBar: AppBar(
//         title: const Text("Tasbeeh Counter"),
//         elevation: 0,
//       ),
//
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//
//             /// 🔢 BIG COUNTER DISPLAY
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(30),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1A1A1A),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     "Count",
//                     style: TextStyle(color: Colors.white54),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     "$count",
//                     style: const TextStyle(
//                       fontSize: 50,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             /// ✏️ NAME INPUT
//             TextField(
//               controller: nameController,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: "Enter name (e.g. Tasbeeh)",
//                 hintStyle: const TextStyle(color: Colors.white54),
//                 filled: true,
//                 fillColor: const Color(0xFF1A1A1A),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             /// 💾 SAVE BUTTON
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: saveCount,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                 ),
//                 child: const Text("Save Record"),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             /// 📜 HISTORY TITLE
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "History",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             /// 📜 HISTORY LIST
//             Expanded(
//               child: ListView.builder(
//                 itemCount: history.length,
//                 itemBuilder: (_, i) {
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 10),
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1A1A1A),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       history[i],
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       /// ➕ ➖ RESET BUTTONS
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             backgroundColor: Colors.blueAccent,
//             onPressed: increment,
//             child: const Icon(Icons.add),
//           ),
//           const SizedBox(height: 10),
//           FloatingActionButton(
//             backgroundColor: Colors.orange,
//             onPressed: decrement,
//             child: const Icon(Icons.remove),
//           ),
//           const SizedBox(height: 10),
//           FloatingActionButton(
//             backgroundColor: Colors.red,
//             onPressed: reset,
//             child: const Icon(Icons.refresh),
//           ),
//         ],
//       ),
//     );
//   }
// }