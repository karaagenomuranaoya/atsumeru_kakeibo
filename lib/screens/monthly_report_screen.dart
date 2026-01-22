import 'package:flutter/material.dart';
import '../models/category_tag.dart';
import '../models/transaction_item.dart';
import '../repositories/transaction_repository.dart';

class MonthlyHistoryScreen extends StatefulWidget {
  const MonthlyHistoryScreen({super.key});
  @override
  State<MonthlyHistoryScreen> createState() => _MonthlyHistoryScreenState();
}

class _MonthlyHistoryScreenState extends State<MonthlyHistoryScreen> {
  final PageController _pageController = PageController(initialPage: 1000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('月別レポート')),
      body: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          final d = DateTime(
            DateTime.now().year,
            DateTime.now().month + (index - 1000),
          );
          return MonthPage(year: d.year, month: d.month);
        },
      ),
    );
  }
}

class MonthPage extends StatefulWidget {
  final int year;
  final int month;
  const MonthPage({super.key, required this.year, required this.month});
  @override
  State<MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage> {
  List<TransactionItem> _history = [];
  final TransactionRepository _repository = TransactionRepository();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final allItems = await _repository.getAllTransactions();
    setState(() {
      _history = allItems.where((i) {
        return i.date.year == widget.year && i.date.month == widget.month;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    int total = _history.fold(0, (s, i) => s + i.amount);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            "${widget.year}年 ${widget.month}月",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        _buildSummaryCard(total),
        Expanded(
          child: ListView.builder(
            itemCount: _history.length,
            itemBuilder: (c, i) {
              final item = _history[i];

              // ▼▼ 修正: 費目が「デフォルト」ならカッコごと非表示 ▼▼
              final expenseStr = item.expense == 'デフォルト'
                  ? ''
                  : ' (${item.expense})';

              // ▼▼ 修正: 支払いが「デフォルト」ならスラッシュごと非表示 ▼▼
              final paymentStr = item.payment == 'デフォルト'
                  ? ''
                  : '${item.payment} / ';

              return ListTile(
                title: Text('¥${item.amount}$expenseStr'),
                subtitle: Text('$paymentStr${item.displayDate}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(int total) {
    return Card(
      margin: const EdgeInsets.all(15),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              '¥ $total',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Wrap(
              spacing: 10,
              children: expenseTags.where((t) => t.label != 'デフォルト').map((t) {
                // デフォルト以外の費目を集計表示
                int s = _history
                    .where((i) => i.expense == t.label)
                    .fold(0, (sum, i) => sum + i.amount);
                return s > 0
                    ? Text(
                        '${t.label}: ¥$s',
                        style: TextStyle(
                          color: t.color,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox.shrink();
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
