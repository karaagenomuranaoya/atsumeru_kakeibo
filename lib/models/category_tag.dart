import 'package:flutter/material.dart';

class CategoryTag {
  final String label;
  final Color color;
  final bool isCircle;

  const CategoryTag(this.label, this.color, {this.isCircle = false});
}

// 定数データ
final List<CategoryTag> expenseTags = [
  // ▼▼ 修正: 「デフォルト」は選択肢には表示しないため削除 ▼▼
  CategoryTag('食費', Colors.orange, isCircle: true),
  CategoryTag('日用品', Colors.green, isCircle: true),
  CategoryTag('雑費', Colors.blueGrey, isCircle: true),
  CategoryTag('交際費', Colors.pink, isCircle: true),
  CategoryTag('趣味', Colors.purple, isCircle: true),
];

final List<CategoryTag> paymentTags = [
  // ▼▼ 修正: 「現金」を選択肢として復活 ▼▼
  CategoryTag('現金', Colors.grey),
  CategoryTag('クレジットカード', Colors.blue),
  CategoryTag('PayPay', Colors.redAccent),
  CategoryTag('Suica', Colors.lightGreen),
];
