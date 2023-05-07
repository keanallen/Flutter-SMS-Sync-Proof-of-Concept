// ignore_for_file: use_build_context_synchronously

import 'package:crypto_simple/crypto_simple.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:realtime_poc/data/database.dart';
import 'package:realtime_poc/home_page.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import 'data/user_model.dart';

class RecipientsPage extends StatefulWidget {
  const RecipientsPage({super.key});

  @override
  State<RecipientsPage> createState() => _RecipientsPageState();
}

class _RecipientsPageState extends State<RecipientsPage>
    with AutomaticKeepAliveClientMixin {
  final db = DatabaseHelper.instance;
  FocusNode _focusNode = FocusNode();
  List<User> users = [];

  Future<List<User>> getAllUser({bool force = false}) async {
    var dbUsers = await db.getAllUser();

    if (dbUsers.isNotEmpty) {
      if (force) {
        setState(() {
          users = dbUsers;
        });
      } else {
        users = dbUsers;
      }
    }

    return dbUsers;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.point_of_sale),
            Text("Terminals"),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              var user = users.firstWhere((element) => element.own == 1);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      user: user,
                      users: users,
                    ),
                  ),
                  (route) => false);
            },
            child: const Text("Done"),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        width: size.width * 0.7,
        child: ElevatedButton(
            onPressed: () => addTerminal(size),
            child: Padding(
              padding: const EdgeInsets.all(11.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add),
                  Text("Add new terminal"),
                ],
              ),
            )),
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Focus(
          focusNode: _focusNode,
          child: Column(
            children: [
              FutureBuilder(
                future: getAllUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: List.generate(
                            7,
                            (index) => Shimmer(
                                  child: Container(
                                    width: size.width,
                                    height: index % 2 == 0 ? 40 : 50,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    color: Colors.grey[300],
                                  ),
                                )),
                      ),
                    );
                  }

                  return Column(
                    children: List.generate(
                      users.length,
                      (index) => ListTile(
                        title: Text(users[index].name),
                        subtitle: Text(users[index].mobile),
                        trailing: users[index].own == 1
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.blue,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addTerminal(Size size) async {
    TextEditingController mobileField = TextEditingController();
    TextEditingController nameFiled = TextEditingController();

    var dialog = AlertDialog(
      scrollable: true,
      title: const Text("New Terminal"),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
        TextButton(
            onPressed: () async {
              final user =
                  User(mobile: mobileField.text, name: nameFiled.text, own: 0);

              await db.insertUser(user);
              await getAllUser(force: true);
              Navigator.pop(context);
            },
            child: const Text("Add")),
      ],
      content: Container(
        width: size.width * 0.7,
        color: Colors.white,
        child: Column(
          children: [
            TextField(
              controller: mobileField,
              decoration: const InputDecoration(
                hintText: 'Mobile Number',
                filled: true,
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameFiled,
              decoration: const InputDecoration(
                hintText: 'Name',
                filled: true,
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.name,
            ),
          ],
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (context) => dialog,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
