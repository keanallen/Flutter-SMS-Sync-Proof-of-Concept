import 'package:crypto_simple/crypto_simple.dart';
import 'package:realtime_poc/intro_page.dart';
import 'package:get_storage/get_storage.dart';
import 'package:telephony/telephony.dart';

backgrounMessageHandler(SmsMessage message) async {
  await GetStorage.init('PREFS');
  GetStorage storage = GetStorage('PREFS');
  CryptoSimple? crypt;

  crypt ??= CryptoSimple(
    superKey: 2023,
    subKey: 47,
    secretKey: "MySecretKey! ;)",
    encryptionMode: EncryptionMode.Randomized,
  );

  //Handle background message
  print("==== MESSAGE RECEIVED IN BACKGROUND ====");

  try {
    List items = storage.read('items') ?? [];

    var decrypted = CryptoSimple.decrypt(encrypted: message.body!);

    var body = jsonDecode(decrypted);

    int productId = body['pid'];
    int newQty = int.parse(body['value'].toString());
    String action = body['type'];
    String name = body['name'];

    print("=== BG PREFS ITEMS ===");
    print(items);
    List<String>? newVal = [];

    if (items != null) {
      newVal = [...items, message.body!];
    } else {
      newVal = [message.body!];
    }

    await storage.write('items', newVal);

    print("=== BG PREFS - NEWVAL ===");
    print(newVal);
    print("=== GS - NEWVAL ===");
    print(storage.read('items'));

    // var type = action == "increment"
    //     ? ProductAction.INCREMENT
    //     : action == "decrement"
    //         ? ProductAction.DECREMENT
    //         : ProductAction.NEW;

    // Product product = Product(productId, newQty, name);

    // streamController.add(ProductEvent([], type, product));
  } catch (e) {
    print("=== errror in BG ===");
    print(e);
  }
}

void main() async {
  CryptoSimple(
    superKey: 2023,
    subKey: 47,
    secretKey: "MySecretKey! ;)",
    encryptionMode: EncryptionMode.Randomized,
  );

  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init('PREFS');
  GetStorage('PREFS').write('items', []);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IntroPage(),
    );
  }
}
