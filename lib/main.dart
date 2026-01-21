import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Category {
  final String name;
  final IconData icon;
  final Color color;

  Category({required this.name, required this.icon, required this.color});
}

//データの設計図
class ExpenseItem {
  final int amount;
  final Category category;
  final String memo;

  ExpenseItem({
    required this.amount,
    required this.category,
    required this.memo,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); //入ってきたキーを親に渡す 今は使わないけど将来のた目に残してある

  @override
  Widget build(BuildContext context) {
    //contextはGPS付きの連絡帳
    //画面を描くときに自動でbuildメソッドを実行する
    //widgetを返すよ
    return MaterialApp(
      //ほら、ウィジットでしょ？
      title: 'Nyaomaru Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'Nyaomaru Demo Home Page'), //最初に入るページ
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title}); //titleをすぐ下のタイトルに代入する

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState(); //newしたstateを渡す _はプライベート
}

class _MyHomePageState extends State<MyHomePage> {
  //MyHomePage という名前の部品とペア
  int _totalAmount = 0;
  //変更 リストの中身をStringからExpenseItemに変更

  List<ExpenseItem> _history = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  final List<Category> _categories = [
    Category(name: '食費', icon: Icons.fastfood, color: Colors.orange),
    Category(name: '交通費', icon: Icons.train, color: Colors.blue),
    Category(name: '日用品', icon: Icons.shopping_bag, color: Colors.green),
    Category(name: '趣味', icon: Icons.sports_esports, color: Colors.purple),
    Category(name: 'その他', icon: Icons.help_outline, color: Colors.grey),
  ];
  late Category _selectedCategory = _categories[0];

  void _addExpense() {
    setState(() {
      String inputText = _controller.text;
      int inputAmount = int.tryParse(inputText) ?? 0;
      String memo = _memoController.text;

      //変更ExpenseItemで追加
      if (inputAmount > 0) {
        _totalAmount += inputAmount;
        _history.insert(
          0,
          ExpenseItem(
            amount: inputAmount,
            category: _selectedCategory,
            memo: memo,
          ),
        );

        _controller.clear();
        _memoController.clear();
      }
    });
  }

  void _resetExpense() {
    setState(() {
      _totalAmount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            const Text('にゃおまるの貯金がこんなに増えたよ。'),
            Text(
              '$_totalAmount',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('カテゴリ：'),
                  DropdownButton<Category>(
                    value: _selectedCategory,
                    items: _categories.map((Category category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(category.icon, color: category.color),
                            const SizedBox(width: 10),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Category? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'いくら足すでやんす？'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
              child: TextField(
                controller: _memoController,
                decoration: const InputDecoration(labelText: '何に使ったの？'),
              ),
            ),
            const SizedBox(height: 20),
            const Text('これまでの履歴：'),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];

                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.star, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,

                    onDismissed: (direction) {
                      setState(() {
                        _totalAmount -= item.amount;
                        _history.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('削除しました(金額も戻したよ。えら！)')),
                      );
                    },

                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.category.color.withOpacity(0.2),
                        child: Icon(
                          item.category.icon,
                          color: item.category.color,
                        ),
                      ),
                      title: Text('¥${item.amount}'),
                      subtitle: Text(item.memo),
                    ),
                  );
                },
              ),
            ),

            const Icon(Icons.star, color: Colors.red),
            ElevatedButton(onPressed: _resetExpense, child: const Text('リセット')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        tooltip: 'Increment',
        child: const Icon(Icons.access_alarms_rounded),
      ),
    );
  }
}
