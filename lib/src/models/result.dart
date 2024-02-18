class SpinResult {
  final int id;
  final String title;
  final String time;
  final String result;

  SpinResult({
    required this.id,
    required this.title,
    required this.time,
    required this.result,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'result': result,
    };
  }

  // Metode untuk membuat objek SpinResult dari map
  static SpinResult fromMap(Map<String, dynamic> map) {
    return SpinResult(
      id: map['id'],
      title: map['title'],
      time: map['time'],
      result: map['result'],
    );
  }
}
