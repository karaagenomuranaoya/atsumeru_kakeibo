import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../repositories/transaction_repository.dart';

class HistoryScreen extends StatefulWidget {
  final String filterValue;
  final String filterKey; // 'expense' or 'payment'
  final Color? color;

  const HistoryScreen({
    super.key,
    required this.filterValue,
    required this.filterKey,
    this.color,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
        if (widget.filterKey == 'expense')
          return i.expense == widget.filterValue;
        if (widget.filterKey == 'payment')
          return i.payment == widget.filterValue;
        return false;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    int total = _history.fold(0, (s, i) => s + i.amount);
    return Scaffold(
      appBar: AppBar(title: Text(widget.filterValue)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: widget.color?.withOpacity(0.1) ?? Colors.blue.shade50,
            child: Center(
              child: Column(
                children: [
                  Text(
                    widget.filterKey == 'expense' ? '費目累計' : '支払い累計',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    '¥ $total',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.color ?? Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _history.length,
              itemBuilder: (c, i) {
                final item = _history[i];

                // ▼▼ 修正: 追加情報の表示ロジック ▼▼
                String detail = "";
                if (widget.filterKey == 'expense') {
                  // 費目でフィルタ中 → 支払い方法を表示
                  if (item.payment != 'デフォルト') {
                    detail = "  /  ${item.payment}";
                  }
                } else {
                  // 支払いでフィルタ中 → 費目を表示
                  if (item.expense != 'デフォルト') {
                    detail = "  /  ${item.expense}";
                  }
                }

                return ListTile(
                  leading: Icon(
                    widget.filterKey == 'payment' ? Icons.payment : Icons.label,
                    color: widget.color,
                  ),
                  title: Text(
                    '¥${item.amount}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${item.displayDate}$detail"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
