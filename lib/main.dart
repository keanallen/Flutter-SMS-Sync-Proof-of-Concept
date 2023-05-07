import 'package:realtime_poc/data/database.dart';
import 'package:crypto_simple/crypto_simple.dart';
import 'package:realtime_poc/intro_page.dart';
import 'package:realtime_poc/recipients_page.dart';
import 'package:telephony/telephony.dart';

CryptoSimple? crypt;

backgrounMessageHandler(SmsMessage message) async {
  if (kDebugMode) {
    print("==== MESSAGE RECEIVED IN BACKGROUND ====");
  }

  try {
    crypt ??= CryptoSimple(
      superKey: 2023,
      subKey: 47,
      secretKey: "MySecretKey! ;)",
      encryptionMode: EncryptionMode.Randomized,
    );

    var db = DatabaseHelper.instance;

    var decrypted = CryptoSimple.decrypt(encrypted: message.body!);

    // POC-SMS-APP=   it's just an identifier
    if (decrypted.contains("POC-SMS-APP=")) {
      decrypted = decrypted.replaceFirst("POC-SMS-APP=", "");

      var body = jsonDecode(decrypted);

      int productId = body['pid'];
      int newQty = int.parse(body['value'].toString());
      String action = body['type'];
      String name = body['name'];
      String date = body['date'];

      SMSData smsData = SMSData.fromMap({
        "type": action,
        "value": newQty,
        "pid": productId,
        "name": name,
        "date": date,
      });

      await db.insertData(smsData);
      if (kDebugMode) {
        print("== INSERTED ==");
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print("=== errror in BG ===");
      print(e);
    }
  }
}

void main() async {
  crypt ??= CryptoSimple(
    superKey: 2023,
    subKey: 47,
    secretKey: "MySecretKey! ;)",
    encryptionMode: EncryptionMode.Randomized,
  );

  WidgetsFlutterBinding.ensureInitialized();

  // create database
  await DatabaseHelper.instance.db;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  //const IntroPage()
  final db = DatabaseHelper.instance;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: db.getAllUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return snapshot.data != null && snapshot.data!.isNotEmpty
              ? const RecipientsPage()
              : const IntroPage();
        },
      ),
    );
  }
}
