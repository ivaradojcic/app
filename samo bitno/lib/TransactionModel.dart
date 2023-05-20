/// Klasa transakcija - sluzi za lakse spremanje u bazu, te citanje iz baze

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// moguce kategorije transakcija
Map<int, String> Categories = {
  0:"Odaberite kategoriju",
  1:"Odjeća",
  2:"Hrana",
  3:"Higijena",
  4:"Tehnologija",
  5:"Škola",
  6:"Režije",
};

/// Podatci bitni za svaku transakciju
class Transaction {
  String title;
  DateTime date;
  String description;
  num amount;
  int category;

  Transaction(this.title, this.date, this.description, this.amount, this.category);

  @override
  String toString() => "Title: $title; Date: $date; Description: $description; Amount: $amount; Category: $category"; // Just for print()
}

/// Adapter za spremati podatke u bazu
class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    return Transaction(reader.read(), reader.read(), reader.read(), reader.read(), reader.read());
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer.write(obj.title);
    writer.write(obj.date);
    writer.write(obj.description);
    writer.write(obj.amount);
    writer.write(obj.category);
  }
}