import 'dart:math';

import 'package:flutter/material.dart';
import 'package:upi_pay/upi_pay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ApplicationMeta> appMetaList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: appMetaList.isNotEmpty
            ? ListView.builder(
                itemCount: appMetaList.length,
                itemBuilder: (context, index) => ListTile(
                      onTap: () async {
                        await _onTap(appMetaList[index]);
                      },
                      leading: (appMetaList[index].iconImage(48)),
                    ))
            : Text('No apps found'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          appMetaList = await UpiPay.getInstalledUpiApplications(
              statusType: UpiApplicationDiscoveryAppStatusType.all);
          print(appMetaList);
          setState(() {});
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _onTap(ApplicationMeta app) async {
    final err = _validateUpiAddress('7827715551@ybl');
    if (err != null) {
      setState(() {
        _upiAddrError = err;
      });
      return;
    }
    setState(() {
      _upiAddrError = null;
    });

    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    print("Starting transaction with id $transactionRef");

    final a = await UpiPay.initiateTransaction(
      amount: 20.toString(),
      app: app.upiApplication,
      receiverName: 'Sharad',
      receiverUpiAddress: '7827715551@ybl',
      transactionRef: transactionRef,
      transactionNote: 'UPI Payment',
    );

    print(a);
  }

  String? _upiAddrError;
  String? _validateUpiAddress(String value) {
    if (value.isEmpty) {
      return 'UPI VPA is required.';
    }
    if (value.split('@').length != 2) {
      return 'Invalid UPI VPA';
    }
    return null;
  }
}
