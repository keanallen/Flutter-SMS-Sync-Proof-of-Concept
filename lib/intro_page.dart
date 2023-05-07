// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:realtime_poc/main.dart';
import 'package:realtime_poc/recipients_page.dart';

import 'data/database.dart';
import 'data/user_model.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  TextEditingController mobileField = TextEditingController();
  TextEditingController nameFiled = TextEditingController();

  final db = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );

    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blue,
      body: SizedBox(
        width: size.width * 1,
        height: size.height * 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.point_of_sale_outlined,
              color: Colors.blue[900],
              size: 40,
            ),
            Text(
              "Welcome to MyPOS",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: size.width * 0.8,
              child: Column(
                children: [
                  TextField(
                    textAlign: TextAlign.center,
                    controller: mobileField,
                    decoration: InputDecoration(
                      hintText: 'Mobile Number',
                      filled: true,
                      border: InputBorder.none,
                      fillColor: Colors.blue[600],
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    textAlign: TextAlign.center,
                    controller: nameFiled,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      filled: true,
                      border: InputBorder.none,
                      fillColor: Colors.blue[600],
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: size.width,
                    child: ElevatedButton(
                      style: buttonStyle,
                      onPressed: nameFiled.text.isNotEmpty &&
                              mobileField.text.isNotEmpty
                          ? () async {
                              if (mobileField.text.trim().isEmpty ||
                                  mobileField.text.trim().length <= 4) return;

                              showDialog(
                                context: context,
                                builder: (context) => const Center(
                                    child: CircularProgressIndicator()),
                              );
                              await Future.delayed(const Duration(seconds: 1));
                              Navigator.of(context).pop();

                              final user = User(
                                  mobile: mobileField.text,
                                  name: nameFiled.text,
                                  own: 1);

                              await db.insertUser(user);

                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RecipientsPage(),
                                  ),
                                  (route) => false);
                            }
                          : null,
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text("Continue"),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
