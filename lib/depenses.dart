import 'package:intl/intl.dart';

class Depenses {
  final int id;
  final double montant;
  final DateTime date;
  final String categorie;

  Depenses(this.id, this.montant, this.date, this.categorie);

  String get formattedDate {
    var formateur = DateFormat('yyyy-MM-dd');
    return formateur.format(date);
  }

  static final columns = ['id', 'montant', 'date', 'categorie'];

  factory Depenses.fromMap(Map<String, dynamic> data) {
    return Depenses(
      data['id'],
      data['montant'],
      DateTime.parse(data['date']),
      data['categorie'],
    );
  }
  Map<String, dynamic> toMap() => {
        'id': id,
        'montant': montant,
        'date': date.toString(),
        'categorie': categorie,
      };
}
