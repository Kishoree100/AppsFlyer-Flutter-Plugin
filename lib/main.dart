import 'package:flutter/material.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:clipboard/clipboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appsflyer Test App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Appsflyer Test App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AppsflyerSdk _appsflyerSdk;
  Map? _gcd;
  String _appsFlyerId = 'Loading...';
  String _customerUserId = '';
  String _deepLinkStatus = "Waiting for deep link...";
  Map<String, dynamic>? _deepLinkData;


  Future<void> initAF() async {
    final String cuid = "user_12345";
    _customerUserId = cuid;

    final AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey: "CpYt7yYGtdMfBHMPqBohs7",
      appId: "2468101214", // ios app
      showDebug: true,
    );

    _appsflyerSdk = AppsflyerSdk(options);
    _appsflyerSdk.setCustomerUserId(cuid);
    _appsflyerSdk.setAppInviteOneLinkID("BN7y", (res) {
      print("setAppInviteOneLinkID callback: $res");
    });

    _appsflyerSdk.onAppOpenAttribution((res) {
      print("App Open Attribution Data: $res");
    });

    _appsflyerSdk.onInstallConversionData((res) {
      print("Install Conversion Data: $res");
      setState(() {
        _gcd = res;
      });
    });

    _appsflyerSdk.onDeepLinking((DeepLinkResult deepLinkResult) {
      final dl = deepLinkResult.deepLink;

      setState(() {
        _deepLinkStatus = deepLinkResult.status.name;
        _deepLinkData = {
          "campaign": dl?.campaign,
          "mediaSource": dl?.mediaSource,
          "deepLinkValue": dl?.deepLinkValue,
          "matchType": dl?.matchType,
          "clickHttpReferrer": dl?.clickHttpReferrer,
          "isDeferred": dl?.isDeferred,
        };
      });

      switch (deepLinkResult.status) {
        case Status.FOUND:
          print("DeepLink found");
          break;
        case Status.NOT_FOUND:
          print("No deep link found");
          break;
        case Status.ERROR:
          print("DeepLink error: ${deepLinkResult.error}");
          break;
        case Status.PARSE_ERROR:
          print("DeepLink parse error");
          break;
      }
    });

    await _appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    final afId = await _appsflyerSdk.getAppsFlyerUID();
    setState(() {
      _appsFlyerId = afId ?? 'Unavailable';
      _customerUserId = cuid;
    });
  }

  @override
  void initState() {
    super.initState();
    initAF();
  }

  void _sendPurchaseEvent() {
    _appsflyerSdk.logEvent("af_purchase", {
      "af_revenue": "10.00",
      "af_currency": "USD",
    });
    print("Purchase event sent");
  }

  void _generateUserInviteLink() {
    final inviteParams = AppsFlyerInviteLinkParams(
      channel: "SDK",
      campaign: "user_invite",
      referrerName: "User123",
      customerID: "user_123",
      customParams: {
        "af_sub1": "custom_param"
      },
    );

    _appsflyerSdk.generateInviteLink(
      inviteParams,
          (dynamic inviteLink) {
        FlutterClipboard.copy(inviteLink);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Invite link copied to clipboard:\n$inviteLink")),
          );
        }
        print("Generated invite link: $inviteLink");
      },
          (dynamic error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to generate invite link: $error")),
          );
        }
        print("Error generating invite link: $error");
      },
    );
  }


  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Appsflyer Test App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),


              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AppsFlyer ID:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  SelectableText(
                    _appsFlyerId,
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Customer User ID:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _customerUserId,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _sendPurchaseEvent,
                child: const Text('Send Purchase Event'),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _generateUserInviteLink,
                child: const Text('User Invite'),
              ),
              const SizedBox(height: 30),

              Text(
                'Deep Link Status: $_deepLinkStatus',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (_deepLinkData != null) ...[
                const Text(
                  'Deep Link Data:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  _deepLinkData!
                      .entries
                      .map((e) => "${e.key}: ${e.value}")
                      .join("\n"),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 20),
              ],

              if (_gcd != null) ...[
                const Text(
                  'Install Conversion Data:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(_gcd.toString()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}