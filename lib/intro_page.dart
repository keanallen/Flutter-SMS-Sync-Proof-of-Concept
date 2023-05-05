import 'package:flutter/material.dart';
import 'package:realtime_poc/home_page.dart';
import 'package:realtime_poc/user.dart';

class IntroPage extends StatelessWidget {
  IntroPage({super.key});

  final List<User> users = [
    //User(1, "Mark Loreto", "+639173242410"),
    //User(2, "Andrew Ayson", "+639617837182"),
    User(1, "Dummy", "+639952215588"),
    User(3, "Kean Allen", "+639952215588"),
  ];

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
            Text(
              "Please select a user",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 10),
            Column(
              children: List.generate(
                users.length,
                (index) => Container(
                  width: 200,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(
                            user: users[index],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: 10),
                          Text(users[index].name),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
