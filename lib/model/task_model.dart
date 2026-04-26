class TaskModel {
  String id;
  String title;
  String description;
  bool done;
  List<String> images; // ⭐ NEW

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.done = false,
    this.images = const [], // ⭐ NEW
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "done": done,
      "images": images, // ⭐ NEW
    };
  }

  static TaskModel fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      title: map["title"] ?? "",
      description: map["description"] ?? "",
      done: map["done"] ?? false,
      images: List<String>.from(map["images"] ?? []), // ⭐ NEW
    );
  }
}