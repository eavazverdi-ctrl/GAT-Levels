import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FxLevelsApp());
}

class FxLevelsApp extends StatelessWidget {
  const FxLevelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FX Levels',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F80ED)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _buyTopCtrl = TextEditingController();
  final _buyHighCtrl = TextEditingController();
  final _buyLowCtrl = TextEditingController();

  final _sellLowCtrl = TextEditingController();
  final _sellHighCtrl = TextEditingController();
  final _sellLow2Ctrl = TextEditingController();

  String buyP1 = '—', buyP2 = '—', buyStop = '—';
  String sellStop = '—', sellP2 = '—', sellP1 = '—';

  @override
  void initState() {
    super.initState();
    for (final c in [
      _buyTopCtrl, _buyHighCtrl, _buyLowCtrl,
      _sellLowCtrl, _sellHighCtrl, _sellLow2Ctrl
    ]) {
      c.addListener(_recalc);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _buyTopCtrl, _buyHighCtrl, _buyLowCtrl,
      _sellLowCtrl, _sellHighCtrl, _sellLow2Ctrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _toDouble(String s) {
    if (s.trim().isEmpty) return null;
    final t = s.replaceAll(',', '.');
    return double.tryParse(t);
  }

  void _recalc() {
    final ht = _toDouble(_buyTopCtrl.text);
    final hiBuy = _toDouble(_buyHighCtrl.text);
    final loBuy = _toDouble(_buyLowCtrl.text);

    final hl = _toDouble(_sellLowCtrl.text);
    final hiSell = _toDouble(_sellHighCtrl.text);
    final loSell = _toDouble(_sellLow2Ctrl.text);

    // BUY formulas
    if (ht != null && hiBuy != null && loBuy != null) {
      final b22 = 2*loBuy - hiBuy;
      final p1 = 2*b22 - (ht + hiBuy)/2.0;
      final p2 = 2*b22 - ht;
      final stop = 2*p2 - p1;
      buyP1 = p1.toStringAsFixed(2);
      buyP2 = p2.toStringAsFixed(2);
      buyStop = stop.toStringAsFixed(2);
    } else {
      buyP1 = buyP2 = buyStop = '—';
    }

    // SELL formulas
    if (hl != null && hiSell != null && loSell != null) {
      final d22 = 2*hiSell - loSell;
      final d23 = (hl + loSell)/2.0;
      final pt2 = 2*d22 - hl;
      final pt1 = 2*d22 - d23;
      final stop = 2*pt2 - pt1;
      sellStop = stop.toStringAsFixed(2);
      sellP2 = pt2.toStringAsFixed(2);
      sellP1 = pt1.toStringAsFixed(2);
    } else {
      sellStop = sellP2 = sellP1 = '—';
    }

    setState(() {});
  }

  void _clearAll() {
    for (final c in [
      _buyTopCtrl, _buyHighCtrl, _buyLowCtrl,
      _sellLowCtrl, _sellHighCtrl, _sellLow2Ctrl
    ]) {
      c.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FX Levels'),
        actions: [
          IconButton(onPressed: _clearAll, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          final buyCard = _SideCard.buy(
            topCtrl: _buyTopCtrl, highCtrl: _buyHighCtrl, lowCtrl: _buyLowCtrl,
            p1: buyP1, p2: buyP2, stop: buyStop,
          );
          final sellCard = _SideCard.sell(
            lowCtrl: _sellLowCtrl, highCtrl: _sellHighCtrl, low2Ctrl: _sellLow2Ctrl,
            p1: sellP1, p2: sellP2, stop: sellStop,
          );
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buyCard),
                Expanded(child: sellCard),
              ],
            );
          } else {
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [buyCard, const SizedBox(height: 12), sellCard],
            );
          }
        },
      ),
    );
  }
}

class _SideCard extends StatelessWidget {
  final String title;
  final Color headerColor;
  final List<Widget> children;

  const _SideCard({required this.title, required this.headerColor, required this.children});

  factory _SideCard.buy({
    required TextEditingController topCtrl,
    required TextEditingController highCtrl,
    required TextEditingController lowCtrl,
    required String p1, required String p2, required String stop,
  }) {
    return _SideCard(
      title: 'خرید',
      headerColor: const Color(0xFFD6F5D2),
      children: [
        _LabeledField(label: 'hunt top', controller: topCtrl),
        _LabeledField(label: 'high', controller: highCtrl),
        _LabeledField(label: 'low', controller: lowCtrl),
        const Divider(),
        _OutputRow(label: 'نقطه اول', value: p1, color: Color(0xFFD8F8D8)), // green
        _OutputRow(label: 'نقطه دوم', value: p2, color: Color(0xFFD8F8D8)), // green
        _OutputRow(label: 'استاپ', value: stop, color: Color(0xFFFFF3C4)),   // yellow
      ],
    );
  }

  factory _SideCard.sell({
    required TextEditingController lowCtrl,
    required TextEditingController highCtrl,
    required TextEditingController low2Ctrl,
    required String p1, required String p2, required String stop,
  }) {
    return _SideCard(
      title: 'فروش',
      headerColor: const Color(0xFFFFD6D6),
      children: [
        _LabeledField(label: 'hunt low', controller: lowCtrl),
        _LabeledField(label: 'high', controller: highCtrl),
        _LabeledField(label: 'low', controller: low2Ctrl),
        const Divider(),
        _OutputRow(label: 'استاپ', value: stop, color: Color(0xFFFFF3C4)),   // yellow
        _OutputRow(label: 'نقطه دوم', value: p2, color: Color(0xFFFFD0D0)),  // red
        _OutputRow(label: 'نقطه اول', value: p1, color: Color(0xFFFFD0D0)),  // red
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: children),
          )
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _LabeledField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          SizedBox(
            width: 160,
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.done,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.\-]'))],
              decoration: const InputDecoration(hintText: 'عدد'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutputRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _OutputRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          )
        ],
      ),
    );
  }
}
