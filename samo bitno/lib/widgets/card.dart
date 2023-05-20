import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

/// Kartica za prikazivanje transakcija - sav kod je namijenjen samo prikazu transakcije na ekranu
class CustomCard extends StatelessWidget{
  String title;
  String description;
  num amount;
  DateTime date;
  String category;
  Function delete;

  CustomCard(this.title, this.description, this.amount, this.date, this.category, this.delete, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontSize: 22)),
                        Text(DateFormat("dd.MM.yyyy.").format(date)),
                      ],
                    ),
                    IconButton(
                        onPressed: () => delete(),
                        icon: Icon(Icons.delete, color: Colors.blue)
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                child: Text(description),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$amount €", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),),

                    /// botun za shareanje transakcije
                    IconButton(
                        onPressed: (){
                          Share.share('Check out my transaction made on ${DateFormat("dd.MM.yyyy.").format(date)}: \n\t Title: $title \n\t Description: $description \n\t Amount: $amount €');
                        },
                        icon: Icon(Icons.share, color: Colors.blue,)
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}