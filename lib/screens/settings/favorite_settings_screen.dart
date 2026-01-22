import 'package:flutter/material.dart';
import '../../models/category_tag.dart';
import '../../repositories/settings_repository.dart';

class FavoriteSettingsScreen extends StatefulWidget {
  const FavoriteSettingsScreen({super.key});

  @override
  State<FavoriteSettingsScreen> createState() => _FavoriteSettingsScreenState();
}

class _FavoriteSettingsScreenState extends State<FavoriteSettingsScreen> {
  final SettingsRepository _repository = SettingsRepository();
  List<String> _currentFavorites = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _repository.loadFavorites();
    setState(() {
      // ▼▼ 修正: ここで List.from() を使い、必ず「書き換え可能なコピー」を作成する ▼▼
      // これをしないと、デフォルト設定（constリスト）の場合に変更できずエラーになる
      _currentFavorites = List<String>.from(list);
    });
  }

  Future<void> _toggleFavorite(String key) async {
    setState(() {
      if (_currentFavorites.contains(key)) {
        _currentFavorites.remove(key);
      } else {
        _currentFavorites.add(key);
      }
    });
    // 保存処理
    await _repository.saveFavorites(_currentFavorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('お気に入り設定')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          _buildSectionHeader('費目ショートカット'),
          _buildCheckTile(
            const CategoryTag('デフォルト', Colors.blueGrey),
            'expense',
          ),
          ...expenseTags.map((tag) => _buildCheckTile(tag, 'expense')),

          const Divider(),

          _buildSectionHeader('支払い方法ショートカット'),
          _buildCheckTile(const CategoryTag('デフォルト', Colors.grey), 'payment'),
          ...paymentTags.map((tag) => _buildCheckTile(tag, 'payment')),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 5),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.blue.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCheckTile(CategoryTag tag, String type) {
    final key = '$type:${tag.label}';
    final isChecked = _currentFavorites.contains(key);

    return CheckboxListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Row(
        children: [
          Icon(
            type == 'payment' ? Icons.payment : Icons.label,
            color: tag.color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(tag.label),
        ],
      ),
      value: isChecked,
      // チェックボックスだけでなく行全体タップで反応
      onChanged: (bool? value) => _toggleFavorite(key),
      activeColor: Colors.blue,
    );
  }
}
