import 'package:flutter/material.dart';
import 'favorite_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.star_border),
            title: const Text('お気に入り設定'),
            subtitle: const Text('トップ画面上部のショートカットを変更します'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoriteSettingsScreen(),
                ),
              );
            },
          ),
          // 今後他の設定が増えたらここに追加
        ],
      ),
    );
  }
}
