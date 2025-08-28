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
const String baseUrl = "http://localhost:3000";
String? loggedInUserId;

Future<void> login() async {
  print("===== Login =====");

  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();

  if (username == null || password == null || username.isEmpty || password.isEmpty) {
    print("Incomplete input");
    return;
  }

  final body = {"username": username, "password": password};
  final url = Uri.parse('$baseUrl/login');
  final response = await http.post(url, body: body);

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    print(" ${result['message']}");
    loggedInUserId = result['userId'].toString();
    showtoday();
  } else {
    final result = jsonDecode(response.body);
    print(" ${result['message']}");
  }
}

Future<void> showtoday() async {
  final url = Uri.parse('$baseUrl/expenses/today/$loggedInUserId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List;
    int total = 0;
    print("---------- Today's expenses ----------");
    for (var i = 0; i < data.length; i++) {
      print(
        "${i + 1}. ${data[i]['item']} : ${data[i]['paid']}\$ : ${data[i]['date']}",
      );
      total += int.tryParse(data[i]['paid'].toString()) ?? 0;
    }
    print("Total expenses = ${total}\$");
  } else {
    print(" ${response.body}");
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