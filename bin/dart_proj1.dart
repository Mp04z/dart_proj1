import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  while (true) {
    showmenu();
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await showall();
        break;
      case '6':
        print("Goodbye!");
        return;
      default:
        print("Feature not implemented yet.");
    }
  }
}

void showmenu() {
  print("\n========= Expense Tracking App =========");
  print("Welcome Tom");
  print("1. All expenses");
  print("2. Today's expense");
  print("3. Search expense");
  print("4. Add new expense");
  print("5. Delete an expense");
  print("6. Exit");
  stdout.write("Choose...");
}

Future<void> showall() async {
  final uri = Uri.parse('http://localhost:3000/expenses');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List result = jsonDecode(response.body);

    int total = 0;
    print("\n------------ All expenses -----------");
    for (final exp in result) {
      print('${exp["id"]}. ${exp["item"]} : ${exp["paid"]}฿ : ${exp["date"]}');
      total += exp["paid"] as int;
    }
    print("Total expenses = ${total}฿");
  } else {
    print("Error: ${response.statusCode}");
    print("Connection error!");
  }
}