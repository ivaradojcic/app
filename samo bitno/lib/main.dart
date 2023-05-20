import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'screens/input_screen.dart';
import 'screens/statistics_screen.dart';

import 'widgets/card.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
import 'TransactionModel.dart';

/// lista svih dopustenih slova za generiranje id-a
const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

/// kreira random string sa _chars - za generiranje random id-a
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

void main() async {
  /// Hive - baza podataka u mobitelu
  /// prije pokretanja same aplikacije treba inicijalizirati Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Organizator transakcija',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Organizator transakcija'),
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
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    /// cita imena elemenata u bazi - id transakcija
    var keys = Hive.box('transactions').keys;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        /// ListView - koristi se za buildat liste beskonacno dugacke (duzine koja je potrebna)
        child: ListView.builder(
            itemCount: keys.length,
            itemBuilder: (BuildContext context, int index) {
              /// cita sve transakcije iz baze
              Transaction transaction = Hive.box('transactions').get(keys.elementAt(index));

              /// prikazuje transakcije u obliku kartice
              return CustomCard(
                  transaction.title,
                  transaction.description,
                  transaction.amount,
                  transaction.date,
                  Categories[transaction.category]!,
                  (){
                    print("delete ${keys.elementAt(index)}");
                    setState((){
                      Hive.box('transactions').delete(keys.elementAt(index));
                    });
                  }
              );
            }),
      ),

      /// plusic u donjem desnom kutu ekrana
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // kad je pretisnut, pokrece ekran za dodavanje transakcija
          Navigator.push(context, MaterialPageRoute(builder: (context) => InputPage())).then((value) => setState((){}));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),

      /// navigation bar - za promijeniti ekran izmedu pocetnog i ekrana sa statistikama
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() {
          _currentIndex = i;
          if (_currentIndex == 1){
            Navigator.push(context, MaterialPageRoute(builder: (context) => StatisticsPage()));
            _currentIndex = 0;
          }
        }),
        items: [
          /// Pocetni ekran
          SalomonBottomBarItem(
            icon: Icon(Icons.attach_money),
            title: Text("Troškovi"),
            unselectedColor: Colors.blue,
            selectedColor: Colors.blue,
          ),

          /// Ekran sa statistikama
          SalomonBottomBarItem(
            icon: Icon(Icons.auto_graph),
            title: Text("Statistika"),
            unselectedColor: Colors.blue,
            selectedColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
