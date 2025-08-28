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
      case '2':
        print("Feature not implemented yet.");
        break;
      case '3':
        print("Feature not implemented yet.");
        break;
      case '4':
        await addExpense();
        break;
      case '5':
        await deleteExpense();
        break;
      case '6':
        print("-----Bye-----");
        return;
      default:
        print("Invalid choice!");
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
  stdout.write("Choose... ");
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

Future<void> addExpense() async {
  print("===== Add new expense =====");
  stdout.write("Item name: ");
  final item = stdin.readLineSync();

  stdout.write("Amount paid: ");
  final paidInput = stdin.readLineSync();

  if (item == null || item.isEmpty || paidInput == null || paidInput.isEmpty) {
    print("Invalid input!");
    return;
  }

  final paid = int.tryParse(paidInput);
  if (paid == null) {
    print("Amount must be a number!");
    return;
  }

  final uri = Uri.parse('http://localhost:3000/expenses');
  final response = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "user_id": 2,
      "item": item,
      "paid": paid,
    }),
  );

  if (response.statusCode == 200) {
    print("Added successfully!");
  } else {
    print("Error: ${response.statusCode}");
    print(response.body);
  }
}

Future<void> deleteExpense() async {
  print("===== Delete an item =====");
  stdout.write("Item id: ");
  final id = stdin.readLineSync();

  if (id == null || id.isEmpty) {
    print("Invalid id!");
    return;
  }

  final uri = Uri.parse('http://localhost:3000/expenses/$id');
  final response = await http.delete(uri);

  if (response.statusCode == 200) {
    print("Deleted!");
  } else if (response.statusCode == 404) {
    print("Item not found!");
  } else {
    print("Error: ${response.statusCode}");
    print(response.body);
  }
}
