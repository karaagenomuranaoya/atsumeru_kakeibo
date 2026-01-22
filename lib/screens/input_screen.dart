import 'package:flutter/material.dart';
import '../models/category_tag.dart';
import '../models/transaction_item.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/settings_repository.dart'; // 追加
import '../widgets/category_selector.dart';
import '../widgets/app_drawer.dart';
import 'history_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});
  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TransactionRepository _repository = TransactionRepository();
  final SettingsRepository _settingsRepository = SettingsRepository(); // 追加

  int? _selectedExpenseIndex;
  int? _selectedPaymentIndex;
  DateTime _selectedDate = DateTime.now();

  // お気に入りリスト用データ
  List<Map<String, dynamic>> _favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites(); // お気に入りを読み込む

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_amountFocusNode);
        }
      });
    });
  }

  // お気に入りを読み込んでUI用データに変換する
  Future<void> _loadFavorites() async {
    final favStrings = await _settingsRepository.loadFavorites();
    final List<Map<String, dynamic>> items = [];

    for (var str in favStrings) {
      final parts = str.split(':');
      if (parts.length != 2) continue;

      final type = parts[0];
      final label = parts[1];

      // タグ情報を検索して色などを取得
      CategoryTag? tag;
      if (type == 'expense') {
        if (label == 'デフォルト') {
          tag = const CategoryTag('デフォルト', Colors.blueGrey);
        } else {
          tag = expenseTags.firstWhere(
            (t) => t.label == label,
            orElse: () => CategoryTag(label, Colors.grey),
          );
        }
      } else {
        if (label == 'デフォルト') {
          tag = const CategoryTag('デフォルト', Colors.grey);
        } else {
          tag = paymentTags.firstWhere(
            (t) => t.label == label,
            orElse: () => CategoryTag(label, Colors.grey),
          );
        }
      }

      items.add({
        'icon': type == 'payment' ? Icons.payment : Icons.restaurant, // 簡易アイコン
        // アイコンを細かく分けたい場合は条件分岐を増やす
        // 'icon': type == 'payment' ? Icons.credit_card : Icons.local_offer,
        'color': tag.color,
        'label': tag.label,
        'key': type,
      });
    }

    if (mounted) {
      setState(() {
        _favoriteItems = items;
      });
    }
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ... _pickDate, _saveData は変更なしなので省略可ですが、一応そのまま ...
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveData({required bool shouldDismissKeyboard}) async {
    final amountText = _amountController.text;
    if (amountText.isEmpty ||
        amountText == "0" ||
        int.tryParse(amountText) == null) {
      if (shouldDismissKeyboard) _amountFocusNode.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('金額を入力してください'),
          backgroundColor: Colors.redAccent,
          duration: Duration(milliseconds: 800),
        ),
      );
      return;
    }

    try {
      final newItem = TransactionItem(
        amount: int.parse(amountText),
        expense: _selectedExpenseIndex != null
            ? expenseTags[_selectedExpenseIndex!].label
            : 'デフォルト',
        payment: _selectedPaymentIndex != null
            ? paymentTags[_selectedPaymentIndex!].label
            : 'デフォルト',
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          DateTime.now().hour,
          DateTime.now().minute,
        ),
      );

      await _repository.addTransaction(newItem);

      setState(() {
        _amountController.clear();
        _selectedExpenseIndex = null;
        _selectedPaymentIndex = null;
      });

      if (shouldDismissKeyboard) _amountFocusNode.unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存しました'),
            duration: Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存エラー: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      onDrawerChanged: (isOpened) {
        if (isOpened) _amountFocusNode.unfocus();
      },
      // ▼▼ 修正: Drawerに戻り時のコールバックを渡す ▼▼
      drawer: AppDrawer(onFavoritesUpdated: () => _loadFavorites()),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                    child: Column(
                      children: [
                        _buildAmountInput(),
                        const SizedBox(height: 15),
                        CategorySelector(
                          tags: expenseTags,
                          selectedIndex: _selectedExpenseIndex,
                          rowCount: 2,
                          onSelected: (i) =>
                              setState(() => _selectedExpenseIndex = i),
                        ),
                        const Divider(
                          height: 30,
                          thickness: 1,
                          color: Colors.black12,
                        ),
                        CategorySelector(
                          tags: paymentTags,
                          selectedIndex: _selectedPaymentIndex,
                          rowCount: 2,
                          onSelected: (i) =>
                              setState(() => _selectedPaymentIndex = i),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
            _buildHeaderButtons(),
          ],
        ),
      ),
    );
  }

  // 金額入力欄（変更なし）
  Widget _buildAmountInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '¥ ',
          style: TextStyle(
            fontSize: 44,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: TextField(
            controller: _amountController,
            focusNode: _amountFocusNode,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: '0',
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black12, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: IconButton(
            onPressed: _pickDate,
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                const SizedBox(height: 2),
                Text(
                  "${_selectedDate.month}/${_selectedDate.day}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // アクションボタン（変更なし）
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _saveData(shouldDismissKeyboard: false),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('次へ'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _saveData(shouldDismissKeyboard: true),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('完了'),
            ),
          ),
        ],
      ),
    );
  }

  // ▼▼ 修正: お気に入りボタンの表示ロジック ▼▼
  Widget _buildHeaderButtons() {
    // お気に入りが4つ以下かどうか判定
    final bool isFixedLayout = _favoriteItems.length <= 4;

    return Positioned(
      top: 45,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            // 1. メニューボタン（聖域：常に左端に固定）
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 10),
              child: _buildCircleButton(
                icon: Icons.menu,
                color: Colors.blue,
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),

            // 2. お気に入りエリア
            Expanded(
              child: isFixedLayout
                  // 4つ以下：固定配置 (均等配置、あるいは左寄せ)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _favoriteItems
                          .map((data) => _buildFavItem(data))
                          .toList(),
                    )
                  // 5つ以上：スクロール配置
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 15),
                      child: Row(
                        children: _favoriteItems.map((data) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _buildFavItem(data),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavItem(Map<String, dynamic> data) {
    return _buildCircleButton(
      icon: data['icon'] as IconData,
      color: data['color'] as Color,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryScreen(
              filterValue: data['label'] as String,
              filterKey: data['key'] as String,
              color: data['color'] as Color,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 24),
        onPressed: onTap,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        style: IconButton.styleFrom(padding: const EdgeInsets.all(8)),
      ),
    );
  }
}
