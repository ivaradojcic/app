import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lorenloznik/TransactionModel.dart';

class StatisticsPage extends StatefulWidget {
  @override
  State<StatisticsPage> createState() => _StatisticsPage();
}

class _StatisticsPage extends State<StatisticsPage> {
  int _currentIndex = 1;

  List<_SalesData> data = [];

  late Box box;

  Map<DateTime, num> lastMonth = {};
  Map<num, num> byCat = {};

  /// prije nego sto se ista treba prikazivati na ekranu potrebno je ucitati podatke iz baze podataka
  void initState(){
    super.initState();

    /// generira listu zadnjih 30 dana - datumi
    DateTime end = DateTime.now();
    DateTime start = end.subtract(const Duration(days: 30));
    final daysToGenerate = end.difference(start).inDays;
    List<DateTime> days = List.generate(daysToGenerate, (i) => start.add(Duration(days: i)));

    /// za prikazivanje na grafu
    days.forEach((element) {
      lastMonth[DateTime(element.year, element.month, element.day)] = 0;
    });

    Hive.openBox('transactions').then((value){
      /// Nakon sta se baza ucita

      box = value;                    /// varijabla koja sluzi za identificiranje boxa u kojem su spremljeni svi podatci
      Iterable items = box.keys;      /// ime svih elemenata baze

      setState(() {
        items.forEach((element) {
          /// Prolazi kroz sve elemente u bazi

          Transaction transaction = box.get(element);

          DateTime date = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);  /// Datum transakcije
          if(lastMonth.keys.contains(date)){
            /// provjerava ako je transakcija odradena u zadnjih 30 dana
            ///
            /// ako je onda ju dodaje u listu lastMonth - za daljnu statistiku
            lastMonth[date] = lastMonth[date]! + transaction.amount;
            byCat[transaction.category] = byCat[transaction.category]??0 + transaction.amount;
          }

          print(transaction);
        });
      });

      print(lastMonth);
      print(byCat);
    });
  }

  @override
  Widget build(BuildContext context){

    data.removeRange(0, data.length);     /// ukoliko vec ima podataka, treba ih maknuti
    lastMonth.forEach((key, value) {      /// podatci za prikazivanje grafa
      data.add(_SalesData(DateFormat("dd").format(key), value.toDouble()));
    });


    String dailyAverage = (lastMonth.values.reduce((a, b) => a + b)/lastMonth.length).toStringAsFixed(2);         /// uzima zbroj svih transakcija i dijeli sa brojem dana u mjesecu - dnevni prosjek
    String weeklyAverage = (lastMonth.values.reduce((a, b) => a + b)/(lastMonth.length/7)).toStringAsFixed(2);    /// uzima zbroj svih transakcija u mjesecu i dijeli sa broju tjedana u mjesecu - tjedni prosjek
    String mothlyAmount = (lastMonth.values.reduce((a, b) => a + b)).toStringAsFixed(2);                          ///zbroj svih transakcija u mjesecu - ukupna potrosnja

    /// pretrazuje podatke za najvecu potrosnju
    Map<String, num> biggestSpend = {"key":0, "value": 0};

    byCat.forEach((key, value) {
      if(value > biggestSpend["value"]!){
        biggestSpend["key"] = key;
        biggestSpend["value"] = value;
      }
    });

    /// ime kategorije u obliku stringa
    String catName = Categories[biggestSpend["key"]!]!;

    /// prikaz svih prijasnje izracunatih podataka
    return Scaffold(
      appBar: AppBar(
        title: Text("Statistika troškova"),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ListView(
          children: [
            /// Graf
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  // Chart title
                  title: ChartTitle(text: 'Potrošnja 30 dana'),
                  // Enable legend
                  legend: Legend(isVisible: false),
                  // Enable tooltip
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries<_SalesData, String>>[
                    LineSeries<_SalesData, String>(
                        dataSource: data,
                        xValueMapper: (_SalesData sales, _) => sales.year,
                        yValueMapper: (_SalesData sales, _) => sales.sales,
                        name: 'Sales',
                        color: Colors.blue,
                        // Enable data label
                        dataLabelSettings: DataLabelSettings(isVisible: false))
                  ]),
            ),

            /// Dnevni prosijek
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Container(
                height: 48,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Dnevni prosijek: $dailyAverage €", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.blue,
                ),
              ),
            ),

            /// Tjedni prosijek
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Container(
                height: 48,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Tjedni prosijek: $weeklyAverage €", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.blue,
                ),
              ),
            ),

            /// Mjesecna potrosnja
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Container(
                height: 48,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Mjesečna potrošnja: $mothlyAmount €", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.blue,
                ),
              ),
            ),

            /// Kategorija sa najvecom potrosnjom
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Container(
                height: 48,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Najviše trošite na kategoriju: $catName", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),)
                      //Treba pisati na koju kategoriju troškova najvise trosimo (zadnjih mjesec dana)
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.blue[100],
                ),
              ),
            ),
          ],
        ),
      ),

      /// navigation bar - za promijeniti ekran izmedu pocetnog i ekrana sa statistikama
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() {
          _currentIndex = i;
          if (_currentIndex == 0){
            Navigator.pop(context);
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

/// klasa za unosenje podataka u graf
class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
