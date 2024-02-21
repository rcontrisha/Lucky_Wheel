import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common/constants.dart';
import '../flutter_fortune_wheel.dart';
import '../widgets/custom_form_fortune_add_edit.dart';
import '../widgets/fortune_item.dart';
import '../widgets/fortune_template.dart';

class FortuneWheelSettingPage extends StatefulWidget {
  final Wheel wheel;
  final void Function(Wheel)
      onWheelUpdated; // Deklarasi parameter onWheelUpdated

  const FortuneWheelSettingPage({
    Key? key,
    required this.wheel,
    required this.onWheelUpdated, // Tambahkan parameter onWheelUpdated dalam konstruktor
  }) : super(key: key);

  @override
  _FortuneWheelSettingPageState createState() =>
      _FortuneWheelSettingPageState();
}

class _FortuneWheelSettingPageState extends State<FortuneWheelSettingPage> {
  late Wheel _wheel;

  final TextEditingController _durationWheelController =
      TextEditingController();

  late final StreamController<bool> _fortuneValuesController;

  final TextEditingController spinPrize = TextEditingController();

  final TextEditingController _wheelTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _wheel = widget.wheel;
    _durationWheelController.text = _wheel.duration.inSeconds.toString();
    spinPrize.text = _wheel.spinPrize ?? '';
    _wheelTitleController.text = _wheel.title ?? '';
    _fortuneValuesController = StreamController<bool>.broadcast();
  }

  @override
  void dispose() {
    super.dispose();
    _durationWheelController.dispose();
    _wheelTitleController.dispose();
    _fortuneValuesController.close();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleConfirmBack();
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFC8E6C9),
          appBar: AppBar(
            title: const Text('Settings'),
            actions: [
              IconButton(
                splashRadius: 28,
                tooltip: 'Save',
                onPressed: () {
                  Navigator.pop(context, _wheel);
                },
                icon: const Icon(Icons.save),
              ),
            ],
          ),
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              _buildWheelTitle(),
              _buildGameMode(),
              _buildDuration(),
              _buildEditPrize(),
              _buildExpansionFortuneValues(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleConfirmBack() {
    Widget cancelButton = TextButton(
      child: const Text('Cancel'),
      onPressed: () {
        Navigator.pop(context);
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
      ),
    );
    Widget okButton = TextButton(
      child: const Text('Confirm'),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
      ),
    );

    AlertDialog alert = AlertDialog(
      title: const Text('Warning'),
      content: const Text(
          'Are you sure you want to go back without saving the changed configuration?'),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _buildWheelTitle() {
    return ListTile(
      title: const Text(
        'Wheel Title',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 16),
        child: TextFormField(
          controller: _wheelTitleController,
          keyboardType: TextInputType.text,
          onChanged: (value) {
            _wheel = _wheel.copyWith(
              title: _wheelTitleController.text,
            );
          },
          decoration: const InputDecoration(
            hintText: 'Enter wheel title',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildGameMode() {
    return ListTile(
      title: const Text(
        'Spin Mode',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            horizontalTitleGap: 0.0,
            visualDensity: const VisualDensity(vertical: -4, horizontal: 0),
            onTap: () {
              setState(() {
                _wheel = _wheel.copyWith(isSpinByPriority: true);
              });
            },
            title: const Text('The priority mode'),
            leading: Radio<bool>(
              value: true,
              groupValue: _wheel.isSpinByPriority,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (_) {
                setState(() {
                  _wheel = _wheel.copyWith(isSpinByPriority: true);
                });
              },
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            horizontalTitleGap: 0.0,
            visualDensity: const VisualDensity(vertical: -4, horizontal: 0),
            title: const Text('Random mode'),
            onTap: () {
              setState(() {
                _wheel = _wheel.copyWith(isSpinByPriority: false);
              });
            },
            leading: Radio<bool>(
              value: false,
              groupValue: _wheel.isSpinByPriority,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (_) {
                setState(() {
                  _wheel = _wheel.copyWith(isSpinByPriority: false);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuration() {
    return ListTile(
      title: Row(
        children: [
          const Text(
            'Spin time (s)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              int second = int.tryParse(_durationWheelController.text) ?? 0;
              if (second > 1) {
                second--;
                _wheel = _wheel.copyWith(duration: Duration(seconds: second));
                _durationWheelController.text = second.toString();
                setState(() {});
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(8)),
              child: Transform.rotate(
                angle: pi / 2,
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: TextField(
              controller: _durationWheelController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration:
                  const InputDecoration.collapsed(hintText: 'Enter spin time'),
              onChanged: (String? value) {
                if (value == '') {
                  _durationWheelController.text = '1';
                }
                int? second = int.tryParse(_durationWheelController.text);
                if (second != null) {
                  _wheel = _wheel.copyWith(duration: Duration(seconds: second));
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              int second = int.tryParse(_durationWheelController.text) ?? 0;
              second++;
              _wheel = _wheel.copyWith(duration: Duration(seconds: second));
              _durationWheelController.text = second.toString();
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(8)),
              child: Transform.rotate(
                angle: -pi / 2,
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditPrize() {
    return ListTile(
      title: const Text(
        'Wheel Prize (Spin Button)',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 16),
        child: TextFormField(
          controller: spinPrize,
          keyboardType: TextInputType.text,
          onChanged: (value) {
            _wheel = _wheel.copyWith(
              spinPrize: spinPrize.text,
            );
          },
          decoration: const InputDecoration(
            hintText: 'Enter Wheel Prize',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionFortuneValues() {
    return ExpansionTile(
      initiallyExpanded: true,
      title: const Text(
        'Spin Value',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      childrenPadding: const EdgeInsets.only(left: 16),
      children: [
        Row(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                    onPressed: _handleInsertItem,
                    child: const Text('+ Add new'))),
            const SizedBox(width: 16),
            Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                    onPressed: _handleGetDefaultTemplate,
                    child: const Text('Choose default template'))),
          ],
        ),
        _buildFortuneValues(),
      ],
    );
  }

  Widget _buildFortuneValues() {
    return StreamBuilder<bool>(
      stream: _fortuneValuesController.stream,
      builder: (context, snapshot) {
        return ListView.separated(
          key: const ValueKey<String>('FortuneValues'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _wheel.items.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) => FortuneItem(
            key:
                ValueKey<String>('fortuneWheelItem<${_wheel.items[index].id}>'),
            fortune: _wheel.items[index],
            onEditPressed: () => _handleEditFortuneItemPressed(index),
            onDeletePressed: () => _handleDeleteFortuneItemPressed(index),
            onChanged: (newFortune) {
              _wheel.items[index] = newFortune;
              widget.onWheelUpdated(
                  _wheel); // Panggil fungsi callback saat nilai berubah
              setState(() {}); // Update the UI
            },
          ),
          separatorBuilder: (context, index) => const Divider(),
        );
      },
    );
  }

  void _handleGetDefaultTemplate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        TextEditingController controllerStart = TextEditingController();
        TextEditingController controllerEnd = TextEditingController();

        return AlertDialog(
          title: const Text('Create Custom Template'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controllerStart,
                decoration:
                    const InputDecoration(labelText: 'Enter Range Start'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: controllerEnd,
                decoration: const InputDecoration(labelText: 'Enter Range End'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () {
                  int start = int.tryParse(controllerStart.text) ?? 1;
                  int end = int.tryParse(controllerEnd.text) ?? 10;

                  List<Fortune> customValues = List.generate(
                    end - start + 1,
                    (index) => Fortune(
                      id: index + 1,
                      titleName: '${start + index}', // Use a meaningful title
                      backgroundColor: Colors
                          .primaries[Random().nextInt(Colors.primaries.length)],
                    ),
                  );

                  FortuneTemplate customTemplate = FortuneTemplate(
                    title: 'Custom Range ($start - $end)',
                    fortuneValues: customValues,
                    onPressed: () {
                      _wheel = _wheel.copyWith(items: customValues);
                      _fortuneValuesController.sink.add(true);
                      Navigator.pop(context);
                    },
                  );

                  _showConfirmationDialog(customTemplate);
                },
                child: const Text('Create Template'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(FortuneTemplate template) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Template'),
          content: Text(
              'Are you sure you want to use the template "${template.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _wheel = _wheel.copyWith(items: template.fortuneValues);
                _fortuneValuesController.sink.add(true);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleInsertItem() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: CustomFormFortuneAddEdit(
            isInsert: true,
            fortuneItem: Fortune(
              id: _wheel.items.length + 1,
              titleName: '',
              backgroundColor:
                  Colors.primaries[Random().nextInt(Colors.primaries.length)],
            ),
            onChanged: (fortuneItem) {
              _wheel.items.add(fortuneItem);
              _fortuneValuesController.sink.add(true);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Future<void> _handleEditFortuneItemPressed(int index) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: CustomFormFortuneAddEdit(
            fortuneItem: _wheel.items[index],
            onChanged: (fortuneItem) {
              _wheel.items[index] = fortuneItem;
              _fortuneValuesController.sink.add(true);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _handleDeleteFortuneItemPressed(int index) {
    Widget cancelButton = TextButton(
      child: const Text('Cancel'),
      onPressed: () {
        Navigator.pop(context);
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
      ),
    );
    Widget okButton = TextButton(
      child: const Text('Confirm'),
      onPressed: () {
        Navigator.pop(context);
        _wheel.items.removeAt(index);
        _fortuneValuesController.sink.add(true);
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
      ),
    );

    AlertDialog alert = AlertDialog(
      title: const Text('Warning'),
      content: const Text('Are you sure you want to delete this value?'),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
