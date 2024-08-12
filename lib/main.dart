// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';


class ExchangeRateController extends GetxController {
  var exchangeRate = 0.0.obs;
  var convertedAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExchangeRate();
  }

  Future<void> fetchExchangeRate() async {
    try {
      final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/EGP'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        exchangeRate.value = data['rates']['USD'];
      } else {
        Get.snackbar('Error', 'Failed to load exchange rate');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load exchange rate');
    }
  }

  void convertCurrency(double amount) {
    convertedAmount.value = amount * exchangeRate.value;
  }
}


void main() {
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyHomePage(),
  ));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final ExchangeRateController controller = Get.put(ExchangeRateController());
  final TextEditingController egpController = TextEditingController();

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Currency Converter',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.teal[900],
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Title(
                  color: Colors.black,
                  child: Text(
                    'From EGP To USD',
                    style: TextStyle(fontSize: 30.5, color: Colors.white),
                  ),
                ),
                TextField(
                  controller: egpController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    suffix: Icon(CupertinoIcons.money_dollar),
                    hintText: 'Enter the amount in EGP',
                    hintStyle: TextStyle(color: Colors.white),
                    labelText: 'EGP',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    double amount = double.parse(egpController.text);
                    controller.convertCurrency(amount);
                  },
                  color: Colors.blue,
                  child: Text('Convert'),
                ),
                Obx(() => Title(
                  color: Colors.black,
                  child: Text(
                    '${controller.convertedAmount} USD',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
                Obx(() => controller.exchangeRate.value != 0
                    ? Text(
                        'Current Exchange Rate: 1 EGP = ${controller.exchangeRate.value} USD',
                        style: TextStyle(color: Colors.white),
                      )
                    : CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
