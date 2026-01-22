import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_item.dart';

class TransactionRepository {
  static const String _key = 'history';

  // 保存処理
  Future<void> addTransaction(TransactionItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<TransactionItem> currentList = await getAllTransactions();

    // 新しいデータを先頭に追加
    currentList.insert(0, item);

    // JSON文字列に変換して保存
    final String jsonString = json.encode(
      currentList.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_key, jsonString);
  }

  // 全件取得処理
  Future<List<TransactionItem>> getAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => TransactionItem.fromJson(e)).toList();
  }
}
