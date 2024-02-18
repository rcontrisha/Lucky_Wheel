import 'package:flutter/material.dart';

import '../flutter_fortune_wheel.dart';
import '../widgets/fortune_item.dart';

class FortuneTemplatesDetailPage extends StatelessWidget {
  const FortuneTemplatesDetailPage({
    Key? key,
    required this.title,
    required this.fortuneValues,
  }) : super(key: key);

  final String title;
  final List<Fortune> fortuneValues;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        itemCount: fortuneValues.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return FortuneItem(
            key: ValueKey<String>(
                'fortuneWheelItem<${fortuneValues[index].id}>'),
            fortune: fortuneValues[index],
            isShowAction: false,
            onChanged: (Fortune value) {
              Null;
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      ),
    );
  }
}
