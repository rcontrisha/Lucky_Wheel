import 'package:flutter/material.dart';
import 'package:pojek_lucky_wheel/flutter_fortune_wheel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FortuneWheelHistoryPage extends StatefulWidget {
  final List<Fortune> resultsHistory;

  const FortuneWheelHistoryPage({
    Key? key,
    required this.resultsHistory, // Tambahkan parameter ini
  }) : super(key: key);

  @override
  _FortuneWheelHistoryPageState createState() =>
      _FortuneWheelHistoryPageState();
}

class _FortuneWheelHistoryPageState extends State<FortuneWheelHistoryPage> {
  late Future<List<SpinHistory>> _spinHistory;

  @override
  void initState() {
    super.initState();
    _spinHistory = _fetchSpinHistory();
  }

  Future<Database> _openDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'spin_history.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE spin_history(id INTEGER PRIMARY KEY, title TEXT, time TEXT, result TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> _insertSpinHistory(SpinHistory spinHistory) async {
    final Database db = await _openDatabase();
    await db.insert(
      'spin_history',
      spinHistory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SpinHistory>> _fetchSpinHistory() async {
    final Database db = await _openDatabase();
    final List<Map<String, dynamic>> maps = await db.query('spin_history');
    return List.generate(maps.length, (i) {
      return SpinHistory(
        id: maps[i]['id'],
        title: maps[i]['title'] ?? '', // Periksa apakah null
        time: maps[i]['time'] ?? '', // Periksa apakah null
        result: maps[i]['result'] ?? '', // Periksa apakah null
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spin history')),
      body: FutureBuilder<List<SpinHistory>>(
        future: _spinHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final spinHistory = snapshot.data!;
          return ListView.separated(
            itemCount: spinHistory.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final history = spinHistory[index];
              return ListTile(
                title: Text('Result ${history.id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time: ${history.time}'),
                    Text('Title: ${history.title}'),
                    Text('Result: ${history.result}'),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          );
        },
      ),
    );
  }
}

class SpinHistory {
  final int id;
  final String title;
  final String time;
  final String result;

  SpinHistory({
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
}
