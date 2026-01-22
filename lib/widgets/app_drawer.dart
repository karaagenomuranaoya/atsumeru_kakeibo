import 'package:flutter/material.dart';
import '../models/category_tag.dart';
import '../screens/monthly_report_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings/settings_screen.dart'; // 追加

class AppDrawer extends StatelessWidget {
  // 設定画面から戻った時にInputScreenを更新するためのコールバック
  final VoidCallback? onFavoritesUpdated;

  const AppDrawer({super.key, this.onFavoritesUpdated});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // --- メインコンテンツ部分 (Expandedで伸ばす) ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text(
                    'メニュー',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('月別レポート'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MonthlyHistoryScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildSectionHeader("費目別"),
                _buildFilterTile(
                  context,
                  const CategoryTag('デフォルト', Colors.blueGrey),
                  'expense',
                ),
                ...expenseTags.map(
                  (tag) => _buildFilterTile(context, tag, 'expense'),
                ),
                const SizedBox(height: 15),
                const Divider(),
                _buildSectionHeader("支払い方法別"),
                _buildFilterTile(
                  context,
                  const CategoryTag('デフォルト', Colors.grey),
                  'payment',
                ),
                ...paymentTags.map(
                  (tag) => _buildFilterTile(context, tag, 'payment'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // --- 最下部の設定ボタン ---
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('設定'),
            onTap: () async {
              Navigator.pop(context); // ドロワーを閉じる
              // 設定画面へ遷移し、戻ってくるまで待機
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              // 戻ってきたらコールバックを実行してInputScreenを更新
              onFavoritesUpdated?.call();
            },
          ),
          // iPhone等の下のバーとかぶらないように少し余白
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 10, bottom: 5),
      child: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  Widget _buildFilterTile(
    BuildContext context,
    CategoryTag tag,
    String filterKey,
  ) {
    return ListTile(
      leading: Icon(
        filterKey == 'payment' ? Icons.payment : Icons.label,
        color: tag.color,
      ),
      title: Text(tag.label),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryScreen(
              filterValue: tag.label,
              filterKey: filterKey,
              color: tag.color,
            ),
          ),
        );
      },
    );
  }
}
