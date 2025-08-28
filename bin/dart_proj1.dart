import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

const String baseUrl = "http://localhost:3000";
String? loggedInUserId;
String? loggedInUsername;

void main() async {
  await login(); // ให้ล็อกอินก่อน

  if (loggedInUserId == null) {
    print("Login failed. Exiting...");
    return;
  }

  while (true) {
    showmenu();
    final choice = stdin.readLineSync();

    switch (choice) {
      
      case '2':
        await showtoday();
        break;
      case '6':
        print("Goodbye!");
        return;
      default:
        print("Feature not implemented yet.");
    }
  }
}

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
    loggedInUsername = username;
    showmenu();
  } else {
    final result = jsonDecode(response.body);
    print(" ${result['message']}");
  }
}

void showmenu() {
  
  print("\n========= Expense Tracking App =========");
  print("Welcome ${loggedInUsername ?? 'Guest'}");
  print("1. All expenses");
  print("2. Today's expense");
  print("3. Search expense");
  print("4. Add new expense");
  print("5. Delete an expense");
  print("6. Exit");
  stdout.write("Choose...");
}

void showall() {}

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

void addexpense() {}

void deleteexpense() {}
