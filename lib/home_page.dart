import 'dart:async';

import 'package:crypto_simple/crypto_simple.dart';

import 'package:realtime_poc/product.dart';
import 'package:realtime_poc/stream.dart';
import 'package:realtime_poc/user.dart';
import 'package:get_storage/get_storage.dart';
import 'package:telephony/telephony.dart';

import 'main.dart';

final streamController = ProductService().controller;

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final Telephony telephony = Telephony.instance;
// Obtain shared preferences.

  late GetStorage storage;

  late StreamSubscription<Product> subscription;
  List<Product> products = [];
  final List<User> users = [
    User(1, "Dummy", "+639952215588"),
    User(3, "Kean Allen", "+639952215588"),
  ];

  // void subscribeToProductStream() {
  //   subscription = streamController.stream.listen((event) async {
  //     print("== STREAM ==");

  //     print(event.product.id);
  //     print(event.product.qty);
  //     print(event.action);
  //   });
  // }
  Future<void> _initStorage() async {
    await GetStorage.init('PREFS');
    storage = GetStorage('PREFS');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // SharedPreferences.getInstance().then((value) => prefs = value);
    _initStorage();

    if (state == AppLifecycleState.resumed) {
      print("=== RESUMED ===");

      List items = storage.read('items');

      print("== PREFS ==> $items");

      //if (items != null) {
      for (var message in items) {
        var decrypted = CryptoSimple.decrypt(encrypted: message);
        var body = jsonDecode(decrypted);

        print("======== BODY =======");
        print("MAP ===> $body");
        print("DECRYPTED ===> $decrypted");

        int productId = body['pid'];
        int newQty = int.parse(body['value'].toString());
        String action = body['type'];
        String name = body['name'];

        var type = action == "increment"
            ? ProductAction.INCREMENT
            : action == "decrement"
                ? ProductAction.DECREMENT
                : ProductAction.NEW;

        Product product = Product(productId, newQty, name);

        streamController.add(ProductEvent(products, type, product));
      }

      // widget.prefs.setStringList('items', []);
      //storage.write('items', []);
      //}
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    print("=== INIT STATE ===");
    addDummyProduct();
    listenIncoming();
    super.initState();
    // SharedPreferences.getInstance().then((value) {
    //   widget.prefs = value;
    // });
    WidgetsBinding.instance.addObserver(this);
    _initStorage();
  }

  void addDummyProduct() async {
    // prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    var product1 = Product(1, 10, "Apple");
    var product2 = Product(2, 7, "Banana");
    var product3 = Product(3, 100, "Mango");

    streamController.add(ProductEvent(
        [product1, product2, product3], ProductAction.NEW, product1));

    await Future.delayed(const Duration(milliseconds: 100));
    streamController.add(ProductEvent(
        [product1, product2, product3], ProductAction.NEW, product2));

    await Future.delayed(const Duration(milliseconds: 100));
    streamController.add(ProductEvent(
        [product1, product2, product3], ProductAction.NEW, product3));
  }

  void addNewProduct() {
    TextEditingController nameField = TextEditingController();
    TextEditingController qtyField = TextEditingController();

    Random random = Random();
    int randomNumber = random.nextInt(800000) + 10000;

    var alert = AlertDialog(
      title: const Text("New Product"),
      scrollable: true,
      content: Column(
        children: [
          TextField(
            controller: nameField,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              hintText: 'Name ...',
            ),
          ),
          TextField(
            controller: qtyField,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Quantity.',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            sendMessage(
              pid: randomNumber,
              type: ProductAction.NEW,
              value: int.parse(qtyField.text),
              productName: nameField.text,
            );
            Navigator.of(context).pop();
          },
          child: const Text("Submit"),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alert,
    );
  }

  @override
  Widget build(BuildContext context) {
    print(GetStorage('PREFS').read('items'));
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome back, ${widget.user.name}!"),
        actions: [
          IconButton(
              onPressed: () => addNewProduct(), icon: const Icon(Icons.add))
        ],
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Products",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: size.width,
                child: StreamBuilder<ProductEvent>(
                  stream: streamController.stream,
                  builder: (context, snapshot) {
                    print("=== snapshot builder ===");

                    print(snapshot.data?.products.length);

                    if (!snapshot.hasData) {
                      return SizedBox(
                        width: size.width,
                        height: size.height * 0.6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(height: 20),
                            Text('Waiting for some products...')
                          ],
                        ),
                      );
                    } else {
                      products = snapshot.data!.products;
                      var productSnapshot = snapshot.data!.product;

                      print(snapshot.data!.action.name);
                      print(productSnapshot.name);
                      var tIndex = products
                          .indexWhere((p) => p.id == productSnapshot.id);

                      if (snapshot.data!.action == ProductAction.INCREMENT) {
                        Product product = Product(
                            productSnapshot.id,
                            products[tIndex].qty + productSnapshot.qty,
                            products[tIndex].name);

                        var newProducts = [...products];
                        newProducts[tIndex] = product;

                        products = newProducts;
                      }

                      if (snapshot.data!.action == ProductAction.DECREMENT) {
                        Product product = Product(
                            productSnapshot.id,
                            products[tIndex].qty - productSnapshot.qty,
                            products[tIndex].name);

                        var newProducts = [...products];
                        newProducts[tIndex] = product;

                        products = newProducts;
                      }

                      if (snapshot.data!.action == ProductAction.NEW) {
                        Product product = Product(productSnapshot.id,
                            productSnapshot.qty, productSnapshot.name);

                        var newProducts = [...products];
                        if (products
                                .map((e) => e.id)
                                .toList()
                                .contains(productSnapshot.id) ==
                            false) {
                          newProducts.add(product);
                        }

                        products = newProducts;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        products.length,
                        (index) {
                          Color myColor = Colors.green;

                          if (index == 0 || index > 9) {
                            myColor = Colors.green[100]!;
                          } else {
                            myColor = Colors.orange[index * 100]!;
                          }

                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(products[index].name),
                            trailing: SizedBox(
                              width: 140,
                              child: Row(
                                children: [
                                  TextButton(
                                    onPressed: () => sendMessage(
                                        pid: products[index].id,
                                        type: ProductAction.DECREMENT),
                                    child: const Icon(
                                      Icons.remove,
                                      color: Colors.red,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => sendMessage(
                                        pid: products[index].id,
                                        type: ProductAction.INCREMENT),
                                    child: const Icon(
                                      Icons.add,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: myColor,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: FittedBox(
                                  child: Text(
                                    products[index].qty.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendMessage(
      {required int pid,
      required ProductAction type,
      int value = 1,
      String productName = ""}) async {
    String _type = "";

    // get the target product
    //var theProduct = streamController

    var tIndex = products.indexWhere((p) => p.id == pid);

    Product product = Product(pid, value, productName);

    var newProducts = [...products];
    newProducts.add(product);

    streamController.add(ProductEvent(products, type, product));

    _type = type == ProductAction.INCREMENT
        ? "increment"
        : type == ProductAction.DECREMENT
            ? "decrement"
            : "new";

    // need to get the other terminal address

    var recipients = users
        .where((element) => element.mobile != widget.user.mobile)
        .toList()
        .map((e) => e.mobile)
        .toList();

    //for (var mobile in recipients) {
    String address = "+639171130690";

    Map<String, dynamic> content = {
      "type": _type,
      "value": value,
      "pid": pid,
      "name": productName,
    };

    final String sha1Hash =
        CryptoSimple.encrypt(inputString: jsonEncode(content));

    telephony.sendSms(to: address, message: sha1Hash);
    //}
  }

  listenIncoming() async {
    telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          // Handle message
          try {
            print("==== MESSAGE RECEIVED ! ====");
            var decrypted = CryptoSimple.decrypt(encrypted: message.body!);

            var body = jsonDecode(decrypted);

            int productId = body['pid'];
            int newQty = int.parse(body['value'].toString());
            String action = body['type'];
            String name = body['name'];

            print(action);
            print(body);

            var type = action == "increment"
                ? ProductAction.INCREMENT
                : action == "decrement"
                    ? ProductAction.DECREMENT
                    : ProductAction.NEW;

            Product product = Product(productId, newQty, name);

            streamController.add(ProductEvent(products, type, product));
          } catch (e) {
            print("=== errror ===");
            print(e);
          }
        },
        onBackgroundMessage: backgrounMessageHandler);
  }
}
