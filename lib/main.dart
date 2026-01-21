import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
  List<String> _history = [];
  final List<String> _categories = ['ご飯5杯', 'ラーメン', 'キング牛丼'];
  String _selectedCategory = 'ご飯5杯';

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  void _addExpense() {
    setState(() {
      String inputText = _controller.text;
      int inputAmount = int.tryParse(inputText) ?? 0;
      String memo = _memoController.text;

      if (inputAmount > 0) {
        _totalAmount += inputAmount;
        _history.insert(0, '$_selectedCategory¥$inputAmount:$memo');

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items: _categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
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
                        _history.removeAt(index);
                      });
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('削除しました')));
                    },

                    child: ListTile(title: Text(_history[index])),
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
